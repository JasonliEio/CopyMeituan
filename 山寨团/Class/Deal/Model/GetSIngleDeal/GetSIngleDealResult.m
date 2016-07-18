//
//  GetSIngleDealResult.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "GetSIngleDealResult.h"
#import "Deals.h"
#import "MJExtension.h"

@implementation GetSIngleDealResult
//告诉deals 这个数组里面装的是 Deals 模型
- (NSDictionary *)objectClassInArray
{
    return @{@"deals" : [Deals class]};
}

@end
