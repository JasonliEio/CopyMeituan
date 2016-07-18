//
//  MetaDataTool.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "MetaDataTool.h"
#import "CategoryModel.h"
#import "CityModel.h"
#import "CityGroupModel.h"
#import "SortsModel.h"
#import "MJExtension.h"
#import "Deals.h"

@interface MetaDataTool ()
{
    /** 所有的分类 */
    NSArray *_categories;
    /** 所有的城市 */
    NSArray *_cities;
    /** 所有的城市组 */
    NSArray *_cityGroups;
    /** 所有的排序 */
    NSArray *_sorts;
}
@end

@implementation MetaDataTool

#pragma  mark - 单例
static id _instace = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)shareMetaData
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instace;
}
/*******************************************************************/
- (NSArray *)categories
{
    if (!_categories) {
        _categories = [CategoryModel objectArrayWithFilename:@"categories.plist"]; //通过plist来创建一个模型数组
    }
    return _categories;
}

- (NSArray *)cityGroups
{
    if (!_cityGroups) {
        _cityGroups = [CityGroupModel objectArrayWithFilename:@"cityGroups.plist"];
    }
    return _cityGroups;
}

- (NSArray *)cities
{
    if (!_cities) {
        _cities = [CityModel objectArrayWithFilename:@"cities.plist"];
    }
    return _cities;
}

- (NSArray *)sorts
{
    if (!_sorts) {
        _sorts = [SortsModel objectArrayWithFilename:@"sorts.plist"];
    }
    return _sorts;
}

- (CityModel*)cityWithName:(NSString*)name
{
    if (name.length == 0) return nil;
    
    for (CityModel *city in self.cities) {
        if ([city.name isEqualToString:name]) return city;
    }
    return nil; 
}

+ (CategoryModel*)categoryWithDeal:(Deals*)deal
{
    NSArray *cs = [MetaDataTool shareMetaData].categories;
    NSString *Dname = [deal.categories firstObject];
    for (CategoryModel *cat in cs) {
        if ([Dname isEqualToString:cat.name]) return cat;
        if ([cat.subcategories containsObject:Dname]) return cat;
    }
    return nil;
}

@end
