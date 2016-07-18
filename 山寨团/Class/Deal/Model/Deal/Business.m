//
//  Business.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "Business.h"
#import "MJExtension.h"

@implementation Business
//因为id系统有，所以模型只能写ID，然而json数据里面的又必须是id，所以这个方法可以转换
- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"ID" : @"id"};
}

/**
 归档的实现(因为数据库的存储需要用到 NSKeyedArchiver ，MJCodingImplementation这个宏直接把所有的属性归档)
 */
MJCodingImplementation
@end
