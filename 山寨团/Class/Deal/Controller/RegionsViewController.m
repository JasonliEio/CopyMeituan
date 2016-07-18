//
//  RegionsViewController.m
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "RegionsViewController.h"
#import "DropDownMenu.h"
#import "UIView+AutoLayout.h"
#import "CityModel.h"
#import "CityViewController.h"
#import "CustomNavViewController.h"
#import "RegionsModel.h"

@interface RegionsViewController ()<DropDownDataSource,DropDownMenuDelegate>



@property (nonatomic,weak) DropDownMenu *menu;
@end

@implementation RegionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //顶部工具条
    UIView *topView = [self.view.subviews firstObject];
    
    // 创建菜单
    DropDownMenu *menu = [DropDownMenu dropdownMenu];
    
    menu.dataSource = self;
    menu.delegate = self;
    
    [self.view addSubview:menu];
    
    //菜单的顶部就是顶部工具条的底部
    [menu autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView];
    
    //除开顶部，其它距离父控件都为0
    [menu autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    self.menu = menu;

}


//- (DropDownMenu *)menu
//{
//    if (_menu == nil) {
//        //顶部工具条
//        UIView *topView = [self.view.subviews firstObject];
//        
//        // 创建菜单
//        DropDownMenu *menu = [DropDownMenu dropdownMenu];
//    
//        menu.dataSource = self;
//        
//        [self.view addSubview:menu];
//        
//        //菜单的顶部就是顶部工具条的底部
//        [menu autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView];
//        
//        //除开顶部，其它距离父控件都为0
//        [menu autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
//        self.menu = menu;
//    }
//    return _menu;
//}

#pragma mark -DropDownDataSource 数据源代理方法
- (NSInteger)numberOfRowsInMainTable:(DropDownMenu *)dropDown
{
    return self.regions.count;
}

- (NSString *)DropDown:(DropDownMenu *)dropDown titleForRowInMainTable:(int)row
{
    RegionsModel *region = self.regions[row];
    return region.name;
}

- (NSArray*)DropDown:(DropDownMenu *)dropDown subDataForRowInMainTable:(int)row
{
    RegionsModel *region = self.regions[row];
    return region.subregions;
}

#pragma mark - DropDownDataSource 点击代理方法
- (void)dropDown:(DropDownMenu *)dropDown didSelectRowInMainTable:(NSInteger)row
{
    RegionsModel *region = self.regions[row];
    if (region.subregions.count == 0) {
        // 发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:RegionDidChangeNotification object:nil userInfo:@{SelectRegion : region}];
    }
}

- (void)dropDown:(DropDownMenu *)dropDown didSelectRowInSubTable:(NSInteger)subRow inMainTable:(NSInteger)mainRow
{
    RegionsModel *region = self.regions[mainRow];
    // 发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:RegionDidChangeNotification object:nil userInfo:@{SelectRegion : region, SelectSubRegionName : region.subregions[subRow]}];
}


//切换城市
- (IBAction)changeCity {
    [self.popover dismissPopoverAnimated:YES];//点击切换城市的时候隐藏popover
    CityViewController *city = [[CityViewController alloc]init];
    CustomNavViewController *nav = [[CustomNavViewController alloc] initWithRootViewController:city];
    nav.modalPresentationStyle = UIModalPresentationFormSheet; //设置modal 出来控制器的样式
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil]; //通过窗口控制器modal出控制器
}
@end
