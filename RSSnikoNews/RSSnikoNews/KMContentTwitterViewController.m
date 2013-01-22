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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tweetImages = [[NSMutableArray alloc]init];
    tweetImageUrls= [[NSMutableArray alloc]init];
    bounds = [[UIScreen mainScreen]bounds];
    
    height = bounds.size.height;// - self.tabBarController.tabBar.bounds.size.height-self.navigationController.navigationBar.bounds.size.height;
    height = bounds.size.height - self.tabBarController.tabBar.bounds.size.height-self.navigationController.navigationBar.bounds.size.height;
    
    _topicTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, height*0.1)];
    _topicTitle.textAlignment=UITextAlignmentLeft;
    _topicTitle.textColor=[UIColor whiteColor];
    _topicTitle.backgroundColor=[UIColor darkGrayColor];
    _topicTitle.text=@"  Twitterの反応";
    [self.view addSubview:_topicTitle];
    
    _webTwitterView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height*0.1, bounds.size.width, height*0.9)];
    _webTwitterView.delegate = self;
    [self.view addSubview:_webTwitterView];

    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height*0.1, bounds.size.width*0.87, self.view.bounds.size.height-height*0.1) style:UITableViewStyleGrouped];
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
     _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
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
    _tweetUsers = PerformHTMLXPathQuery(_downloadedData, @"//div[@id='twitter-remains']/ul/li/p[@class='user-name']/a");

    for (NSDictionary *tweetUser in _tweetUsers) {
        NSLog([tweetUser objectForKey:@"nodeContent"] );
    }

    NSArray *parsetweetImageUrls = PerformHTMLXPathQuery(_downloadedData, @"//div[@id='twitter-remains']/ul/li/a/img[@title]");
    for (NSDictionary *parsetweetImageUrl in parsetweetImageUrls) {
        id urltmp =[[[parsetweetImageUrl objectForKey:@"nodeAttributeArray"] objectAtIndex:1]objectForKey:@"nodeContent"];
//        NSURL *url = [NSURL URLWithString:urltmp];

        [tweetImageUrls addObject:urltmp];
/*
        NSURL *url = [NSURL URLWithString:urltmp];
        NSData *imgFile = [NSData dataWithContentsOfURL:url];
        UIImage *tweetImage = [[UIImage alloc] initWithData:imgFile];
        [_tweetImages addObject:tweetImage];
*/
    }
/*
    [NSThread detachNewThreadSelector:@selector(downloadTwitterImages) toTarget:self withObject:nil];
 */
    
    if ([_tweets count]==0) {
    }else{
        [_tableView reloadData];
    }
}
- (void)downloadTwitterImages
{
    for (NSDictionary *tweetImageUrl in tweetImageUrls) {
        id urltmp =[[[tweetImageUrl objectForKey:@"nodeAttributeArray"] objectAtIndex:1]objectForKey:@"nodeContent"];
        NSURL *url = [NSURL URLWithString:urltmp];

        NSData *imgFile = [NSData dataWithContentsOfURL:url];
        UIImage *tweetImage = [[UIImage alloc] initWithData:imgFile];
        [_tweetImages addObject:tweetImage];
        [_tableView reloadData];
        
    }
    [_tableView reloadData];
}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    _connection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tweets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"tweetCell";
    CellIdentifier=[CellIdentifier stringByAppendingFormat:@"%d",indexPath.row];
    UITableViewCell *cell;
//    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSInteger cellnum = _tweets.count;
    
    if (indexPath.row >= cellnum) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *tweet = [_tweets objectAtIndex:indexPath.row];
    NSString *body = [tweet objectForKey:@"nodeContent"];;
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(230.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
	return size.height +30+35;

}
- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *tweet = [_tweets objectAtIndex:indexPath.row];
    NSDictionary *tweetUser = [_tweetUsers objectAtIndex:indexPath.row];
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.tag = 1;
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = [UIFont systemFontOfSize:14.0];
    UIView *message = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.height, 0.0, cell.frame.size.width-cell.frame.size.height, cell.frame.size.height)];
    message.tag = 0;
    [message addSubview:label];
    [cell.contentView addSubview:message];
    NSString *text = [tweetUser objectForKey:@"nodeContent"];
    text = [text stringByAppendingFormat:@"\n%@",[tweet objectForKey:@"nodeContent"] ];
   
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(230.0f-cell.frame.size.height, height) lineBreakMode:UILineBreakModeWordWrap];
    label.frame = CGRectMake(20, 11, size.width + 5, size.height);
    label.text = text;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 4.0, cell.frame.size.height-4.0, cell.frame.size.height-4.0)];
    [cell.contentView addSubview:imageView];

    
    UIActivityIndicatorView *indicator;
    indicator = [[UIActivityIndicatorView alloc]
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame =imageView.bounds;
    indicator.hidesWhenStopped = TRUE;
    indicator.contentMode = UIViewContentModeCenter;
    [indicator startAnimating];
    [imageView addSubview:indicator];

    dispatch_queue_t q_global, q_main;
    q_global = dispatch_get_global_queue(0, 0);
    q_main = dispatch_get_main_queue();

	dispatch_async(q_global, ^{
        NSURL *url = [NSURL URLWithString:[tweetImageUrls objectAtIndex:indexPath.row]];
        NSData *imgFile = [NSData dataWithContentsOfURL:url];
        UIImage *tweetImage = [[UIImage alloc] initWithData:imgFile];
        if (tweetImage) {
            [_tweetImages addObject:tweetImage];
        }

		dispatch_async(q_main, ^{
			imageView.image = tweetImage;
			indicator.hidden = YES;
            
		});
	});

/*
    if (_tweetImages.count>=indexPath.row+1) {
        imageView.image=[_tweetImages objectAtIndex:indexPath.row];
        [cell.contentView addSubview:imageView];
    }else{
        dispatch_queue_t q_global, q_main;
        q_global = dispatch_get_global_queue(0, 0);
        q_main = dispatch_get_main_queue();
        dispatch_async(q_global, ^{
            UIActivityIndicatorView *indicator;
            indicator = [[UIActivityIndicatorView alloc]
						 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.frame =imageView.bounds;
			indicator.hidesWhenStopped = TRUE;
			indicator.contentMode = UIViewContentModeCenter;
			[indicator startAnimating];
            dispatch_async(q_main, ^{
				imageView.image = nil;
                [imageView addSubview:indicator];
                [cell.contentView addSubview:imageView];
			});
            
            NSURL *url = [NSURL URLWithString:[tweetImageUrls objectAtIndex:indexPath.row]];
            NSData *imgFile = [NSData dataWithContentsOfURL:url];
            UIImage *tweetImage = [[UIImage alloc] initWithData:imgFile];
            if (tweetImage) {
                [_tweetImages addObject:tweetImage];
            }
			dispatch_async(q_main, ^{
				[indicator removeFromSuperview];
				imageView.image = tweetImage;
                [cell.contentView addSubview:imageView];
            });
            
        });
        
    }
*/

}
@end
