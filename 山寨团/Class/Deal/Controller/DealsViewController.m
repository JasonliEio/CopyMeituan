//
//  DealsViewController.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DealsViewController.h"
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"
#import "UIView+AutoLayout.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "DealsTopMenu.h"
#import "CategoriesViewController.h"
#import "RegionsViewController.h"
#import "SortsViewController.h"
#import "SortsModel.h"
#import "CategoryModel.h"
#import "CityModel.h"
#import "RegionsModel.h"
#import "MJExtension.h"
#import "SearchDealsController.h"
#import "CustomNavViewController.h"
#import "MJRefresh.h"
#import "FindDealsParam.h"
#import "CollectViewController.h"
#import "MapViewController.h"

@interface DealsViewController ()<AwesomeMenuDelegate>
/** 分类菜单 */
@property (weak, nonatomic) DealsTopMenu *categoryMenu;
/** 区域菜单 */
@property (weak, nonatomic) DealsTopMenu *regionMenu;
/** 排序菜单 */
@property (weak, nonatomic) DealsTopMenu *sortMenu;


/** 点击顶部菜单后弹出的Popover */
/** 分类Popover */
@property (strong, nonatomic) UIPopoverController *categoryPopover;
/** 区域Popover */
@property (strong, nonatomic) UIPopoverController *regionPopover;
/** 排序Popover */
@property (strong, nonatomic) UIPopoverController *sortPopover;



/** 当前选中的城市 */
@property (nonatomic, copy) NSString *selectedCityName;

/** 当前选中分类的名字 */
@property (nonatomic, copy) NSString *selectedCategoryName;

/** 当前选中区域的名字 */
@property (nonatomic, copy) NSString *selectedRegionName;



/** 当前选中的排序 */
@property (nonatomic, strong) SortsModel *selectedSort;



@property (nonatomic,strong) RegionsViewController *regionVC;

@end

@implementation DealsViewController

- (RegionsViewController *)regionVC
{
    if (!_regionVC) {
        self.regionVC = [[RegionsViewController alloc] init];
    }
    return _regionVC;
}

#pragma mark - 懒加载三个popview
- (UIPopoverController *)categoryPopover
{
    if (_categoryPopover == nil) {
        
        CategoriesViewController *cv = [[CategoriesViewController alloc] init];
        self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:cv];
    }
    return _categoryPopover;
}

- (UIPopoverController *)sortPopover
{
    if (!_sortPopover) {
        SortsViewController *cv = [[SortsViewController alloc] init];
        self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:cv];
        
    }
    return _sortPopover;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setUpNavLeft]; //设置导航栏左边的内容
    
    
    [self setUpNavRight]; //设置导航栏右边的内容
    
    
    [self setUpUserMenu]; //用户菜单
    
    [self.regionVC changeCity];
}

#pragma mark - 实现父类方法
- (void)setUpParams:(FindDealsParam *)params
{
    //城市名称
    params.city = self.selectedCityName;
    //排序
    if(self.selectedSort){
        params.sort = @(self.selectedSort.value);
    }
    //分类
    if (self.selectedCategoryName) {
        params.category = self.selectedCategoryName;
    }
    
    //区域
    if (self.selectedRegionName) {
        params.region = self.selectedRegionName;
    }
}


#pragma mark - 通知的监听方法
//监听城市名的改变
-(void)cityDidChange:(NSNotification*)note
{
    self.selectedCityName = note.userInfo[SelectCityName];
    
    //1.更换顶部区域的名字
    self.regionMenu.title = [NSString stringWithFormat:@"%@ - 全部",self.selectedCityName];
    self.regionMenu.subtitle = nil;
    
    //2.刷新数据
    [self.collectionView headerBeginRefreshing];
    
}

//监听排序的改变
-(void)sortDidChange:(NSNotification*)note
{
    //1.更换顶部item文字
    self.selectedSort = note.userInfo[SelectSort];
    
    self.sortMenu.subtitle = self.selectedSort.label;
    
    //2.关闭popView
    [self.sortPopover dismissPopoverAnimated:YES];
    
    //3.刷新数据
    [self.collectionView headerBeginRefreshing];
}

