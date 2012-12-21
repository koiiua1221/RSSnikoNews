//
//  KMRSSResponseParseOperation.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRSSResponseParseOperation.h"

@implementation KMRSSResponseParseOperation
@synthesize feedUrlString = _feedUrlString;
@synthesize parsedChannel = _parsedChannel;
- (void)start
{
    // Create request
    NSURLRequest*   request = nil;
    if (_parsedChannel) {
        NSURL*  url;
        url = [NSURL URLWithString:_channel.feedUrlString];
        if (url) {
            request = [NSURLRequest requestWithURL:url];
        }
    }
    
    if (!request) {
        return;
    }
    
    // Create connection
    NSData*         data;
    NSURLResponse*  response;
    NSError*        error = nil;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Notify to delegate
        //[self performSelectorOnMainThread:@selector(_notifyParserDidFailWithError:)
        //        withObject:error waitUntilDone:YES];
    }
    else {
        // Create XML parser
        NSXMLParser*    parser;
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        
        // Parse XML
        [parser parse];
        
        // Notify to delegate
        //[self performSelectorOnMainThread:@selector(_notifyParserDidFinishLoading)
        //        withObject:error waitUntilDone:YES];
    }
    
    // Release autorelease pool
    pool = nil;
}

@end
