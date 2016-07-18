//
//  DealTool.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
// (团购业务类)

#import <Foundation/Foundation.h>
#import "FindDealsParam.h"
#import "FindDealsResult.h"
#import "GetSIngleDealResult.h"
#import "GetSingleParam.h"

@interface DealTool : NSObject

//搜素团购信息
+ (void)findDeals:(FindDealsParam*)param
                  success:(void (^)(FindDealsResult *result))success //成功
                  failure:(void (^)(NSError *error))failure; //失败

//获得制定团购信息
+ (void)getSingleDeals:(GetSingleParam*)param
          success:(void (^)(GetSIngleDealResult *result))success //成功
          failure:(void (^)(NSError *error))failure; //失败

@end