//监听分类的改变
-(void)categoryDidChange:(NSNotification*)note
{
    CategoryModel *category = note.userInfo[SelectCategory];
    NSString *subCategoryName = note.userInfo[SelectSubCategoryName];
    
    if (subCategoryName == nil || [subCategoryName isEqualToString:@"全部"]) {
        self.selectedCategoryName = category.name;
    }else{
        self.selectedCategoryName = subCategoryName;
    }
    
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    //1.更换顶部item
    [self.categoryMenu setIcon:category.icon highIcon:category.highlighted_icon];
    [self.categoryMenu setTitle:category.name];
    [self.categoryMenu setSubtitle:subCategoryName];
    
    //2.关闭popover
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    //3.刷新数据
    [self.collectionView headerBeginRefreshing];
}

//监听区域的改变
-(void)regionDidChange:(NSNotification*)note
{
    RegionsModel *region = note.userInfo[SelectRegion];
    NSString *subRegionName = note.userInfo[SelectSubRegionName];
    
    if (subRegionName == nil || [subRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = region.name;
    }else{
        self.selectedRegionName = subRegionName;
    }
    if ([self.selectedRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = nil;
    }
    
    
    //1.更换顶部item
    [self.regionMenu setTitle:[NSString stringWithFormat:@"%@ - %@",self.selectedCityName,region.name]];
    [self.regionMenu setSubtitle:subRegionName];
    
    
    //2.关闭popover
    [self.regionPopover dismissPopoverAnimated:YES];
    
    //3.刷新数据
    [self.collectionView headerBeginRefreshing];
}

//加载最新的数据
/******************************************************************************/

//设置导航栏左边的内容
- (void)setUpNavLeft
{
    // 1.LOGO
    UIBarButtonItem *logoItem = [UIBarButtonItem itemWithImageName:@"icon_meituan_logo" highImageName:@"icon_meituan_logo" target:nil action:nil];
    logoItem.customView.userInteractionEnabled = NO;
    
    // 2.分类
    DealsTopMenu *categoryMenu = [DealsTopMenu menu];
    //点击方法
    [categoryMenu addTarget:self action:@selector(categoryMenuClick)];
    
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryMenu];
    self.categoryMenu = categoryMenu;
    
    // 3.区域
    DealsTopMenu *regionMenu = [DealsTopMenu menu];
    
    //点击方法
    [regionMenu addTarget:self action:@selector(regionMenuClick)];
    
    UIBarButtonItem *regionItem = [[UIBarButtonItem alloc] initWithCustomView:regionMenu];
    self.regionMenu = regionMenu;
    
    // 4.排序
    DealsTopMenu *sortMenu = [DealsTopMenu menu];
    [sortMenu addTarget:self action:@selector(sortMenuClick)];
    
    [sortMenu setIcon:@"icon_sort" highIcon:@"icon_sort_highlighted"];
    sortMenu.title = @"排序";
    
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortMenu];
    self.sortMenu = sortMenu;
    
    self.navigationItem.leftBarButtonItems = @[logoItem, categoryItem, regionItem, sortItem];
    
}

//设置导航栏右边的内容
- (void)setUpNavRight
{
    // 1.地图
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithImageName:@"icon_map" highImageName:@"icon_map_highlighted" target:self action:@selector(mapClick)];
    mapItem.customView.width = 50;
    mapItem.customView.height = 27;
    
    // 2.搜索
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithImageName:@"icon_search" highImageName:@"icon_search_highlighted" target:self action:@selector(searchClick)];
    searchItem.customView.width = mapItem.customView.width;
    searchItem.customView.height = mapItem.customView.height;
    
    self.navigationItem.rightBarButtonItems = @[mapItem, searchItem];
}


