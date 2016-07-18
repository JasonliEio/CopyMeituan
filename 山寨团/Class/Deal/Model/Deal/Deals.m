//
//  Deals.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "Deals.h"
#import "Business.h"
#import "MJExtension.h"

@implementation Deals
//数组 － 字典 (告诉  businesses 这个数据装的是 Business这个模型)
- (NSDictionary *)objectClassInArray
{
    return @{@"businesses" : [Business class]};
}

//因为description系统有，所以模型只能写desc，然而json数据里面的又必须是description，所以这个方法可以转换
- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"desc" : @"description"};
}

//这个方法表示 如果同一个模型可能不一样的时候，只要他们的deal_id 是一样的 就认为这两个模型是一样的
- (BOOL)isEqual:(Deals*)other
{
    return [self.deal_id isEqual:other.deal_id];
}

/**
 归档的实现(因为数据库的存储需要用到 NSKeyedArchiver ，MJCodingImplementation这个宏直接把所有的属性归档)
 */
MJCodingImplementation
@end
