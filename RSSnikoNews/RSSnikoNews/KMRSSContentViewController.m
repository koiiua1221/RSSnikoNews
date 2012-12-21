//
//  KMRSSContentViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMRSSContentViewController.h"
#import "KMRSSItem.h"

@interface KMRSSContentViewController ()

@end

@implementation KMRSSContentViewController
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
    [self.view addSubview:_webView];
    [self _updateHTMLContent];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_updateHTMLContent
{
    // webViewを確認する
    if (!_webView) {
        return;
    }
    
    // HTMLを作成する
    NSMutableString*    html;
    html = [NSMutableString string];
    
    // ヘッダを追加する
    [html appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
    [html appendString:@"<html>"];
    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    [html appendString:@"<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"];
    [html appendString:@"<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\">"];
    [html appendString:@"<meta name=\"viewport\" content=\"minimum-scale=1.0, width=device-width, maximum-scale=1.0, user-scalable=no\" />"];
    [html appendString:@"</head>"];
    
    // bodyを追加する
    [html appendString:@"<body>"];
    
    // アイテムを追加する
    if (_item) {
        // titleを追加する
        NSString*   title;
        title = _item.title;
        if (!title) {
            title = NSLocalizedString(@"Untitled", nil);
        }
        [html appendString:@"<h2>"];
        [html appendString:title];
        [html appendString:@"</h2>"];
        
        // linkを追加する
        NSString*   link;
        link = _item.link;
        if (link) {
/*
            [html appendString:@"<h4>"];
            [html appendString:_item.link];
            [html appendString:@"</h4>"];
*/            
            [html appendFormat:@"<a href=%@ target=\"_self\">%@</a>",_item.link,_item.link];
            
        }
        
        // pubDateを追加する
        NSString*   pubDate;
        pubDate = _item.pubDate;
        if (pubDate) {
            [html appendString:@"<h4>"];
            [html appendString:_item.pubDate];
            [html appendString:@"</h4>"];
        }
        
        // itemDescriptionを追加する
        NSString*   itemDescription;
        itemDescription = _item.itemDescription;
        if (!itemDescription) {
            itemDescription = @"(No Description)";
        }
        [html appendString:@"<p>"];
        [html appendString:itemDescription];
        [html appendString:@"</p>"];
    }
    
    // bodyの終わり
    [html appendString:@"</body>"];
    
    // HTMLの終わり
    [html appendString:@"</html>"];
    
    // HTMLを読み込む
    [_webView loadHTMLString:html baseURL:nil];
}
@end
