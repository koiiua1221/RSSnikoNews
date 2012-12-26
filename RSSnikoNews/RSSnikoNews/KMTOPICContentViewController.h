//
//  KMTOPICContentViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMTOPICItem;

@interface KMTOPICContentViewController : UIViewController
{
    KMTOPICItem*    _item;
    UIWebView* _webView;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, retain) KMTOPICItem* item;
@property (unsafe_unretained) id delegate;

@end
