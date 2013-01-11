//
//  KMAboutViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2013/01/11.
//  Copyright (c) 2013年 KoujiMiura. All rights reserved.
//

#import "KMAboutViewController.h"

@interface KMAboutViewController ()

@end

@implementation KMAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"本アプリについて";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor  = [UIColor blackColor];
    CGRect bounds = [[UIScreen mainScreen]bounds];
    _webView = [[UIWebView alloc]initWithFrame:bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSString *aboutPath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:aboutPath]]];
    _webView.scalesPageToFit=YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
