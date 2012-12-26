//
//  KMTOPICItemListTableViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/21.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMTOPICChannel;

@interface KMTOPICItemListTableViewController : UITableViewController
{
    KMTOPICChannel* _channel;
    id  __unsafe_unretained _delegate;
}
@property (nonatomic, retain) KMTOPICChannel* channel;
@property (unsafe_unretained) id delegate;
@end
