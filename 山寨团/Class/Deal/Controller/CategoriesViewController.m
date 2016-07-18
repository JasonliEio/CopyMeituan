//
//  CategoriesViewController.m
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "CategoriesViewController.h"
#import "DropDownMenu.h"
#import "MetaDataTool.h"
#import "CategoryModel.h"

@interface CategoriesViewController ()<DropDownMenuDelegate,DropDownDataSource>

@end

@implementation CategoriesViewController

- (void)loadView //在这个方法里面写，可以保证控制器一运行就加载DropDownMenu 这个自定义的view,如果写在viewDidLoad 控制器会先加载一个空白view，这样比较浪费
{
    DropDownMenu *menu = [DropDownMenu dropdownMenu];
    menu.dataSource = self;
    menu.delegate = self; //代理
    self.view = menu;
}


#pragma mark -DropDownDataSource 数据源代理方法
- (NSInteger)numberOfRowsInMainTable:(DropDownMenu *)dropDown
{
    return [MetaDataTool shareMetaData].categories.count;
}

- (NSString*)DropDown:(DropDownMenu *)dropDown iconForRowInMainTable:(int)row
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[row];
    return category.small_icon;
}

- (NSString *)DropDown:(DropDownMenu *)dropDown selectedIocnForRowInMainTable:(int)row
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[row];
    return category.small_highlighted_icon;
}

- (NSString *)DropDown:(DropDownMenu *)dropDown titleForRowInMainTable:(int)row
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[row];
    return category.name;
}

- (NSArray*)DropDown:(DropDownMenu *)dropDown subDataForRowInMainTable:(int)row
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[row];
    return category.subcategories;
}
#pragma mark - 实现代理方法
//点击主表
- (void)dropDown:(DropDownMenu *)dropDown didSelectRowInMainTable:(NSInteger)row
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[row];
    if (category.subcategories.count == 0) {
        //发通知
        [[NSNotificationCenter defaultCenter]postNotificationName:CategoryDidChangeNotification object:nil userInfo:@{SelectCategory : category}];
    }
}

//点击次表
- (void)dropDown:(DropDownMenu *)dropDown didSelectRowInSubTable:(NSInteger)subRow inMainTable:(NSInteger)mainRow
{
    CategoryModel *category = [MetaDataTool shareMetaData].categories[mainRow];
    //发通知
    [[NSNotificationCenter defaultCenter]postNotificationName:CategoryDidChangeNotification object:nil userInfo:@{SelectCategory : category , SelectSubCategoryName : category.subcategories[subRow]}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(400, 480);
    
}


@end
