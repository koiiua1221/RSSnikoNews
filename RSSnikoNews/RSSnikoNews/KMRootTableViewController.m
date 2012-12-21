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
        self.title = @"ニコニコニュースRSS";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([KMRSSChannelManager sharedManager].channels.count==0)
    {
        //ToDo 定数配列の宣言位置をしかるべきところへ
        NSArray *nikoRssChannelName = [NSArray arrayWithObjects:@"トピックス",
                                                                @"ホットランキング",
                                                                @"デイリーランキング",
                                                                @"ウィークリーランキング",
                                                                @"NCN", nil];
        NSArray *nikoRssChannelUrl = [NSArray arrayWithObjects: @"http://news.nicovideo.jp/topiclist?rss=2.0",
                                                                @"http://news.nicovideo.jp/ranking/hot?rss=2.0",
                                                                @"http://news.nicovideo.jp/ranking/daily?rss=2.0",
                                                                @"http://news.nicovideo.jp/ranking/weekly?rss=2.0",
                                                                @"http://news.nicovideo.jp/media/article/1?rss=2.0", nil];
        int i;
        for (i = 0; i<maxnum; i++)
        {
            KMRSSChannel* rssChannel;
            rssChannel = [[KMRSSChannel alloc]init];
            [[KMRSSChannelManager sharedManager]addChannel:rssChannel];
            rssChannel.title = [nikoRssChannelName objectAtIndex:i];
            rssChannel.feedUrlString = [nikoRssChannelUrl objectAtIndex:i];
        }
        [[KMRSSChannelManager sharedManager]save];
    }
    [[KMRSSConnector sharedConnector]refreshAllChannels];

}

-(void)viewWillAppear:(BOOL)animated
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    [self.navigationController pushViewController:controller animated:YES];}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"\n\n\n\nチャンネル選択";//中央揃えにする //ToDo　iphone5,4s以前とで微調整
}

- (void)connectorDidBeginRefreshAllChannels:(NSNotification*)notification
{
    // アクションシートを表示する
    _refreshAllChannelsSheet = [[UIActionSheet alloc]
                                initWithTitle:@"Refreshing all channels…"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showFromToolbar:self.navigationController.toolbar];
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
}
@end
