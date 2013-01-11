//
//  KMSaveItemManager.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMSaveItemManager.h"

@implementation KMSaveItemManager

@synthesize saveItems = _saveItems;
static KMSaveItemManager*  _sharedInstance = nil;

+ (KMSaveItemManager*)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[KMSaveItemManager alloc] init];
    }
    return _sharedInstance;
}
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _saveItems = [NSMutableArray array];
    return self;
}
- (void)addSaveItem:(KMSaveItem*)saveItem
{
    if (!saveItem) {
        return;
    }
    [_saveItems addObject:saveItem];
}
- (void)insertSaveItem:(KMSaveItem*)saveItem atIndex:(unsigned int)index
{
    if (!saveItem) {
        return;
    }
    if (index > [_saveItems count]) {
        return;
    }
    [_saveItems insertObject:saveItem atIndex:index];
}
- (void)removeSaveItemAtIndex:(unsigned int)index
{
    if (index > [_saveItems count] - 1) {
        return;
    }
    [_saveItems removeObjectAtIndex:index];
}
- (void)moveSaveItemAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex
{
    if (fromIndex > [_saveItems count] - 1) {
        return;
    }
    if (toIndex > [_saveItems count]) {
        return;
    }
    KMSaveItem* saveItem;
    saveItem = [_saveItems objectAtIndex:fromIndex];
    [_saveItems removeObject:saveItem];
    [_saveItems insertObject:saveItem atIndex:toIndex];
}
- (NSString*)_saveItemDir
{
    NSArray*    paths;
    NSString*   path;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@".saveItem"];
    return path;
}

- (NSString*)_saveItemPath
{
    NSString*   path;
    path = [[self _saveItemDir] stringByAppendingPathComponent:@"saveItem.dat"];
    return path;
}
- (void)load
{
    NSString*   saveItemPath;
    saveItemPath = [self _saveItemPath];
    if (!saveItemPath || ![[NSFileManager defaultManager] fileExistsAtPath:saveItemPath]) {
        return;
    }
    NSArray*    saveItems;
    saveItems = [NSKeyedUnarchiver unarchiveObjectWithFile:saveItemPath];
    if (!saveItems) {
        return;
    }
    [_saveItems setArray:saveItems];
}
- (void)save
{
    NSFileManager*  fileMgr;
    fileMgr = [NSFileManager defaultManager];
    NSString*   saveItemDir;
    saveItemDir = [self _saveItemDir];
    if (![fileMgr fileExistsAtPath:saveItemDir]) {
        NSError*    error;
        [fileMgr createDirectoryAtPath:saveItemDir
           withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString*   saveItemPath;
    saveItemPath = [self _saveItemPath];
    [NSKeyedArchiver archiveRootObject:_saveItems toFile:saveItemPath];
}
@end
