//
//  KMTOPICResponseParser.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMTOPICResponseParser.h"
#import "KMTOPICItem.h"
#import "KMTOPICChannel.h"
#import "XPathQuery.h"

@implementation KMTOPICResponseParser

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
    _networkState = TOPICNetworkStateNotConnected;
    _parsedChannel = [[KMTOPICChannel alloc] init];
    _items = [NSMutableArray array];
    
    return self;
}
- (void)parse
{
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
    
    _downloadedData = nil;
    _downloadedData = [NSMutableData data];
    
    _parsedChannel = nil;
    _parsedChannel = [[KMTOPICChannel alloc] init];
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    _networkState = TOPICNetworkStateInProgress;
}
- (void)cancel
{
    [_connection cancel];
    _downloadedData = nil;
    _networkState = TOPICNetworkStateCanceled;
    
    if ([_delegate respondsToSelector:@selector(parserDidCancel:)]) {
        [_delegate parserDidCancel:self];
    }
    
    _connection = nil;
}
#pragma mark -- NSURLConnectionDelegate --
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if ([_delegate respondsToSelector:@selector(parser:didReceiveResponse:)]) {
        [_delegate parser:self didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_downloadedData appendData:data];
    
    if ([_delegate respondsToSelector:@selector(parser:didReceiveData:)]) {
        [_delegate parser:self didReceiveData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [_items removeAllObjects];
    
    NSArray *contents = PerformHTMLXPathQuery(_downloadedData, @"//h3/a[@href]");
    KMTOPICItem*    item;
    
    for (NSDictionary *content in contents) {
        item = [[KMTOPICItem alloc] init];
        [_items addObject:item];
        item.title = [content objectForKey:@"nodeContent"];
        NSArray *attr = [content objectForKey:@"nodeAttributeArray"];
        NSDictionary *nodeAttribute = [attr objectAtIndex:0];
        NSString *baseUrl = @"http://news.nicovideo.jp";
        item.link = [baseUrl stringByAppendingString:[nodeAttribute valueForKey:@"nodeContent"]];
    }
    [_parsedChannel.items setArray:_items];
    _networkState = TOPICNetworkStateFinished;
    
    if ([_delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
        [_delegate parserDidFinishLoading:self];
    }
    
    _connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _error = nil;
    _networkState = TOPICNetworkStateError;
    
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:error];
    }
    
    _connection = nil;
}
@end
