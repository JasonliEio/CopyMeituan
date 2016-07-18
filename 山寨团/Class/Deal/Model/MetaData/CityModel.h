//
//  CityModel.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject
/** 城市名称 */
@property (copy, nonatomic) NSString *name;
/** 区域 */
@property (strong, nonatomic) NSArray *regions;
/** 拼音 suzhou */
@property (copy, nonatomic) NSString *pinYin;
/** 拼音首字母 sz */
@property (copy, nonatomic) NSString *pinYinHead;

@end
