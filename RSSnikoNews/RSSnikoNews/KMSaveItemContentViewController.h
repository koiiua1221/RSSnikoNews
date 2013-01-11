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
    KMSaveItem*    _item;
    UIWebView* _webView;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, retain) KMSaveItem* item;
@property (unsafe_unretained) id delegate;

@end
