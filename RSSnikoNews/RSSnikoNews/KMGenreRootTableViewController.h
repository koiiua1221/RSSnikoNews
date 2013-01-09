//
//  KMRootTableViewController.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMGenreRootTableViewController : UITableViewController<UIActionSheetDelegate>
{
    UIActionSheet*  _refreshAllChannelsSheet;
    BOOL _isDownloaded;
}
@end
