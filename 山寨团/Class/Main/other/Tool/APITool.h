//
//  APITool.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APITool : NSObject //这是个单例
- (void)request:(NSString*)url params:(NSDictionary*)params //参数
                               success:(void (^)(id json))success //成功
                               failure:(void (^)(NSError *error))failure; //失败


+ (instancetype)shareAPITool; //api工具类单例
@end
