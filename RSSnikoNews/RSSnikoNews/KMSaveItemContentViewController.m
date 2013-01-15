//
//  KMSaveItemContentViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMSaveItemContentViewController.h"
#import "KMSaveItemManager.h"
#import "KMSaveItem.h"
#import "XPathQuery.h"
#import <QuartzCore/QuartzCore.h>
@interface KMSaveItemContentViewController ()

@end

@implementation KMSaveItemContentViewController
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:_item.title];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y,bounds.size.width , bounds.size.height*0.4)];
    _webView.delegate = self;
    [[_webView layer] setBorderColor:[[UIColor blackColor] CGColor] ];
    [[_webView layer] setBorderWidth:2];
    [self.view addSubview:_webView];
    _webTwitterView = [[UIWebView alloc]initWithFrame:CGRectMake(bounds.origin.x, bounds.size.height*0.4,bounds.size.width , bounds.size.height-bounds.size.height*0.4)];
    _webTwitterView.delegate = self;
    [self.view addSubview:_webTwitterView];
    [[_webTwitterView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[_webTwitterView layer] setBorderWidth:2];
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
    url = [NSURL URLWithString:_item.feedUrlString];
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
    
    [self _updateHTMLContents];
    [self _updateTwitterContents];
}
- (void)_updateHTMLContents
{
    if (!_webView) {
        return;
    }
    
    NSMutableString*    html;
    html = [NSMutableString string];
    
    [html appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
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
        [html appendString:@"\"/>"];
        [html appendString:@"<hr>"];
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
}
- (void)_updateTwitterContents
{
    if (!_webTwitterView) {
        return;
    }
    
    NSMutableString*    html;
    html = [NSMutableString string];
    
    [html appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
    [html appendString:@"<html>"];
    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
    [html appendString:@"<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"];
    [html appendString:@"<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\">"];
    [html appendString:@"<meta name=\"viewport\" content=\"minimum-scale=1.0, width=device-width, maximum-scale=1.0, user-scalable=no\" />"];
    [html appendString:@"</head>"];
    [html appendString:@"<body>"];
    if ([_tweets count]!=0) {
        [html appendString:@"<div class=\"tweets-text\">"];
        [html appendString:@"<table border>"];
        [html appendString:@"<tr>"];
        [html appendString:@"<th>Twitterの反応</th>"];
        [html appendString:@"</tr>"];
        for (NSDictionary *tweet in _tweets) {
            if ([tweet objectForKey:@"nodeContent"]) {
                [html appendString:@"<tr>"];
                [html appendString:@"<td>"];
                [html appendString:[tweet objectForKey:@"nodeContent"]];
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
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _connection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
@end
