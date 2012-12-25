//
//  KMHTMLChannelManager.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMHTMLChannel.h"

@interface KMHTMLChannelManager : NSObject
{
    NSMutableArray* _channels;
}

@property (nonatomic, readonly) NSArray* channels;

+ (KMHTMLChannelManager*)sharedManager;
- (void)addChannel:(KMHTMLChannel*)channel;
- (void)insertChannel:(KMHTMLChannel*)channel atIndex:(unsigned int)index;
- (void)removeChannelAtIndex:(unsigned int)index;
- (void)moveChannelAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (void)load;
- (void)save;

@end
