//
//  KMSaveItemManager.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMSaveItem.h"

@interface KMSaveItemManager : NSObject
{
    NSMutableArray* _saveItems;
}

@property (nonatomic, readonly) NSArray* saveItems;

+ (KMSaveItemManager*)sharedManager;
- (void)addSaveItem:(KMSaveItem*)saveItem;
- (void)insertSaveItem:(KMSaveItem*)saveItem atIndex:(unsigned int)index;
- (void)removeSaveItemAtIndex:(unsigned int)index;
- (void)moveSaveItemAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (void)load;
- (void)save;

@end
