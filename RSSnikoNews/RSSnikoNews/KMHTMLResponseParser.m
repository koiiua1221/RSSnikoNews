//
//  KMHTMLResponseParser.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMHTMLResponseParser.h"
#import "KMHTMLItem.h"
#import "KMHTMLChannel.h"
#import "XPathQuery.h"

@implementation KMHTMLResponseParser

@synthesize networkState = _networkState;
@synthesize feedUrlString = _feedUrlString;
@synthesize parsedChannel = _parsedChannel;
@synthesize error = _error;
@synthesize delegate = _delegate;
@synthesize downloadedData = _downloadedData;

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _networkState = HTMLNetworkStateNotConnected;
    _parsedChannel = [[KMHTMLChannel alloc] init];
    _items = [NSMutableArray array];
    
    return self;
}
- (void)parse
{
    // リクエストの作成
    NSURLRequest*   request = nil;
    if (_feedUrlString) {
        NSURL*  url;
        url = [NSURL URLWithString:_feedUrlString];
        if (url) {
            request = [NSURLRequest requestWithURL:url];
        }
    }
    
    if (!request) {
        return;
    }
    
    // データバッファの作成
    _downloadedData = nil;
    _downloadedData = [NSMutableData data];
    
    // パース済みチャンネルを作成する
    _parsedChannel = nil;
    _parsedChannel = [[KMHTMLChannel alloc] init];
    
    // NSURLConnectionオブジェクトの作成
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // ネットワークアクセス状態の設定
    _networkState = HTMLNetworkStateInProgress;
}
- (void)cancel
{
    [_connection cancel];
    _downloadedData = nil;
    _networkState = HTMLNetworkStateCanceled;
    
    if ([_delegate respondsToSelector:@selector(parserDidCancel:)]) {
        [_delegate parserDidCancel:self];
    }
    
    _connection = nil;
}
#pragma mark -- NSURLConnectionDelegate --
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parser:didReceiveResponse:)]) {
        [_delegate parser:self didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    // ダウンロード済みデータを追加
    [_downloadedData appendData:data];
    
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parser:didReceiveData:)]) {
        [_delegate parser:self didReceiveData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [_items removeAllObjects];
    
    NSArray *contents = PerformHTMLXPathQuery(_downloadedData, @"//h3/a[@href]");
    KMHTMLItem*    item;
    
    for (NSDictionary *content in contents) {
        item = [[KMHTMLItem alloc] init];
        [_items addObject:item];
        item.title = [content objectForKey:@"nodeContent"];
        NSArray *attr = [content objectForKey:@"nodeAttributeArray"];
        NSDictionary *nodeAttribute = [attr objectAtIndex:0];
        NSString *baseUrl = @"http://news.nicovideo.jp";
        item.link = [baseUrl stringByAppendingString:[nodeAttribute valueForKey:@"nodeContent"]];
    }
    [_parsedChannel.items setArray:_items];
    _networkState = HTMLNetworkStateFinished;
    
    if ([_delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
        [_delegate parserDidFinishLoading:self];
    }
    
    _connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _error = nil;
    _networkState = HTMLNetworkStateError;
    
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:error];
    }
    
    _connection = nil;
}
@end
