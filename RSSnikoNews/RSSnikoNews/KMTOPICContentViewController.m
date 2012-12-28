//
//  KMTOPICContentViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMTOPICContentViewController.h"
#import "KMTOPICItem.h"

@interface KMTOPICContentViewController ()

@end

@implementation KMTOPICContentViewController
@synthesize item = _item;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect bounds = [[UIScreen mainScreen]bounds];
    _webView = [[UIWebView alloc]initWithFrame:bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [self _updateTOPICContent];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_updateTOPICContent
{
    if (!_webView) {
        return;
    }
    NSURL *url = [NSURL URLWithString:_item.link];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
    _webView.scalesPageToFit=YES;
    return;
}
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
