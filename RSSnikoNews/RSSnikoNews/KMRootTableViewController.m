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
        // Custom initialization
        self.view.backgroundColor = [UIColor grayColor];
        self.title = @"RSS別 News";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRssChannel];
    [[KMRSSConnector sharedConnector]refreshAllChannels];
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
    
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
    
    NSArray*    channels;
    channels = [KMRSSChannelManager sharedManager].channels;
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
                   name:RSSConnectorDidBeginRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorInProgressRefreshAllChannels:)
                   name:RSSConnectorInProgressRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorDidFinishRefreshAllChannels:)
                   name:RSSConnectorDidFinishRefreshAllChannels object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
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
    // Configure the cell...
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
    KMRSSItemListTableViewController*  controller;
    controller = [[KMRSSItemListTableViewController alloc] init];
    controller.channel = channel;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"\n\n\nチャンネル";//中央寄せ
}

- (void)connectorDidBeginRefreshAllChannels:(NSNotification*)notification
{
    _refreshAllChannelsSheet = [[UIActionSheet alloc]
                                initWithTitle:@"Refreshing all channels…"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showFromToolbar:self.navigationController.toolbar];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
}

- (void)connectorInProgressRefreshAllChannels:(NSNotification*)notification
{
    // 進捗を取得する
    float   progress;
    progress = [[KMRSSConnector sharedConnector] progressOfRefreshAllChannels];
    
    // アクションシートのタイトルを更新する
    _refreshAllChannelsSheet.title =
    [NSString stringWithFormat:@"Refreshing all channels… %d", (int)(progress * 100)];

}

- (void)connectorDidFinishRefreshAllChannels:(NSNotification*)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
@end
