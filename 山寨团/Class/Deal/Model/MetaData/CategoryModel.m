//
//  CategoryModel.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

- (NSString *)title //DropDownMenuItem 协议所需要返回的
{
    return self.name;
}

- (NSArray *)subTitles
{
    return self.subcategories;
}

- (NSString *)image
{
    return self.small_icon;
}

- (NSString *)highlightedImage
{
    return self.small_highlighted_icon;
}
@end
