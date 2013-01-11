//
//  KMAppDelegate.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMViewController;
@class KMRootTableViewController;
@class KMGenreRootTableViewController;
@class KMTOPICRootTableViewController;
@class KMSaveItemTableViewController;
@class KMAboutViewController;

@interface KMAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
    UIViewController *rootController_;
    UIViewController *genreRootController_;
    UIViewController *topicRootController_;
    UIViewController *saveItemRootController_;
    UIViewController *aboutRootController_;
    UITabBarController *tabBarController;
    KMRootTableViewController *mainView;
    KMGenreRootTableViewController *genreView;
    KMTOPICRootTableViewController *topicView;
    KMSaveItemTableViewController *saveItemView;
    KMAboutViewController *aboutView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) KMRootTableViewController *mainView;
@property (nonatomic, retain) KMGenreRootTableViewController *genreView;
@property (nonatomic, retain) KMTOPICRootTableViewController *topicView;
@property (nonatomic, retain) KMSaveItemTableViewController *saveItemView;
@property (nonatomic, retain) KMAboutViewController *aboutView;

@end
