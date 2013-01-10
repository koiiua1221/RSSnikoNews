//
//  KMHTMLConnector.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString*    HTMLConnectorDidBeginRetriveTitle;
extern NSString*    HTMLConnectorDidFinishRetriveTitle;
extern NSString*    HTMLConnectorDidBeginRefreshAllChannels;
extern NSString*    HTMLConnectorInProgressRefreshAllChannels;
extern NSString*    HTMLConnectorDidFinishRefreshAllChannels;

@interface KMHTMLConnector : NSObject
{
    NSMutableArray* _retrieveTitleParsers;
    NSMutableArray* _refreshAllChannelParsers;
}
@property (nonatomic, readonly, getter=isNetworkAccessing) BOOL networkAccessing;
+ (KMHTMLConnector*)sharedConnector;
- (void)retrieveTitleWithUrlString:(NSString*)urlString;
- (BOOL)isRefreshingAllChannels;
- (void)refreshAllChannels;
- (float)progressOfRefreshAllChannels;
- (void)cancelRefreshAllChannels;
@end
