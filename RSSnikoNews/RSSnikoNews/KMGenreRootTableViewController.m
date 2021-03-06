//
//  KMGenreRootTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMGenreRootTableViewController.h"
#import "KMHTMLChannelManager.h"
#import "KMGenreItemListTableViewController.h"
#import "KMHTMLConnector.h"

@interface KMGenreRootTableViewController ()

@end

@implementation KMGenreRootTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        self.title = @"ジャンル別";
        controller = [[KMGenreItemListTableViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initHTMLChannel];
//    [[KMHTMLConnector sharedConnector]addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
/*
    NSNotificationCenter*   center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(connectorDidBeginRefreshAllChannels:)
                   name:HTMLConnectorDidBeginRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorInProgressRefreshAllChannels:)
                   name:HTMLConnectorInProgressRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorDidFinishRefreshAllChannels:)
                   name:HTMLConnectorDidFinishRefreshAllChannels object:nil];
*/
}
- (void)initHTMLChannel {
    if ([KMHTMLChannelManager sharedManager].channels.count==0)
    {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"genre" ofType:@"plist"];
        NSArray *genreChannelArray = [NSArray arrayWithContentsOfFile:file];

        for (NSDictionary *genreChannelData in genreChannelArray)
        {
            KMHTMLChannel* htmlChannel;
            htmlChannel = [[KMHTMLChannel alloc]init];
            [[KMHTMLChannelManager sharedManager]addChannel:htmlChannel];
            htmlChannel.title = [genreChannelData objectForKey:@"title"];
            htmlChannel.feedUrlString = [genreChannelData objectForKey:@"feedUrlString"];
        }
        [[KMHTMLChannelManager sharedManager]save];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
/*
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadChannel)];
    self.navigationItem.rightBarButtonItem = reloadButton;
*/    
    NSArray*    channels;
    channels = [KMHTMLChannelManager sharedManager].channels;
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
/*
    if (!_isDownloaded) {
        [[KMHTMLConnector sharedConnector]refreshAllChannels];
        _isDownloaded=YES;
    }
*/
}
/*
- (void)viewWillUnload
{
    [[KMHTMLConnector sharedConnector]removeObserver:self forKeyPath:@"networkAccessing"];
}
*/
/*
- (void)reloadChannel
{
    [[KMHTMLConnector sharedConnector] cancelRefreshAllChannels];
    [[KMHTMLConnector sharedConnector]refreshAllChannels];
//    _isDownloaded=YES;
    
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    KMHTMLChannel* hchannel = [[KMHTMLChannelManager sharedManager].channels objectAtIndex:indexPath.row];
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
    return [KMHTMLChannelManager sharedManager].channels.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"genreRootCell";
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
    KMHTMLChannel* channel = nil;
    channels = [KMHTMLChannelManager sharedManager].channels;
    if (indexPath.row < [channels count]) {
        channel = [channels objectAtIndex:indexPath.row];
    }
    if (!channel) {
        return;
    }

//    KMGenreItemListTableViewController*  controller;
//    controller = [[KMGenreItemListTableViewController alloc] init];
    controller.channel = channel;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ジャンル";
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
    progress = [[KMHTMLConnector sharedConnector] progressOfRefreshAllChannels];
    
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
/*
- (void)_updateNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =
    [KMHTMLConnector sharedConnector].networkAccessing;
}
*/
/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        [self _updateNetworkActivity];
    }
}
*/
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [[KMHTMLConnector sharedConnector] cancelRefreshAllChannels];
}

@end
