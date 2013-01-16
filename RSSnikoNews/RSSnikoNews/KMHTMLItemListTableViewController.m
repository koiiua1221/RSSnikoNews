//
//  KMHTMLItemListTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMHTMLItemListTableViewController.h"
#import "KMHTMLItem.h"
#import "KMHTMLChannel.h"
#import "KMContentViewController.h"
#import "KMHTMLConnector.h"

@interface KMHTMLItemListTableViewController ()

@end

@implementation KMHTMLItemListTableViewController
@synthesize delegate = _delegate;
@synthesize channel = _channel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
//        [[KMHTMLConnector sharedConnector]addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
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
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible==YES) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = _channel.title;

    NSIndexPath*    indexPath;
    indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
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
/*
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
}
*/
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
    KMContentViewController*   controller;
    controller = [[KMContentViewController alloc] initWithSaveButton];
    controller.item = item;
    controller.delegate = self;
        
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title=@"戻る";
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
