//
//  DropDownMenu.h
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//  下拉菜单

#import <UIKit/UIKit.h>
@class DropDownMenu;


@protocol DropDownDataSource <NSObject>
//左边的表格一共有多少行
- (NSInteger)numberOfRowsInMainTable:(DropDownMenu*)dropDown;

//返回左边表格每一行具体的标题
- (NSString*)DropDown:(DropDownMenu*)dropDown titleForRowInMainTable:(int)row;

//返回左边表格每一行具体的子数据
- (NSArray*)DropDown:(DropDownMenu*)dropDown subDataForRowInMainTable:(int)row;

@optional
//返回左边表格每一行具体的图标
- (NSString*)DropDown:(DropDownMenu*)dropDown iconForRowInMainTable:(int)row;

//返回左边表格每一行具体的选中图标
- (NSString*)DropDown:(DropDownMenu*)dropDown selectedIocnForRowInMainTable:(int)row;

@end


@protocol DropDownMenuDelegate <NSObject> //监听点击的代理方法
@optional
- (void)dropDown:(DropDownMenu*)dropDown didSelectRowInMainTable:(NSInteger)row;
- (void)dropDown:(DropDownMenu*)dropDown didSelectRowInSubTable:(NSInteger)subRow inMainTable:(NSInteger)mainRow;
@end

@interface DropDownMenu : UIView
+ (instancetype)dropdownMenu;

@property (nonatomic,weak) id<DropDownDataSource> dataSource;

@property (nonatomic,weak) id<DropDownMenuDelegate> delegate;


@end
