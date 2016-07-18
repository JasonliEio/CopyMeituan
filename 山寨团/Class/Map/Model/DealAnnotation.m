//
//  DealAnnotation.m
//  山寨团
//
//  Created by jason on 15-2-12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DealAnnotation.h"

@implementation DealAnnotation
 - (BOOL)isEqual:(DealAnnotation*)other
{
    return [self.title isEqual:other.title];
}
@end
