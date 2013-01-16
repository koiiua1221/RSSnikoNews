//
//  KMContentViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSaveItem;

@interface KMContentViewController : UIViewController<UIWebViewDelegate>
{
    KMSaveItem* _item;
    UIWebView* _webView;
    UIWebView* _webTwitterView;
    UILabel* _topicTitle;
    NSMutableData* _downloadedData;
    NSURLConnection* _connection;
    int _networkState;
    NSArray *_writings;
    NSArray *_tweets;
    NSArray *_imgs;
    CGRect bounds;
    CGFloat height;
    id __unsafe_unretained _delegate;
}
- (id)initWithSaveButton;

@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) KMSaveItem* item;
@property (unsafe_unretained) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

@end
