//
//  RegionsModel.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "RegionsModel.h"

@implementation RegionsModel

- (NSString *)title
{
    return self.name;
}

- (NSArray *)subTitles
{
    return self.subregions;
}
@end
