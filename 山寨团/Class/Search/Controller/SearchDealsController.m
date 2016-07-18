//
//  SearchDealsController.m
//  山寨团
//
//  Created by Jason on 15/2/8.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "SearchDealsController.h"
#import "UIBarButtonItem+Extension.h"
#import "MJRefresh.h"
#import "FindDealsParam.h"

@interface SearchDealsController ()<UISearchBarDelegate>

@end

@implementation SearchDealsController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.collectionView.backgroundColor = cColor(230, 230, 230, 1.0);
    
    //1.返回
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"icon_back" highImageName:@"icon_back_highlighted" target:self action:@selector(back)];
    
    
    //2.搜索框
    UIView *titleView = [[UIView alloc]init];
    titleView.width = 300;
    titleView.height = 35;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = titleView.bounds;
    searchBar.delegate = self;
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
    searchBar.placeholder = @"请输入关键词";
    //[titleView addSubview:searchBar];
    self.navigationItem.titleView = searchBar;
    
    
    
}


- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 搜索框代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //1.进入下拉刷新方法
    [self.collectionView headerBeginRefreshing];
   
    //2.退出键盘
    [searchBar resignFirstResponder];
}


#pragma mark - 实现父类的方法
- (void)setUpParams:(FindDealsParam *)params
{
    params.city = self.cityName;
    UISearchBar *bar = (UISearchBar*)self.navigationItem.titleView;
    params.keyword = bar.text;
}
@end
