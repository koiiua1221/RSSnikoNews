//
//  KMHTMLItemListTableViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMHTMLChannel;

@interface KMHTMLItemListTableViewController : UITableViewController
{
    KMHTMLChannel* _channel;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, retain) KMHTMLChannel* channel;
@property (unsafe_unretained) id delegate;
@end
