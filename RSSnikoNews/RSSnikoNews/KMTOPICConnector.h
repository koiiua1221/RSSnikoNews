//
//  KMTOPICConnector.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString*    TOPICConnectorDidBeginRetriveTitle;
extern NSString*    TOPICConnectorDidFinishRetriveTitle;
extern NSString*    TOPICConnectorDidBeginRefreshAllChannels;
extern NSString*    TOPICConnectorInProgressRefreshAllChannels;
extern NSString*    TOPICConnectorDidFinishRefreshAllChannels;

@interface KMTOPICConnector : NSObject
{
    NSMutableArray* _retrieveTitleParsers;
    NSMutableArray* _refreshAllChannelParsers;
}
@property (nonatomic, readonly, getter=isNetworkAccessing) BOOL networkAccessing;
+ (KMTOPICConnector*)sharedConnector;
- (void)retrieveTitleWithUrlString:(NSString*)urlString;
- (BOOL)isRefreshingAllChannels;
- (void)refreshAllChannels;
- (float)progressOfRefreshAllChannels;

@end
