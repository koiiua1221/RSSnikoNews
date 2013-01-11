//
//  KMTOPICChannel.m
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import "KMTOPICChannel.h"

@implementation KMTOPICChannel

@synthesize identifier = _identifier;
@synthesize feedUrlString = _feedUrlString;
@synthesize title = _title;
@synthesize link = _link;
@synthesize items = _items;

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    CFUUIDRef   uuid;
    uuid = CFUUIDCreate(NULL);
    _identifier = (__bridge NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    _items = [NSMutableArray array];
    
    return self;
}
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _identifier = [decoder decodeObjectForKey:@"identifier"];
    _feedUrlString = [decoder decodeObjectForKey:@"feedUrlString"];
    _title = [decoder decodeObjectForKey:@"title"];
    _link = [decoder decodeObjectForKey:@"link"];
    _items = [decoder decodeObjectForKey:@"items"];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_feedUrlString forKey:@"feedUrlString"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_link forKey:@"link"];
    [encoder encodeObject:_items forKey:@"items"];
}

@end
