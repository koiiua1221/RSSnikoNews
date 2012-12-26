//
//  KMRSSResponseParseOperation.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMRSSChannel;

@interface KMRSSResponseParseOperation : NSOperation
{
    NSString*   _feedUrlString;
    KMRSSChannel* _parsedChannel;
}
@property (nonatomic, retain) NSString* feedUrlString;
@property (retain) KMRSSChannel* parsedChannel;
@property (nonatomic, assign) id delegate;
- (void)parse;
- (void)cancel;
@end
@interface NSObject (KMRSSResponseParseOperationDelegate)
@end