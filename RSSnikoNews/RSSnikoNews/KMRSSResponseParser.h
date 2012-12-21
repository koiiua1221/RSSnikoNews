//
//  KMRSSResponseParser.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
enum {
    RSSNetworkStateNotConnected = 0,
    RSSNetworkStateInProgress,
    RSSNetworkStateFinished,
    RSSNetworkStateError,
    RSSNetworkStateCanceled,
};
@class KMRSSItem;
@class KMRSSChannel;

@interface KMRSSResponseParser : NSObject<NSXMLParserDelegate>
{
    int                 _networkState;
    NSString*           _feedUrlString;
    KMRSSChannel*       _parsedChannel;
    NSURLConnection*    _connection;
    NSMutableData*      _downloadedData;
    NSError*            _error;
    BOOL                _foundRss;
    BOOL                _isRss;
    BOOL                _isChannel;
    BOOL                _isItem;
    NSMutableString*    _buffer;
    NSMutableArray*     _items;
    KMRSSItem*          _currentItem;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) NSString* feedUrlString;
@property (retain) KMRSSChannel* parsedChannel;
@property (nonatomic, readonly) NSError* error;
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

- (void)parse;
- (void)cancel;

@end

@interface NSObject (KMRSSResponseParserDelegate)
- (void)parser:(KMRSSResponseParser*)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(KMRSSResponseParser*)parser didReceiveData:(NSData*)data;
- (void)parserDidFinishLoading:(KMRSSResponseParser*)parser;
- (void)parser:(KMRSSResponseParser*)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(KMRSSResponseParser*)parser;

@end
