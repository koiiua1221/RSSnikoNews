//
//  KMTOPICItem.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/20.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMTOPICItem : NSObject<NSCoding>
{
    NSString*   _identifier;
    BOOL        _read;
    NSString*   _title;
    NSString*   _link;
    NSString*   _itemDescription;
    NSString*   _pubDate;
}
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, getter=isRead) BOOL read;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* link;
@property (nonatomic, retain) NSString* itemDescription;
@property (nonatomic, retain) NSString* pubDate;

@end