#pragma mark - leftBarButtonItems 的点击方法
/** 分类菜单 */
- (void)categoryMenuClick
{
    [self.categoryPopover presentPopoverFromRect:self.categoryMenu.bounds inView:self.categoryMenu permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

/** 区域菜单 */
- (void)regionMenuClick
{
    
//    RegionsViewController *cv = [[RegionsViewController alloc] init];
   
    self.regionPopover = [[UIPopoverController alloc] initWithContentViewController:self.regionVC];
    
    self.regionVC.popover = self.regionPopover; //这里引用可以让点击区域隐藏popover
    if (self.selectedCityName) {
        CityModel *city = [[[MetaDataTool shareMetaData].cities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.selectedCityName]] firstObject];
        self.regionVC.regions = city.regions;
    }
    
    [self.regionPopover presentPopoverFromRect:self.regionMenu.bounds inView:self.regionMenu permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

/** 排序菜单 */
- (void)sortMenuClick
{
    [self.sortPopover presentPopoverFromRect:self.sortMenu.bounds inView:self.sortMenu permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


/********************************************/

#pragma mark - rightBarButtonItems 的点击方法
- (void)mapClick
{
    CustomNavViewController *nav = [[CustomNavViewController alloc] initWithRootViewController:[[MapViewController alloc] init]];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)searchClick
{
    if(self.selectedCityName){
        SearchDealsController *searchVC = [[SearchDealsController alloc] init];
        searchVC.cityName = self.selectedCityName;
        CustomNavViewController *nav = [[CustomNavViewController alloc]initWithRootViewController:searchVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [KVNProgress showErrorWithStatus:@"请先选择城市" onView:self.view];
    }
    
    
    
}
/********************************************/

//左下角菜单
- (void)setUpUserMenu
{
    UIImage *itemBg = [UIImage imageNamed:@"bg_pathMenu_black_normal"];
    // 用户
    AwesomeMenuItem *mineItem = [[AwesomeMenuItem alloc] initWithImage:itemBg highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    // 收藏
    AwesomeMenuItem *collectItem = [[AwesomeMenuItem alloc] initWithImage:itemBg highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    // 浏览
    AwesomeMenuItem *scanItem = [[AwesomeMenuItem alloc] initWithImage:itemBg highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    // 更多
    AwesomeMenuItem *moreItem = [[AwesomeMenuItem alloc] initWithImage:itemBg highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    NSArray *items = @[mineItem, collectItem, scanItem, moreItem];
    
    // 中间按钮
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    // 菜单
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem optionMenus:items];
    [self.view addSubview:menu];
    menu.alpha = 0.3;
    menu.rotateAddButton = NO;
    menu.delegate = self;
    // 菜单占据90°
    menu.menuWholeAngle = M_PI_2;
    CGFloat menuWH = 200;
    CGFloat menuPadding = 60;
    menu.startPoint = CGPointMake(menuPadding, menuWH - menuPadding);
    [menu autoSetDimensionsToSize:CGSizeMake(menuWH, menuWH)];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    // 半透明背景
    UIImageView *menuBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background"]];
    menuBg.center = startItem.center;
    [menu insertSubview:menuBg atIndex:0];
    
}

#pragma mark - 菜单代理
- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    [self awesomeMenuWillAnimateClose:menu];
    
    switch (idx) {
        case 0: {

            break;
        }
        case 1: {//收藏
            CustomNavViewController *nav = [[CustomNavViewController alloc]initWithRootViewController:[[CollectViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    //显示xx图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    menu.highlightedContentImage = [UIImage imageNamed:@"icon_pathMenu_cross_highlighted"];
    
    //取消半透明
    menu.alpha = 1.0;
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    //恢复 人头 图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    menu.highlightedContentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_highlighted"];
    
    //恢复半透明
    menu.alpha = 0.3;
}

- (void)setUpNotifination
{
    
    //监听城市的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityDidChange:) name:CityDidChangeNotification object:nil];
    
    //监听排序的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortDidChange:) name:SortDidChangeNotification object:nil];
    
    //监听分类的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryDidChange:) name:CategoryDidChangeNotification object:nil];
    
    //监听区域的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionDidChange:) name:RegionDidChangeNotification object:nil];
}



#pragma mark - 销毁
//这个控制器一消失就移除通知
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//一显示 再添加回通知
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpNotifination];
}
@end
