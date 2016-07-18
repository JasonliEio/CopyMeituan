//
//  GetSIngleDealResult.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetSIngleDealResult : NSObject
/** 本次API访问所获取的单页团购数量 */
@property (assign, nonatomic) int count;

/** 所有的团购 */
@property (strong, nonatomic) NSArray *deals;
@end
