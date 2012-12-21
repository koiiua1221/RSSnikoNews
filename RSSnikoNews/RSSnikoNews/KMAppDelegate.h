//
//  KMAppDelegate.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMViewController;

@interface KMAppDelegate : UIResponder <UIApplicationDelegate>
{
  UIWindow *window;
  UIViewController *rootController_;
}

@property (strong, nonatomic) UIWindow *window;

@end
