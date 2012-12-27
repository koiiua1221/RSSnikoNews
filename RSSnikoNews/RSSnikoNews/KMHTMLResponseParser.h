//
//  KMHTMLResponseParser.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
enum {
    HTMLNetworkStateNotConnected = 0,
    HTMLNetworkStateInProgress,
    HTMLNetworkStateFinished,
    HTMLNetworkStateError,
    HTMLNetworkStateCanceled,
};
@class KMHTMLItem;
@class KMHTMLChannel;

@interface KMHTMLResponseParser : NSObject
{
    int                 _networkState;
    NSString*           _feedUrlString;
    KMHTMLChannel*       _parsedChannel;
    NSURLConnection*    _connection;
    NSMutableData*      _downloadedData;
    NSError*            _error;
    BOOL                _foundRss;
    BOOL                _isRss;
    BOOL                _isChannel;
    BOOL                _isItem;
    NSMutableString*    _buffer;
    NSMutableArray*     _items;
    KMHTMLItem*          _currentItem;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) NSString* feedUrlString;
@property (retain) KMHTMLChannel* parsedChannel;
@property (nonatomic, readonly) NSError* error;
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

- (void)parse;
- (void)cancel;

@end

@interface NSObject (KMHTMLResponseParserDelegate)
- (void)parser:(KMHTMLResponseParser*)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(KMHTMLResponseParser*)parser didReceiveData:(NSData*)data;
- (void)parserDidFinishLoading:(KMHTMLResponseParser*)parser;
- (void)parser:(KMHTMLResponseParser*)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(KMHTMLResponseParser*)parser;

@end
