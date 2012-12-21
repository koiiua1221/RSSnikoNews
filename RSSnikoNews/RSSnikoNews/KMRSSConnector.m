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
    // パーサが無い場合
    if ([_refreshAllChannelParsers count] == 0) {
        return 1.0f;
    }
    
    // 進捗の計算
    int doneCount = 0;
    for (KMRSSResponseParser* parser in _refreshAllChannelParsers) {
        // ネットワークアクセス状態の確認
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

#pragma mark -- RSSResponseParserDelegate --
- (void)_notifyRetriveTitleStatusWithParser:(KMRSSResponseParser*)parser
{
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    // 通知する
    [[NSNotificationCenter defaultCenter]
     postNotificationName:RSSConnectorDidFinishRetriveTitle object:self userInfo:userInfo];
    
    // networkAccessingの値の変更を通知する
    [self willChangeValueForKey:@"networkAccessing"];
    [_retrieveTitleParsers removeObject:parser];
    [self didChangeValueForKey:@"networkAccessing"];
}
- (void)_notifyRefreshAllChannelStatus
{
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    // 進捗の取得
    float   progress;
    progress = [self progressOfRefreshAllChannels];
    
    // 通知
    NSString*   name;
    if (progress < 1.0f) {
        name = RSSConnectorInProgressRefreshAllChannels;
    }
    else {
        name = RSSConnectorDidFinishRefreshAllChannels;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name object:self userInfo:userInfo];
    
    // For did finish
    if (progress == 1.0f) {
        // networkAccessingの値の変更を通知する
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
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // パースされたアイテムに対するチャンネルを取得する
        KMRSSChannel* channel = nil;
        for (KMRSSChannel* ch in [KMRSSChannelManager sharedManager].channels) {
            if ([ch.feedUrlString isEqualToString:parser.feedUrlString]) {
                channel = ch;
                
                break;
            }
        }
        
        // パースされたアイテムを設定する
        [channel.items setArray:parser.parsedChannel.items];
        
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}

- (void)parser:(KMRSSResponseParser*)parser didFailWithError:(NSError*)error
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}
- (void)parserDidCancel:(KMRSSResponseParser*)parser
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}
@end
