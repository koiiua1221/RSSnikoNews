//
//  KMRSSItemListControllerViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMRSSChannel;

@interface KMRSSItemListTableViewController : UITableViewController
{
    KMRSSChannel* _channel;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, retain) KMRSSChannel* channel;
@property (unsafe_unretained) id delegate;
@end
