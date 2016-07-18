//
//  FindDealsResult.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetSIngleDealResult.h"

@interface FindDealsResult : GetSIngleDealResult
/** 所有页面团购总数 */
@property (assign, nonatomic) int total_count;

@end
