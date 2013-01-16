//
//  KMRSSChannelManager.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRSSChannelManager.h"

@implementation KMRSSChannelManager

@synthesize channels = _channels;
static KMRSSChannelManager*  _sharedInstance = nil;

+ (KMRSSChannelManager*)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[KMRSSChannelManager alloc] init];
    }
    return _sharedInstance;
}
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _channels = [NSMutableArray array];
    return self;
}
- (void)addChannel:(KMRSSChannel*)channel
{
    if (!channel) {
        return;
    }
    [_channels addObject:channel];
}
- (void)insertChannel:(KMRSSChannel*)channel atIndex:(unsigned int)index
{
    if (!channel) {
        return;
    }
    if (index > [_channels count]) {
        return;
    }
    [_channels insertObject:channel atIndex:index];
}
- (void)removeChannelAtIndex:(unsigned int)index
{
    if (index > [_channels count] - 1) {
        return;
    }
    [_channels removeObjectAtIndex:index];
}
- (void)moveChannelAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex
{
    if (fromIndex > [_channels count] - 1) {
        return;
    }
    if (toIndex > [_channels count]) {
        return;
    }
    KMRSSChannel* channel;
    channel = [_channels objectAtIndex:fromIndex];
    [_channels removeObject:channel];
    [_channels insertObject:channel atIndex:toIndex];
}
- (NSString*)_channelDir
{
    NSArray*    paths;
    NSString*   path;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@".rsschannel"];
    return path;
}

- (NSString*)_channelPath
{
    NSString*   path;
    path = [[self _channelDir] stringByAppendingPathComponent:@"rsschannel.dat"];
    return path;
}
- (void)load
{
    NSString*   channelPath;
    channelPath = [self _channelPath];
    if (!channelPath || ![[NSFileManager defaultManager] fileExistsAtPath:channelPath]) {
        return;
    }
    NSArray*    channels;
    channels = [NSKeyedUnarchiver unarchiveObjectWithFile:channelPath];
    if (!channels) {
        return;
    }
    [_channels setArray:channels];
}
- (void)save
{
    NSFileManager*  fileMgr;
    fileMgr = [NSFileManager defaultManager];
    NSString*   channelDir;
    channelDir = [self _channelDir];
    if (![fileMgr fileExistsAtPath:channelDir]) {
        NSError*    error;
        [fileMgr createDirectoryAtPath:channelDir
           withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString*   channelPath;
    channelPath = [self _channelPath];
    [NSKeyedArchiver archiveRootObject:_channels toFile:channelPath];
}
@end
