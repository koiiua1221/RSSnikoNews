//
//  KMTOPICRootTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMTOPICRootTableViewController.h"
#import "KMTOPICChannelManager.h"
#import "KMTOPICItemListTableViewController.h"
#import "KMTOPICConnector.h"
#import "XPathQuery.h"
#import "KMTOPICChannel.h"
#import "KMTOPICResponseParser.h"
#import "KMTOPICItem.h"
@interface KMTOPICRootTableViewController ()
@end

@implementation KMTOPICRootTableViewController
@synthesize networkState = _networkState;
@synthesize downloadedData = _downloadedData;
@synthesize parsedChannel = _parsedChannel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        self.title = @"トピック別 News";
        [[KMTOPICConnector sharedConnector]addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)initTOPICChannel {
    
    [[KMTOPICChannelManager sharedManager] removeAllChannel];
    _refreshAllChannelsSheet = [[UIActionSheet alloc]
                                initWithTitle:@"ダウンロード中…"
                                delegate:self
                                cancelButtonTitle:@"キャンセル"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showInView:self.view];
    [self parse];
}
- (void)parse
{
    NSURLRequest*   request = nil;
    NSURL*  url;
    url = [NSURL URLWithString:@"http://news.nicovideo.jp/"];
    request = [NSURLRequest requestWithURL:url];
    
    if (!request) {
        return;
    }
    _downloadedData = nil;
    _downloadedData = [NSMutableData data];

    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    _networkState = TOPICNetworkStateInProgress;
}
#pragma mark -- NSURLConnectionDelegate --
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_downloadedData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    
    NSArray *titles = PerformHTMLXPathQuery(_downloadedData, @"//div/ul/li/span[@class='topics-tab-text']");
    NSArray *urls = PerformHTMLXPathQuery(_downloadedData, @"//div[@class='topics-index']");
    
    for (NSDictionary *title in titles) {
        NSString *topicTitle = [title objectForKey:@"nodeContent"];
        if ([topicTitle isEqualToString:@"ランキング"]) {
            continue;
        }
        KMTOPICChannel *topicChannel = [[KMTOPICChannel alloc]init];
        [[KMTOPICChannelManager sharedManager]addChannel:topicChannel];
        topicChannel.title = topicTitle;
        NSLog([title objectForKey:@"nodeContent"]);
    }
    NSArray *topicChannels = [[KMTOPICChannelManager sharedManager] channels];
    int i=0;
    for (NSDictionary *urldic in urls) {
        NSArray *topicArray = [[[urldic objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeChildArray"];
        NSMutableArray *items = [NSMutableArray array];
        KMTOPICChannel *topicChannel;
        for (NSDictionary *topicDic in topicArray) {
            NSString *baseUrl = @"http://news.nicovideo.jp";
            NSDictionary *childArray = [[topicDic objectForKey:@"nodeChildArray"] objectAtIndex:0];
            KMTOPICItem*    item;
            item = [[KMTOPICItem alloc] init];
            [items addObject:item];
            topicChannel = [topicChannels objectAtIndex:i];
            item.title = [childArray objectForKey:@"nodeContent"];
            item.link =[baseUrl stringByAppendingString:
            [[[childArray objectForKey:@"nodeAttributeArray"]objectAtIndex:0]objectForKey:@"nodeContent"]];
            NSLog([childArray objectForKey:@"nodeContent"]);
            NSLog([[[childArray objectForKey:@"nodeAttributeArray"]objectAtIndex:0]objectForKey:@"nodeContent"]);            
        }
        [topicChannel.items setArray:items];
        i++;
    }
    _networkState = TOPICNetworkStateFinished;
    _connection = nil;

    [self.tableView reloadData];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_refreshAllChannelsSheet dismissWithClickedButtonIndex:0 animated:YES];
    _refreshAllChannelsSheet = nil;

}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _networkState = TOPICNetworkStateError;
    _connection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
    
    if (!_isDownloaded) {
        [self initTOPICChannel];
        _isDownloaded=YES;
    }
    
    NSArray*    channels;
    channels = [KMTOPICChannelManager sharedManager].channels;
    if ([self.tableView numberOfRowsInSection:0] != [channels count]) {
        [self.tableView reloadData];
        // 最後の行を表示する
        if ([channels count] > 0) {
            NSIndexPath*    lastIndexPath;
            lastIndexPath = [NSIndexPath indexPathForRow:[channels count] - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }else {
        NSIndexPath*    indexPath;
        indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        for (UITableViewCell* cell in [self.tableView visibleCells]) {
            [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
        }
    }
    NSNotificationCenter*   center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(connectorDidBeginRefreshAllChannels:)
                   name:TOPICConnectorDidBeginRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorInProgressRefreshAllChannels:)
                   name:TOPICConnectorInProgressRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorDidFinishRefreshAllChannels:)
                   name:TOPICConnectorDidFinishRefreshAllChannels object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    KMTOPICChannel* hchannel = [[KMTOPICChannelManager sharedManager].channels objectAtIndex:indexPath.row];
    cell.textLabel.text = hchannel.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [KMTOPICChannelManager sharedManager].channels.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TOPICRootCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray*    channels;
    KMTOPICChannel* channel = nil;
    channels = [KMTOPICChannelManager sharedManager].channels;
    if (indexPath.row < [channels count]) {
        channel = [channels objectAtIndex:indexPath.row];
    }
    if (!channel) {
        return;
    }
    KMTOPICItemListTableViewController*  controller;
    controller = [[KMTOPICItemListTableViewController alloc] init];
    controller.channel = channel;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"トピック";
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSInteger cellnum = [KMTOPICChannelManager sharedManager].channels.count;
    
    if (indexPath.row >= cellnum) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }

}
- (void)connectorDidBeginRefreshAllChannels:(NSNotification*)notification
{
    _refreshAllChannelsSheet = [[UIActionSheet alloc]
                                initWithTitle:@"ダウンロード中…"
                                delegate:self
                                cancelButtonTitle:@"キャンセル"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)connectorInProgressRefreshAllChannels:(NSNotification*)notification
{
    float   progress;
    progress = [[KMTOPICConnector sharedConnector] progressOfRefreshAllChannels];
    
    _refreshAllChannelsSheet.title =
    [NSString stringWithFormat:@"Refreshing all channels… %d", (int)(progress * 100)];
}

- (void)connectorDidFinishRefreshAllChannels:(NSNotification*)notification
{
}
- (void)_updateNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =
    [KMTOPICConnector sharedConnector].networkAccessing;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        [self _updateNetworkActivity];
    }
}
@end
