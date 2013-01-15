//
//  KMSaveItemContentViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMSaveItem;

@interface KMSaveItemContentViewController : UIViewController<UIWebViewDelegate>
{
    KMSaveItem* _item;
    UIWebView* _webView;
    UIWebView* _webTwitterView;
    NSMutableData* _downloadedData;
    NSURLConnection* _connection;
    int _networkState;
    NSArray *_writings;
    NSArray *_tweets;
    NSArray *_imgs;
    id __unsafe_unretained _delegate;
}
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) KMSaveItem* item;
@property (unsafe_unretained) id delegate;
@property (nonatomic, readonly) NSData* downloadedData;

@end
