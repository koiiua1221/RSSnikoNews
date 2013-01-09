//
//  KMAppDelegate.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMAppDelegate.h"
#import "KMRootTableViewController.h"
#import "KMGenreRootTableViewController.h"
#import "KMTOPICRootTableViewController.h"

@implementation KMAppDelegate
@synthesize window;
@synthesize mainView,genreView,tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect bounds = [[UIScreen mainScreen]bounds];
    window = [[UIWindow alloc]initWithFrame:bounds];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

    mainView = [[KMRootTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    rootController_ = [[UINavigationController alloc]initWithRootViewController:mainView];
    [viewControllers addObject:rootController_];

    genreView = [[KMGenreRootTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    genreRootController_ = [[UINavigationController alloc]initWithRootViewController:genreView];
    [viewControllers addObject:genreRootController_];
    
    topicView = [[KMTOPICRootTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    topicRootController_ = [[UINavigationController alloc]initWithRootViewController:topicView];
    [viewControllers addObject:topicRootController_];
    
    tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = viewControllers;

    NSArray *tabItemAry = [tabBarController.tabBar items];
    UITabBarItem *tabItem1 = [tabItemAry objectAtIndex:0];
    tabItem1.image = [UIImage imageNamed:@"rss.png"];
    UITabBarItem *tabItem2 = [tabItemAry objectAtIndex:1];
    tabItem2.image = [UIImage imageNamed:@"genre.png"];
    
    UITabBarItem *tabItem3 = [tabItemAry objectAtIndex:2];
    tabItem3.image = [UIImage imageNamed:@"topic.png"];

    [window addSubview:tabBarController.view];

#if 1
    UITabBarController *controller = self.tabBarController;
    controller.selectedViewController = [controller.viewControllers objectAtIndex: 0];

#endif
    
    
    [window makeKeyAndVisible];

//    sleep(1.5f);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
