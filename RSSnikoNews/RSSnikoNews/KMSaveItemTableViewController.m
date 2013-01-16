//
//  KMSaveItemTableViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMSaveItemTableViewController.h"
#import "KMSaveItemManager.h"
#import "KMContentViewController.h"

@interface KMSaveItemTableViewController ()

@end

@implementation KMSaveItemTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"保存News";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[KMSaveItemManager sharedManager] load];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];

    NSArray*    saveItems;
    saveItems = [KMSaveItemManager sharedManager].saveItems;
    if ([self.tableView numberOfRowsInSection:0] != [saveItems count]) {
        [self.tableView reloadData];
        if ([saveItems count] > 0) {
            NSIndexPath*    lastIndexPath;
            lastIndexPath = [NSIndexPath indexPathForRow:[saveItems count] - 1 inSection:0];
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
    KMSaveItem* saveItem =[[KMSaveItemManager sharedManager].saveItems objectAtIndex:indexPath.row];
    cell.textLabel.text = saveItem.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [KMSaveItemManager sharedManager].saveItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SaveItemCell";
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
    NSArray*    saveItems;
    KMSaveItem* saveItem = nil;
    saveItems = [KMSaveItemManager sharedManager].saveItems;
    if (indexPath.row < [saveItems count]) {
        saveItem = [saveItems objectAtIndex:indexPath.row];
    }
    if (!saveItem) {
        return;
    }
    KMContentViewController*  controller;
    controller = [[KMContentViewController alloc] init];
    controller.item = saveItem;
    controller.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title=@"戻る";
    self.navigationItem.backBarButtonItem=backButton;

    [self.navigationController pushViewController:controller animated:YES];
}
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[KMSaveItemManager sharedManager] removeSaveItemAtIndex:indexPath.row];
    [[KMSaveItemManager sharedManager] save];
    [self.tableView reloadData];
    
}
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
@end
