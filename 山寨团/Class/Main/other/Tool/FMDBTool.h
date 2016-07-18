//
//  FMDBTool.h
//  山寨团
//
//  Created by jason on 15-2-10.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Deals;
@interface FMDBTool : NSObject

+(NSArray*)collectDeals:(int)page;// 传页码返回第page页的团购数据:page>＝1

+(int)collectDealsCount; //查询数据库的团购数据总数

+(void)addCollect:(Deals*)deal; //收藏一个团购

+(void)removeCollect:(Deals*)deal;//移除一个团购

+(BOOL)isCollected:(Deals*)deal; //判断是否被收藏了

@end
