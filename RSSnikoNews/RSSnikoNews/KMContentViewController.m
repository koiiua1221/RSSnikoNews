//
//  KMContentViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMContentViewController.h"
#import "KMSaveItemManager.h"
#import "KMSaveItem.h"
#import "XPathQuery.h"
#import <QuartzCore/QuartzCore.h>
@interface KMContentViewController ()

@end

@implementation KMContentViewController
@synthesize item = _item;
@synthesize delegate = _delegate;
@synthesize downloadedData = _downloadedData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithSaveButton
{
    self = [self init];
    if (self) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItem)];
        self.navigationItem.rightBarButtonItem = saveButton;

    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:@"記事"];
    _topicTitle.text=_item.title;
    [_topicTitle setAdjustsFontSizeToFitWidth:true];
    [_topicTitle setAdjustsLetterSpacingToFitWidth:true];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    bounds = [[UIScreen mainScreen]bounds];

    height = bounds.size.height - self.tabBarController.tabBar.bounds.size.height-self.navigationController.navigationBar.bounds.size.height;

    _topicTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, height*0.1)];
    _topicTitle.textAlignment=UITextAlignmentCenter;
    _topicTitle.textColor=[UIColor whiteColor];
    _topicTitle.numberOfLines=2;
    _topicTitle.lineBreakMode=UILineBreakModeWordWrap;
    [[_topicTitle layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[_topicTitle layer] setBorderWidth:2];
    _topicTitle.backgroundColor=[UIColor darkGrayColor];
    [self.view addSubview:_topicTitle];

    _webView = [[UIWebView alloc]init];
    _webView.delegate = self;
    [[_webView layer] setBorderColor:[[UIColor blackColor] CGColor] ];
    [[_webView layer] setBorderWidth:2];
    [self.view addSubview:_webView];
    _webTwitterView = [[UIWebView alloc]init];
    _webTwitterView.delegate = self;
    [self.view addSubview:_webTwitterView];
    [[_webTwitterView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[_webTwitterView layer] setBorderWidth:1.5];
    [self parse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewWillDisappear:(BOOL)animated
{
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)parse
{
    NSURLRequest*   request = nil;
    NSURL*  url;
    url = [NSURL URLWithString:_item.link];
    request = [NSURLRequest requestWithURL:url];
    
    if (!request) {
        return;
    }
    _downloadedData = nil;
    _downloadedData = [NSMutableData data];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
#pragma mark -- NSURLConnectionDelegate --
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_downloadedData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    
//    NSArray *titles = PerformHTMLXPathQuery(_downloadedData, @"//div/ul/li/span[@class='topics-tab-text']");
    _writings = PerformHTMLXPathQuery(_downloadedData, @"//div[@class='body-text']/p");
    for (NSDictionary *writing in _writings) {
        NSLog([writing objectForKey:@"nodeContent"]);
    }
    _tweets = PerformHTMLXPathQuery(_downloadedData, @"//div[@id='twitter-remains']/ul/li/p[@class='user-description']");
    for (NSDictionary *tweet in _tweets) {
        NSLog([tweet objectForKey:@"nodeContent"]);
    }
    
    _imgs = PerformHTMLXPathQuery(_downloadedData, @"//img[@id='image-view-area']");
    
    if ([_tweets count]==0) {
        _webView.frame=CGRectMake(bounds.origin.x, height*0.1,bounds.size.width , height*0.9);
        _webTwitterView.frame=CGRectMake(bounds.origin.x, height*0.6, 0, 0);
        [self _updateHTMLContents];
    }else{
        _webView.frame=CGRectMake(bounds.origin.x, height*0.1,bounds.size.width , height*0.5);
        _webTwitterView.frame=CGRectMake(bounds.origin.x, height*0.6, bounds.size.width , height*0.4);
        [self _updateHTMLContents];
        [self _updateTwitterContents];
    }
}
- (void)_updateHTMLContents
{
    if (!_webView) {
        return;
    }
    
    NSMutableString*    html;
    html = [NSMutableString string];
    
    [html appendString:@"<!DOCTYPE html>"];
    [html appendString:@"<html>"];
    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    [html appendString:@"<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"];
    [html appendString:@"<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\">"];
    [html appendString:@"<meta name=\"viewport\" content=\"minimum-scale=1.0, width=device-width, maximum-scale=1.0, user-scalable=no\" />"];
    [html appendString:@"</head>"];
    [html appendString:@"<body>"];
    
    if ([_imgs count]!=0) {
        [html appendString:@"<img src=\""];
        [html appendString:[[[[_imgs objectAtIndex:0]valueForKey:@"nodeAttributeArray"] objectAtIndex:1] objectForKey:@"nodeContent"]];
        [html appendString:@"\" align=right >"];
    }
    if ([_writings count]!=0) {
        [html appendString:@"<div class=\"body-text\">"];
        for (NSDictionary *writing in _writings) {
            [html appendString:@"<p>"];
            if ([writing objectForKey:@"nodeContent"]) {
                [html appendString:[writing objectForKey:@"nodeContent"]];
                [html appendString:@"</p>"];
            }
        }
        [html appendString:@"</div>"];
    }
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];

    [_webView loadHTMLString:html baseURL:nil];
    _webView.scalesPageToFit=YES;
}
- (void)_updateTwitterContents
{
    if (!_webTwitterView) {
        return;
    }
    
    NSMutableString*    html;
    html = [NSMutableString string];
    
    [html appendString:@"<!DOCTYPE html>"];
    [html appendString:@"<html>"];
    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    [html appendString:@"<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"];
    [html appendString:@"<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\">"];
    [html appendString:@"<meta name=\"viewport\" content=\"minimum-scale=1.0, width=device-width, maximum-scale=1.0, user-scalable=no\" />"];
    [html appendString:@"</head>"];
    [html appendString:@"<body>"];
    if ([_tweets count]!=0) {
        [html appendString:@"<div class=\"tweets-text\">"];
        [html appendString:@"<table border width=310  align=center>"];
        [html appendString:@"<tr>"];
        [html appendString:@"<th><font size=3>Twitterの反応</font></th>"];
        [html appendString:@"</tr>"];
        for (NSDictionary *tweet in _tweets) {
            if ([tweet objectForKey:@"nodeContent"]) {
                [html appendString:@"<tr>"];
                [html appendString:@"<td width=310>"];
                [html appendString:@"<font size=3>"];
                [html appendString:[tweet objectForKey:@"nodeContent"]];
                [html appendString:@"</font>"];
                [html appendString:@"</td>"];
                [html appendString:@"</tr>"];
            }
        }
        [html appendString:@"</table>"];
        [html appendString:@"</div>"];
    }
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    
    [_webTwitterView loadHTMLString:html baseURL:nil];
    _webTwitterView.scalesPageToFit=YES;
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _connection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
- (void)saveItem
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                    message:@"記事を保存しますか？"
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES",nil];
    [alert show];
}
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1) {
        KMSaveItem *saveItem = [[KMSaveItem alloc]init];
        saveItem.link = _item.link;
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
}

@end
