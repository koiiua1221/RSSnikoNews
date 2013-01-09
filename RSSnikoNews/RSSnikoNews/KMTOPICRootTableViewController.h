//
//  KMTOPICRootTableViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMTOPICChannel;

@interface KMTOPICRootTableViewController : UITableViewController<UIActionSheetDelegate>
{
    int _networkState;
    UIActionSheet*  _refreshAllChannelsSheet;
    NSMutableData*  _downloadedData;
    NSURLConnection*    _connection;
    KMTOPICChannel*       _parsedChannel;
    UIActivityIndicatorView* _indicator;
    BOOL _isDownloaded;
}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, readonly) NSData* downloadedData;
@property (retain) KMTOPICChannel* parsedChannel;
@end
