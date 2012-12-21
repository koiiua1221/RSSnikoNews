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
#import "KMRSSResponseParser.h"

@implementation KMRSSResponseParser

@synthesize networkState = _networkState;
@synthesize feedUrlString = _feedUrlString;
@synthesize parsedChannel = _parsedChannel;
@synthesize error = _error;
@synthesize delegate = _delegate;

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
    // サブスレッドを作成する
    [NSThread detachNewThreadSelector:@selector(_parse) toTarget:self withObject:nil];
}
- (void)_parse
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
    
    NSData*         data;
    NSURLResponse*  response;
    NSError*        error = nil;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        _networkState = RSSNetworkStateError;
        [self performSelectorOnMainThread:@selector(_notifyParserDidFailWithError:)
                               withObject:error waitUntilDone:YES];
    }
    else {
        _networkState = RSSNetworkStateFinished;
        
        NSXMLParser*    parser;
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        [parser parse];
        parser = nil;
        [self performSelectorOnMainThread:@selector(_notifyParserDidFinishLoading)
                               withObject:error waitUntilDone:YES];
    }
}
- (void)_notifyParserDidFinishLoading
{
    if ([_delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
        [_delegate parserDidFinishLoading:self];
    }
}
- (void)_notifyParserDidFailWithError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:error];
    }
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
    }
    else if ([elementName isEqualToString:@"channel"]) {
        _isChannel = YES;
    }
    else if ([elementName isEqualToString:@"item"]) {
        _isItem = YES;
        KMRSSItem*    item;
        item = [[KMRSSItem alloc] init];
        [_items addObject:item];
        _currentItem = item;
    }
    else if ([elementName isEqualToString:@"title"] ||
             [elementName isEqualToString:@"link"] ||
             [elementName isEqualToString:@"description"] ||
             [elementName isEqualToString:@"pubDate"])
    {
        // バッファの作成
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
    }
    else if ([elementName isEqualToString:@"channel"]) {
        _isChannel = NO;
    }
    else if ([elementName isEqualToString:@"item"]) {
        _isItem = NO;
    }
    else if ([elementName isEqualToString:@"title"]) {
        if (_isItem) {
            _currentItem.title = _buffer;
        }
        else if (_isChannel) {
            _parsedChannel.title = _buffer;
        }
    }
    else if ([elementName isEqualToString:@"link"]) {
        if (_isItem) {
            _currentItem.link = _buffer;
        }
        else if (_isChannel) {
            _parsedChannel.link = _buffer;
        }
    }
    else if ([elementName isEqualToString:@"description"]) {
        if (_isItem) {
            _currentItem.itemDescription = _buffer;
        }
    }
    else if ([elementName isEqualToString:@"pubDate"]) {
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
