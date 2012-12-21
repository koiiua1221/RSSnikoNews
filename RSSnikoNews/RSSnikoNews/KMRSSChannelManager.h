//
//  KMRSSChannelManager.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMRSSChannel.h"

@interface KMRSSChannelManager : NSObject
{
    NSMutableArray* _channels;
}

@property (nonatomic, readonly) NSArray* channels;

+ (KMRSSChannelManager*)sharedManager;
- (void)addChannel:(KMRSSChannel*)channel;
- (void)insertChannel:(KMRSSChannel*)channel atIndex:(unsigned int)index;
- (void)removeChannelAtIndex:(unsigned int)index;
- (void)moveChannelAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (void)load;
- (void)save;

@end
