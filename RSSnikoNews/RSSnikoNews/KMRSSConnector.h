//
//  KMRSSConnector.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString*    RSSConnectorDidBeginRetriveTitle;
extern NSString*    RSSConnectorDidFinishRetriveTitle;
extern NSString*    RSSConnectorDidBeginRefreshAllChannels;
extern NSString*    RSSConnectorInProgressRefreshAllChannels;
extern NSString*    RSSConnectorDidFinishRefreshAllChannels;

@interface KMRSSConnector : NSObject
{
    NSMutableArray* _retrieveTitleParsers;
    NSMutableArray* _refreshAllChannelParsers;
}
@property (nonatomic, readonly, getter=isNetworkAccessing) BOOL networkAccessing;
+ (KMRSSConnector*)sharedConnector;
- (void)retrieveTitleWithUrlString:(NSString*)urlString;
- (BOOL)isRefreshingAllChannels;
- (void)refreshAllChannels;
- (float)progressOfRefreshAllChannels;

@end
