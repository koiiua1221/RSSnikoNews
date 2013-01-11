//
//  KMRSSConnector.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRSSConnector.h"
#import "KMRSSResponseParser.h"
#import "KMRSSChannelManager.h"

NSString*   RSSConnectorDidBeginRetriveTitle = @"RSSConnectorDidBeginRetriveTitle";
NSString*   RSSConnectorDidFinishRetriveTitle = @"RSSConnectorDidFinishRetriveTitle";
NSString*   RSSConnectorDidBeginRefreshAllChannels = @"RSSConnectorDidBeginRefreshAllChannels";
NSString*   RSSConnectorInProgressRefreshAllChannels = @"RSSConnectorInProgressRefreshAllChannels";
NSString*   RSSConnectorDidFinishRefreshAllChannels = @"RSSConnectorDidFinishRefreshAllChannels";

@implementation KMRSSConnector

static KMRSSConnector*    _sharedInstance = nil;

+ (KMRSSConnector*)sharedConnector
{
    if (!_sharedInstance) {
        _sharedInstance = [[KMRSSConnector alloc] init];
    }
    return _sharedInstance;
}
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _retrieveTitleParsers = [NSMutableArray array];
    _refreshAllChannelParsers = [NSMutableArray array];
    return self;
}
- (BOOL)isNetworkAccessing
{
    return [_retrieveTitleParsers count] > 0 ||
    [_refreshAllChannelParsers count] > 0;
}
- (void)retrieveTitleWithUrlString:(NSString*)urlString
{
    KMRSSResponseParser* parser = [[KMRSSResponseParser alloc]init];
    parser.feedUrlString = urlString;
    parser.delegate = self;
    [parser parse];
    
    [_retrieveTitleParsers addObject:parser];
    BOOL    networkAccessing;
    networkAccessing = self.networkAccessing;
    if (networkAccessing != self.networkAccessing) {
        [self willChangeValueForKey:@"networkAccessing"];
        [self didChangeValueForKey:@"networkAccessing"];
    }
    
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:RSSConnectorDidBeginRetriveTitle object:self userInfo:userInfo];
}
- (BOOL)isRefreshingAllChannels
{
    return [_refreshAllChannelParsers count] > 0;
}
- (void)refreshAllChannels
{
    if ([self isRefreshingAllChannels]) {
        return;
    }
    BOOL    networkAccessing;
    networkAccessing = self.networkAccessing;
    
    NSArray*    channels;
    channels = [KMRSSChannelManager sharedManager].channels;
    
    for (KMRSSChannel* channel in channels) {
        KMRSSResponseParser*  parser;
        parser = [[KMRSSResponseParser alloc] init];
        parser.feedUrlString = channel.feedUrlString;
        parser.delegate = self;
        [parser parse];
        [_refreshAllChannelParsers addObject:parser];
    }
    if (networkAccessing != self.networkAccessing) {
        [self willChangeValueForKey:@"networkAccessing"];
        [self didChangeValueForKey:@"networkAccessing"];
    }
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:RSSConnectorDidBeginRefreshAllChannels object:self userInfo:userInfo];
}
- (float)progressOfRefreshAllChannels
{
    if ([_refreshAllChannelParsers count] == 0) {
        return 1.0f;
    }
    
    int doneCount = 0;
    for (KMRSSResponseParser* parser in _refreshAllChannelParsers) {
        int networkState;
        networkState = parser.networkState;
        if (networkState == RSSNetworkStateFinished ||
            networkState == RSSNetworkStateError ||
            networkState == RSSNetworkStateCanceled)
        {
            doneCount++;
        }
    }
    
    return (float)doneCount / [_refreshAllChannelParsers count];;
}
- (void)cancelRefreshAllChannels
{
    for (KMRSSResponseParser* parser in _refreshAllChannelParsers) {
        [parser cancel];
        if ([_refreshAllChannelParsers count]==0) {
            break;
        }
    }
    
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:RSSConnectorDidFinishRefreshAllChannels
     object:self userInfo:userInfo];
    
    [self willChangeValueForKey:@"networkAccessing"];
    [_refreshAllChannelParsers removeAllObjects];
    [self didChangeValueForKey:@"networkAccessing"];
}
#pragma mark -- RSSResponseParserDelegate --
- (void)_notifyRetriveTitleStatusWithParser:(KMRSSResponseParser*)parser
{
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:RSSConnectorDidFinishRetriveTitle object:self userInfo:userInfo];
    
    [self willChangeValueForKey:@"networkAccessing"];
    [_retrieveTitleParsers removeObject:parser];
    [self didChangeValueForKey:@"networkAccessing"];
}
- (void)_notifyRefreshAllChannelStatus
{
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    float   progress;
    progress = [self progressOfRefreshAllChannels];
    
    NSString*   name;
    if (progress < 1.0f) {
        name = RSSConnectorInProgressRefreshAllChannels;
    }
    else {
        name = RSSConnectorDidFinishRefreshAllChannels;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name object:self userInfo:userInfo];
    
    if (progress == 1.0f) {
        [self willChangeValueForKey:@"networkAccessing"];
        [_refreshAllChannelParsers removeAllObjects];
        [self didChangeValueForKey:@"networkAccessing"];
    }
}

- (void)parser:(KMRSSResponseParser*)parser didReceiveResponse:(NSURLResponse*)response
{
}

- (void)parser:(KMRSSResponseParser*)parser didReceiveData:(NSData*)data
{
}
- (void)parserDidFinishLoading:(KMRSSResponseParser*)parser
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        KMRSSChannel* channel = nil;
        for (KMRSSChannel* ch in [KMRSSChannelManager sharedManager].channels) {
            if ([ch.feedUrlString isEqualToString:parser.feedUrlString]) {
                channel = ch;
                
                break;
            }
        }
        [channel.items setArray:parser.parsedChannel.items];
        [self _notifyRefreshAllChannelStatus];
    }
}

- (void)parser:(KMRSSResponseParser*)parser didFailWithError:(NSError*)error
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        [self _notifyRefreshAllChannelStatus];
    }
}
- (void)parserDidCancel:(KMRSSResponseParser*)parser
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        [self _notifyRefreshAllChannelStatus];
    }
}
@end
