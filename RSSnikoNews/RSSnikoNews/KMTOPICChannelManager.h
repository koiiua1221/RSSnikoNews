//
//  KMTOPICChannelManager.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMTOPICChannel.h"

@interface KMTOPICChannelManager : NSObject
{
    NSMutableArray* _channels;
}

@property (nonatomic, readwrite) NSMutableArray* channels;

+ (KMTOPICChannelManager*)sharedManager;
- (void)addChannel:(KMTOPICChannel*)channel;
- (void)insertChannel:(KMTOPICChannel*)channel atIndex:(unsigned int)index;
- (void)removeChannelAtIndex:(unsigned int)index;
- (void)removeAllChannel;
- (void)moveChannelAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (void)load;
- (void)save;

@end
