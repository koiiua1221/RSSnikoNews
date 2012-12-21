//
//  KMRootTableViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum tagTypes
{
    topics,
    hotRanking,
    dailyRanking,
    weeklyRanking,
    ncn,
    maxnum
}nikoRsschannel;
@interface KMRootTableViewController : UITableViewController<UIActionSheetDelegate>
{
    UIActionSheet*  _refreshAllChannelsSheet;
}
@end
