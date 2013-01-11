//
//  KMHTMLContentViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMHTMLContentViewController.h"
#import "KMHTMLItem.h"
#import "KMSaveItemManager.h"
#import "KMSaveItem.h"

@interface KMHTMLContentViewController ()

@end

@implementation KMHTMLContentViewController
@synthesize item = _item;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItem)];
    self.navigationItem.rightBarButtonItem = saveButton;

    CGRect bounds = [[UIScreen mainScreen]bounds];
    _webView = [[UIWebView alloc]initWithFrame:bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [self _updateHTMLContent];
}
- (void)viewWillDisappear:(BOOL)animated
{
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)saveItem
{
    KMSaveItem *saveItem = [[KMSaveItem alloc]init];
    saveItem.feedUrlString = _item.link;
    saveItem.title = _item.title;
    [[KMSaveItemManager sharedManager] addSaveItem:saveItem];
    [[KMSaveItemManager sharedManager] save];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完了メッセージ"
                                                    message:@"記事を保存しました。"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)_updateHTMLContent
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

-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
