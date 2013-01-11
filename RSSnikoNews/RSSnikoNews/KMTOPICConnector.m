//
//  KMTOPICConnector.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMTOPICConnector.h"
#import "KMTOPICResponseParser.h"
#import "KMTOPICChannelManager.h"

NSString*   TOPICConnectorDidBeginRetriveTitle = @"TOPICConnectorDidBeginRetriveTitle";
NSString*   TOPICConnectorDidFinishRetriveTitle = @"TOPICConnectorDidFinishRetriveTitle";
NSString*   TOPICConnectorDidBeginRefreshAllChannels = @"TOPICConnectorDidBeginRefreshAllChannels";
NSString*   TOPICConnectorInProgressRefreshAllChannels = @"TOPICConnectorInProgressRefreshAllChannels";
NSString*   TOPICConnectorDidFinishRefreshAllChannels = @"TOPICConnectorDidFinishRefreshAllChannels";

@implementation KMTOPICConnector

static KMTOPICConnector*    _sharedInstance = nil;

+ (KMTOPICConnector*)sharedConnector
{
    if (!_sharedInstance) {
        _sharedInstance = [[KMTOPICConnector alloc] init];
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
    KMTOPICResponseParser* parser = [[KMTOPICResponseParser alloc]init];
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
     postNotificationName:TOPICConnectorDidBeginRetriveTitle object:self userInfo:userInfo];
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
    channels = [KMTOPICChannelManager sharedManager].channels;
    
    for (KMTOPICChannel* channel in channels) {
        KMTOPICResponseParser*  parser;
        parser = [[KMTOPICResponseParser alloc] init];
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
     postNotificationName:TOPICConnectorDidBeginRefreshAllChannels object:self userInfo:userInfo];
}
- (float)progressOfRefreshAllChannels
{
    if ([_refreshAllChannelParsers count] == 0) {
        return 1.0f;
    }
    
    // 進捗の計算
    int doneCount = 0;
    for (KMTOPICResponseParser* parser in _refreshAllChannelParsers) {
        int networkState;
        networkState = parser.networkState;
        if (networkState == TOPICNetworkStateFinished
         || networkState == TOPICNetworkStateError
         || networkState == TOPICNetworkStateCanceled)
        {
            doneCount++;
        }
    }
    
    return (float)doneCount / [_refreshAllChannelParsers count];;
}

#pragma mark -- TOPICResponseParserDelegate --
- (void)_notifyRetriveTitleStatusWithParser:(KMTOPICResponseParser*)parser
{
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:TOPICConnectorDidFinishRetriveTitle object:self userInfo:userInfo];
    
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
        name = TOPICConnectorInProgressRefreshAllChannels;
    }
    else {
        name = TOPICConnectorDidFinishRefreshAllChannels;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name object:self userInfo:userInfo];
    
    if (progress == 1.0f) {
        [self willChangeValueForKey:@"networkAccessing"];
        [_refreshAllChannelParsers removeAllObjects];
        [self didChangeValueForKey:@"networkAccessing"];
    }
}

- (void)parser:(KMTOPICResponseParser*)parser didReceiveResponse:(NSURLResponse*)response
{
}

- (void)parser:(KMTOPICResponseParser*)parser didReceiveData:(NSData*)data
{
}
- (void)parserDidFinishLoading:(KMTOPICResponseParser*)parser
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        KMTOPICChannel* channel = nil;
        for (KMTOPICChannel* ch in [KMTOPICChannelManager sharedManager].channels) {
            if ([ch.feedUrlString isEqualToString:parser.feedUrlString]) {
                channel = ch;
                break;
            }
        }
        [channel.items setArray:parser.parsedChannel.items];
        [self _notifyRefreshAllChannelStatus];
    }
}

- (void)parser:(KMTOPICResponseParser*)parser didFailWithError:(NSError*)error
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        [self _notifyRefreshAllChannelStatus];
    }
}
- (void)parserDidCancel:(KMTOPICResponseParser*)parser
{
    if ([_retrieveTitleParsers containsObject:parser]) {
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        [self _notifyRefreshAllChannelStatus];
    }
}
@end
