//
//  KMContentTwitterViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2013/01/16.
//  Copyright (c) 2013年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSaveItem;

@interface KMContentTwitterViewController : UIViewController<UIWebViewDelegate,UITableViewDelegate>
{
    KMSaveItem* _item;
    UIWebView* _webTwitterView;
    UITableView *_tableView;
    NSArray *_tweets;
    NSArray *_tweetUsers;
    NSMutableArray *tweetImageUrls;
    NSMutableArray *_tweetImages;
    NSMutableData* _downloadedData;
    UILabel* _topicTitle;
    NSURLConnection* _connection;
    int _networkState;
    CGRect bounds;
    CGFloat height;
    id __unsafe_unretained _delegate;

}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) KMSaveItem* item;
@property (unsafe_unretained) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

@end
