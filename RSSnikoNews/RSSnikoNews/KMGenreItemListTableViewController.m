//
//  KMGenreItemListTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMGenreItemListTableViewController.h"
#import "KMHTMLItem.h"
#import "KMHTMLChannel.h"
#import "KMContentViewController.h"
#import "KMHTMLConnector.h"

#import "KMContentViewController.h"
#import "IIViewDeckController.h"
#import "KMContentTwitterViewController.h"

@interface KMGenreItemListTableViewController ()

@end

@implementation KMGenreItemListTableViewController
@synthesize delegate = _delegate;
@synthesize channel = _channel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[KMHTMLConnector sharedConnector]addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
/*
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible==YES) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
*/
    self.title = _channel.title;

    [[KMHTMLConnector sharedConnector]refreshChannel:_channel.feedUrlString];

    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadChannel)];
    self.navigationItem.rightBarButtonItem = reloadButton;

    NSIndexPath*    indexPath;
    indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
    
//    [self.tableView reloadData];
}
- (void)reloadChannel
{
    [[KMHTMLConnector sharedConnector]refreshChannel:_channel.feedUrlString];
    //    _isDownloaded=YES;
    
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSArray*    items;
    KMHTMLItem*    item = nil;
    items = _channel.items;
    if (indexPath.row < [items count]) {
        item = [items objectAtIndex:indexPath.row];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.textLabel.text = item.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/*
- (void)viewWillUnload
{
    [[KMHTMLConnector sharedConnector]removeObserver:self forKeyPath:@"networkAccessing"];
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _channel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HTMLItemListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self _updateCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)_updateNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =
    [KMHTMLConnector sharedConnector].networkAccessing;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        [self _updateNetworkActivity];
    }
    if (![KMHTMLConnector sharedConnector].networkAccessing) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray*    items;
    KMHTMLItem*    item = nil;
    items = _channel.items;
    if (indexPath.row < [items count]) {
        item = [items objectAtIndex:indexPath.row];
    }
    
    if (!item) {
        return;
    }
    KMContentViewController*  controller;
    controller = [[KMContentViewController alloc] init];
    controller.item = item;
    controller.delegate = self;
    
    KMContentTwitterViewController*  twitterView;
    twitterView = [[KMContentTwitterViewController alloc] init];
    twitterView.item = item;
    twitterView.delegate = self;
    
    IIViewDeckController *deckView = [[IIViewDeckController alloc]initWithCenterViewController:controller leftViewController:twitterView save:YES];
    deckView.item = item;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title=@"戻る";
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:deckView animated:YES];
}

@end
