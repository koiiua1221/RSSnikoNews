//
//  KMRSSResponseParser.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRSSResponseParser.h"
#import "KMRSSItem.h"
#import "KMRSSChannel.h"

@implementation KMRSSResponseParser

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
    _networkState = RSSNetworkStateNotConnected;
    _parsedChannel = [[KMRSSChannel alloc] init];
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
    _parsedChannel = [[KMRSSChannel alloc] init];
    
    // NSURLConnectionオブジェクトの作成
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // ネットワークアクセス状態の設定
    _networkState = RSSNetworkStateInProgress;
}
- (void)cancel
{
    [_connection cancel];
    _downloadedData = nil;
    _networkState = RSSNetworkStateCanceled;
    
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
    // フラグの初期化
    _foundRss = NO;
    _isRss = NO;
    _isChannel = NO;
    _isItem = NO;
    _currentItem = nil;
    _buffer = nil;
    [_items removeAllObjects];
    
    NSXMLParser*    parser;
    parser = [[NSXMLParser alloc] initWithData:_downloadedData];
    [parser setDelegate:self];
    
    [parser parse];
    parser = nil;
    
    if (_foundRss) {
        _networkState = RSSNetworkStateFinished;
        
        if ([_delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
            [_delegate parserDidFinishLoading:self];
        }
    }else {
        _networkState = RSSNetworkStateError;
        
        if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
            NSError*    error;
            error = [NSError errorWithDomain:@"RSS" code:0 userInfo:nil];
            [_delegate parser:self didFailWithError:nil];
        }
    }
    
    _connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _error = nil;
    _networkState = RSSNetworkStateError;
    
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:error];
    }
    
    _connection = nil;
}
#pragma mark -- NSXMLParserDelegate --
- (void)parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qualifiedName
    attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString:@"rss"]) {
        _foundRss = YES;
        _isRss = YES;
    }else if ([elementName isEqualToString:@"channel"]) {
        _isChannel = YES;
    }else if ([elementName isEqualToString:@"item"]) {
        _isItem = YES;
        KMRSSItem*    item;
        item = [[KMRSSItem alloc] init];
        [_items addObject:item];
        _currentItem = item;
    }else if ([elementName isEqualToString:@"title"]
            ||[elementName isEqualToString:@"link"]
            ||[elementName isEqualToString:@"description"]
            ||[elementName isEqualToString:@"pubDate"])
    {
        _buffer = nil;
        _buffer = [NSMutableString string];
    }
}
- (void)parser:(NSXMLParser*)parser
 didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qualifiedName
{
    if ([elementName isEqualToString:@"rss"]) {
        _isRss = NO;
    }else if ([elementName isEqualToString:@"channel"]) {
        _isChannel = NO;
    }else if ([elementName isEqualToString:@"item"]) {
        _isItem = NO;
    }else if ([elementName isEqualToString:@"title"]) {
        if (_isItem) {
            _currentItem.title = _buffer;
        }else if (_isChannel) {
            _parsedChannel.title = _buffer;
        }
    }else if ([elementName isEqualToString:@"link"]) {
        if (_isItem) {
            _currentItem.link = _buffer;
        }else if (_isChannel) {
            _parsedChannel.link = _buffer;
        }
    }else if ([elementName isEqualToString:@"description"]) {
        if (_isItem) {
            _currentItem.itemDescription = _buffer;
        }
    }else if ([elementName isEqualToString:@"pubDate"]) {
        if (_isItem) {
            _currentItem.pubDate = _buffer;
        }
    }
    _buffer = nil;
}
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    [_buffer appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser*)parser
{
    [_parsedChannel.items setArray:_items];
}

@end
