//
//  MetaDataTool.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CityModel,Deals,CategoryModel;

@interface MetaDataTool : NSObject//这是个单例

+ (instancetype)shareMetaData;

/**
 *  所有的分类
 */
@property (strong, nonatomic, readonly) NSArray *categories;
/**
 *  所有的城市
 */
@property (strong, nonatomic, readonly) NSArray *cities;
/**
 *  所有的城市组
 */
@property (strong, nonatomic, readonly) NSArray *cityGroups;
/**
 *  所有的排序
 */
@property (strong, nonatomic, readonly) NSArray *sorts;


- (CityModel*)cityWithName:(NSString*)name; //传入城市名返回城市数据模型

+ (CategoryModel*)categoryWithDeal:(Deals*)deal; //根据团购模型返回对应的分类
@end
