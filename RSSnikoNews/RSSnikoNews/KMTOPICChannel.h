//
//  KMTOPICChannel.h
//  RSSnikoNews
//
//  Created by KoujiMiura on 2012/12/19.
//  Copyright (c) 2012年 KoujiMiura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMTOPICChannel : NSObject<NSCoding>
{
    NSString*       _identifier;
    NSString*       _feedUrlString;
    NSString*       _title;
    NSString*       _link;
    NSMutableArray* _items;
}
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, retain) NSString* feedUrlString;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* link;
@property (nonatomic, readonly) NSMutableArray* items;
@end
