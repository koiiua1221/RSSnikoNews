//
//  KMRootTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRootTableViewController.h"
#import "KMRSSChannelManager.h"
#import "KMRSSItemListTableViewController.h"
#import "KMRSSConnector.h"

@interface KMRootTableViewController ()

@end

@implementation KMRootTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        self.title = @"RSS別";
        controller = [[KMRSSItemListTableViewController alloc] init];
        [[KMRSSConnector sharedConnector]addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRssChannel];
    NSNotificationCenter*   center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(connectorDidBeginRefreshAllChannels:)
                   name:RSSConnectorDidBeginRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorInProgressRefreshAllChannels:)
                   name:RSSConnectorInProgressRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorDidFinishRefreshAllChannels:)
                   name:RSSConnectorDidFinishRefreshAllChannels object:nil];
}
- (void)initRssChannel {
    if ([KMRSSChannelManager sharedManager].channels.count==0)
    { 
        NSString *file = [[NSBundle mainBundle] pathForResource:@"rss" ofType:@"plist"];
        NSArray *rssChannelArray = [NSArray arrayWithContentsOfFile:file];
        
        for (NSDictionary *rssChannelData in rssChannelArray)
        {
            KMRSSChannel* rssChannel;
            rssChannel = [[KMRSSChannel alloc]init];
            [[KMRSSChannelManager sharedManager]addChannel:rssChannel];
            rssChannel.title = [rssChannelData objectForKey:@"title"];
            rssChannel.feedUrlString = [rssChannelData objectForKey:@"feedUrlString"];
        }
        [[KMRSSChannelManager sharedManager]save];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
   
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadChannel)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    NSArray*    channels;
    channels = [KMRSSChannelManager sharedManager].channels;
    if ([self.tableView numberOfRowsInSection:0] != [channels count]) {
        [self.tableView reloadData];
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
    if (!_isDownloaded) {
        [[KMRSSConnector sharedConnector]refreshAllChannels];
        _isDownloaded=YES;
    }

}
- (void)reloadChannel
{
    [[KMRSSConnector sharedConnector] cancelRefreshAllChannels];
    [[KMRSSConnector sharedConnector]refreshAllChannels];
    _isDownloaded=YES;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    KMRSSChannel* channel =[[KMRSSChannelManager sharedManager].channels objectAtIndex:indexPath.row];
    cell.textLabel.text = channel.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [KMRSSChannelManager sharedManager].channels.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rootCell";
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
    KMRSSChannel* channel = nil;
    channels = [KMRSSChannelManager sharedManager].channels;
    if (indexPath.row < [channels count]) {
        channel = [channels objectAtIndex:indexPath.row];
    }
    if (!channel) {
        return;
    }
//    KMRSSItemListTableViewController*  controller;
//    controller = [[KMRSSItemListTableViewController alloc] init];
    controller.channel = channel;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"チャンネル";
}

- (void)connectorDidBeginRefreshAllChannels:(NSNotification*)notification
{
/*
    _refreshAllChannelsSheet = [[UIActionSheet alloc]
                                initWithTitle:@"ダウンロード中…"
                                delegate:self
                                cancelButtonTitle:@"キャンセル"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showFromTabBar:self.tabBarController.tabBar];
*/
}

- (void)connectorInProgressRefreshAllChannels:(NSNotification*)notification
{
/*
    // 進捗を取得する
    float   progress;
    progress = [[KMRSSConnector sharedConnector] progressOfRefreshAllChannels];
    
    // アクションシートのタイトルを更新する
    _refreshAllChannelsSheet.title =
    [NSString stringWithFormat:@"Refreshing all channels… %d", (int)(progress * 100)];
*/
}

- (void)connectorDidFinishRefreshAllChannels:(NSNotification*)notification
{
/*
    [_refreshAllChannelsSheet dismissWithClickedButtonIndex:0 animated:YES];
    _refreshAllChannelsSheet = nil;
*/
}
- (void)_updateNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =
    [KMRSSConnector sharedConnector].networkAccessing;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        [self _updateNetworkActivity];
    }
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [[KMRSSConnector sharedConnector] cancelRefreshAllChannels];
}
@end
