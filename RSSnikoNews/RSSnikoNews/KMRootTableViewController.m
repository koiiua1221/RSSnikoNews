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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRssChannel];
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
}

- (void)connectorInProgressRefreshAllChannels:(NSNotification*)notification
{
}

- (void)connectorDidFinishRefreshAllChannels:(NSNotification*)notification
{
}
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [[KMRSSConnector sharedConnector] cancelRefreshAllChannels];
}
@end
