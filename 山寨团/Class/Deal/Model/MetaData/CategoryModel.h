//
//  CategoryModel.h
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropDownMenu.h"

@interface CategoryModel : NSObject
/** 类别名称 */
@property (copy, nonatomic) NSString *name;
/** 大图标 */
@property (copy, nonatomic) NSString *icon;
/** 大图标(高亮) */
@property (copy, nonatomic) NSString *highlighted_icon;
/** 小图标 */
@property (copy, nonatomic) NSString *small_icon;
/** 小图标(高亮) */
@property (copy, nonatomic) NSString *small_highlighted_icon;
/** 子类别 */
@property (strong, nonatomic) NSArray *subcategories;

/** 地图图标 */
@property (copy, nonatomic) NSString *map_icon;
@end
