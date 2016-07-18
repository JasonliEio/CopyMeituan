//
//  APITool.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "APITool.h"
#import "DPAPI.h"
@interface APITool ()<DPRequestDelegate>
@property (nonatomic,strong) DPAPI *api;
@end

@implementation APITool

#pragma mark - ----------     单例
static id _instace = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken , ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)shareAPITool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken , ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (id)copyWithZone:(NSZone*)zone
{
    return _instace;
}
/***********************************************************/

- (DPAPI *)api
{
    if (_api == nil) {
        self.api = [[DPAPI alloc] init];
    }
    return _api;
}

/***********************************************************/
- (void)request:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    DPRequest *request = [self.api requestWithURL:url params:[NSMutableDictionary dictionaryWithDictionary:params] delegate:self];
    request.success = success;
    request.failure = failure;
}

#pragma mark - DPRequestDelegate 请求成功调用
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request.success) {
        request.success(result);
    }
}

//请求失败调用
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request.failure) {
        request.failure(error);
    }
}
@end
