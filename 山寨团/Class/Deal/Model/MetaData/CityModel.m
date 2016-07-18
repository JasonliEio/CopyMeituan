//
//  CityModel.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "CityModel.h"
#import "RegionsModel.h"
#import "MJExtension.h"

@implementation CityModel
- (NSDictionary *)objectClassInArray
{
    return @{@"regions" : [RegionsModel class]};
}

@end
