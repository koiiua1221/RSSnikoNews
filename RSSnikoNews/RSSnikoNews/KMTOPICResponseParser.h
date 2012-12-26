//
//  KMTOPICResponseParser.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>
enum {
    TOPICNetworkStateNotConnected = 0,
    TOPICNetworkStateInProgress,
    TOPICNetworkStateFinished,
    TOPICNetworkStateError,
    TOPICNetworkStateCanceled,
};
@class KMTOPICItem;
@class KMTOPICChannel;

@interface KMTOPICResponseParser : NSObject<NSXMLParserDelegate>
{
    int                 _networkState;
    NSString*           _feedUrlString;
    KMTOPICChannel*       _parsedChannel;
    NSURLConnection*    _connection;
    NSMutableData*      _downloadedData;
    NSError*            _error;
    BOOL                _foundRss;
    BOOL                _isRss;
    BOOL                _isChannel;
    BOOL                _isItem;
    NSMutableString*    _buffer;
    NSMutableArray*     _items;
    KMTOPICItem*          _currentItem;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) NSString* feedUrlString;
@property (retain) KMTOPICChannel* parsedChannel;
@property (nonatomic, readonly) NSError* error;
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

- (void)parse;
- (void)cancel;

@end

@interface NSObject (KMTOPICResponseParserDelegate)
- (void)parser:(KMTOPICResponseParser*)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(KMTOPICResponseParser*)parser didReceiveData:(NSData*)data;
- (void)parserDidFinishLoading:(KMTOPICResponseParser*)parser;
- (void)parser:(KMTOPICResponseParser*)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(KMTOPICResponseParser*)parser;

@end
