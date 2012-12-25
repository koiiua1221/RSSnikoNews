//
//  KMHTMLConnector.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMHTMLConnector.h"
#import "KMHTMLResponseParser.h"
#import "KMHTMLChannelManager.h"

NSString*   HTMLConnectorDidBeginRetriveTitle = @"HTMLConnectorDidBeginRetriveTitle";
NSString*   HTMLConnectorDidFinishRetriveTitle = @"HTMLConnectorDidFinishRetriveTitle";
NSString*   HTMLConnectorDidBeginRefreshAllChannels = @"HTMLConnectorDidBeginRefreshAllChannels";
NSString*   HTMLConnectorInProgressRefreshAllChannels = @"HTMLConnectorInProgressRefreshAllChannels";
NSString*   HTMLConnectorDidFinishRefreshAllChannels = @"HTMLConnectorDidFinishRefreshAllChannels";

@implementation KMHTMLConnector

static KMHTMLConnector*    _sharedInstance = nil;

+ (KMHTMLConnector*)sharedConnector
{
    if (!_sharedInstance) {
        _sharedInstance = [[KMHTMLConnector alloc] init];
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
    KMHTMLResponseParser* parser = [[KMHTMLResponseParser alloc]init];
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
     postNotificationName:HTMLConnectorDidBeginRetriveTitle object:self userInfo:userInfo];
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
    channels = [KMHTMLChannelManager sharedManager].channels;
    
    for (KMHTMLChannel* channel in channels) {
        KMHTMLResponseParser*  parser;
        parser = [[KMHTMLResponseParser alloc] init];
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
     postNotificationName:HTMLConnectorDidBeginRefreshAllChannels object:self userInfo:userInfo];
}
- (float)progressOfRefreshAllChannels
{
    // パーサが無い場合
    if ([_refreshAllChannelParsers count] == 0) {
        return 1.0f;
    }
    
    // 進捗の計算
    int doneCount = 0;
    for (KMHTMLResponseParser* parser in _refreshAllChannelParsers) {
        // ネットワークアクセス状態の確認
        int networkState;
        networkState = parser.networkState;
        if (networkState == HTMLNetworkStateFinished
         || networkState == HTMLNetworkStateError
         || networkState == HTMLNetworkStateCanceled)
        {
            doneCount++;
        }
    }
    
    return (float)doneCount / [_refreshAllChannelParsers count];;
}

#pragma mark -- HTMLResponseParserDelegate --
- (void)_notifyRetriveTitleStatusWithParser:(KMHTMLResponseParser*)parser
{
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    // 通知する
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HTMLConnectorDidFinishRetriveTitle object:self userInfo:userInfo];
    
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
        name = HTMLConnectorInProgressRefreshAllChannels;
    }
    else {
        name = HTMLConnectorDidFinishRefreshAllChannels;
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

- (void)parser:(KMHTMLResponseParser*)parser didReceiveResponse:(NSURLResponse*)response
{
}

- (void)parser:(KMHTMLResponseParser*)parser didReceiveData:(NSData*)data
{
}
- (void)parserDidFinishLoading:(KMHTMLResponseParser*)parser
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // パースされたアイテムに対するチャンネルを取得する
        KMHTMLChannel* channel = nil;
        for (KMHTMLChannel* ch in [KMHTMLChannelManager sharedManager].channels) {
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

- (void)parser:(KMHTMLResponseParser*)parser didFailWithError:(NSError*)error
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
- (void)parserDidCancel:(KMHTMLResponseParser*)parser
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
