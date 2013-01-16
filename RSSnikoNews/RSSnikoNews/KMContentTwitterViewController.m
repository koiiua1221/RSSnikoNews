//
//  KMContentTwitterViewController.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2013/01/16.
//  Copyright (c) 2013年 KoujiMiura. All rights reserved.
//

#import "KMContentTwitterViewController.h"
#import "KMSaveItemManager.h"
#import "KMSaveItem.h"
#import "XPathQuery.h"
#import <QuartzCore/QuartzCore.h>

@interface KMContentTwitterViewController ()

@end

@implementation KMContentTwitterViewController
@synthesize item = _item;
@synthesize delegate = _delegate;
@synthesize downloadedData = _downloadedData;

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
    bounds = [[UIScreen mainScreen]bounds];

    bounds = [[UIScreen mainScreen]bounds];
    
    height = bounds.size.height - self.tabBarController.tabBar.bounds.size.height-self.navigationController.navigationBar.bounds.size.height;
    
    _topicTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, height*0.1)];
    _topicTitle.textAlignment=UITextAlignmentCenter;
    _topicTitle.textColor=[UIColor whiteColor];
    [[_topicTitle layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[_topicTitle layer] setBorderWidth:2];
    _topicTitle.backgroundColor=[UIColor darkGrayColor];
    _topicTitle.text=@"Twitterの反応";
    [self.view addSubview:_topicTitle];
    
    _webTwitterView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height*0.1, bounds.size.width, height*0.9)];
    _webTwitterView.delegate = self;
    [[_webTwitterView layer] setBorderColor:[[UIColor blackColor] CGColor] ];
    [[_webTwitterView layer] setBorderWidth:2];
    [self.view addSubview:_webTwitterView];

    [self parse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
#pragma mark -- NSURLConnectionDelegate --
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_downloadedData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    
    _tweets = PerformHTMLXPathQuery(_downloadedData, @"//div[@id='twitter-remains']/ul/li/p[@class='user-description']");
    for (NSDictionary *tweet in _tweets) {
        NSLog([tweet objectForKey:@"nodeContent"]);
    }

    if ([_tweets count]==0) {
    }else{
        [self _updateTwitterContents];
    }
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
        [html appendString:@"<table border width=250  align=left>"];
        [html appendString:@"<tr>"];
//        [html appendString:@"<th><font size=3>Twitterの反応</font></th>"];
        [html appendString:@"</tr>"];
        for (NSDictionary *tweet in _tweets) {
            if ([tweet objectForKey:@"nodeContent"]) {
                [html appendString:@"<tr>"];
                [html appendString:@"<td width=250>"];
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
@end
