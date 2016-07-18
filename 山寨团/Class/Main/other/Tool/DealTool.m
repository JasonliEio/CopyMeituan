//
//  DealTool.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DealTool.h"
#import "APITool.h"
#import "MJExtension.h"

@implementation DealTool
+ (void)findDeals:(FindDealsParam *)param success:(void (^)(FindDealsResult *result))success failure:(void (^)(NSError *))failure
{       //param.keyValues 模型转字典
    [[APITool shareAPITool] request:@"v1/deal/find_deals" params:param.keyValues success:^(id json) {
        if (success) {
            FindDealsResult *obj = [FindDealsResult objectWithKeyValues:json]; //字典转成模型
            success(obj);
        }
    } failure:^(NSError *error) {
        
        failure(error);
        
    }];
}


+ (void)getSingleDeals:(GetSingleParam *)param success:(void (^)(GetSIngleDealResult *result))success failure:(void (^)(NSError *))failure
{
    //param.keyValues 模型转字典
    [[APITool shareAPITool] request:@"v1/deal/get_single_deal" params:param.keyValues success:^(id json) {
        if (success) {
            GetSIngleDealResult *obj = [GetSIngleDealResult objectWithKeyValues:json]; //字典转成模型
            success(obj);
        }
    } failure:^(NSError *error) {
        
        failure(error);
        
    }];

}
@end
