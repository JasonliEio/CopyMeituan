//
//  BaseViewController.m
//  山寨团
//
//  Created by Jason on 15/2/8.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+AutoLayout.h"
#import "MJRefresh.h"
#import "DealCell.h"
#import "DealTool.h"
#import "MJExtension.h"
#import "DetialViewController.h"

@interface BaseViewController ()
/*所有团购数据*/
@property (nonatomic,strong) NSMutableArray *deals;
/*没有数据的提醒*/
@property (nonatomic,weak) UIImageView *noDataView;

/** 请求参数 */
@property (nonatomic, strong) FindDealsParam *lastParams;

//存储请求结果总数
@property (nonatomic,assign) int totalNumber;
@end

@implementation BaseViewController

static NSString * const reuseIdentifier = @"deal";

//流水布局
- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    
    
    return [self initWithCollectionViewLayout:layout];
}


- (NSMutableArray *)deals
{
    if (!_deals) {
        self.deals = [NSMutableArray array];
    }
    return _deals;
}

- (UIImageView *)noDataView
{
    if (!_noDataView) {
        //添加一个没有数据的提醒
        UIImageView *noDataView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        [self.view addSubview:noDataView];
        [noDataView autoCenterInSuperview];
        self.noDataView = noDataView;
    }
    return _noDataView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = cColor(230, 230, 230, 1.0);
    self.collectionView.alwaysBounceVertical = YES; //设置scrollView永远有弹簧效果
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"DealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

    
    [self setUpRefresh];//集成刷新控件
    
}

#pragma mark - 刷新数据
-(void)setUpRefresh
{
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
}

//上拉加载更多数据
- (void)loadMoreDeals
{
    //1.创建请求参数
    FindDealsParam *params = [self buildParams];
    
    //页码
    params.page = @(self.lastParams.page.intValue +1);
    
    [DealTool findDeals:params success:^(FindDealsResult *result) {
        //请求过期直接返回
        if (params != self.lastParams) return ;
        
        //1.取出团购数组
        [self.deals addObjectsFromArray:result.deals];
        
        //2.刷新UICollectionView
        [self.collectionView reloadData];
        
        //3.结束刷新
        [self.collectionView footerEndRefreshing];
        
        
        
    } failure:^(NSError *error) {
        
        //请求过期直接返回
        if (params != self.lastParams) return ;
        [KVNProgress showErrorWithStatus:@"网络出错" onView:self.view];
        //结束刷新
        [self.collectionView footerEndRefreshing];
        
        //回滚页码
        params.page = @(params.page.intValue - 1);
    }];
    
    
    //3.设置请求参数
    self.lastParams = params;
}

#pragma mark - 服务器请求数据（加载最新的团购数据）

- (FindDealsParam*)buildParams
{
    FindDealsParam *params = [[FindDealsParam alloc] init];
    
    //调用子类实现的方法
    [self setUpParams:params];
    
    //设置单次返回的数量
    params.limit = @(30);
    //页码
    params.page = @1;
    
    return params;
}

- (void)loadNewDeals
{
    FindDealsParam *params = [self buildParams];
    
    
    [DealTool findDeals:params success:^(FindDealsResult *result) {
        //请求过期直接返回
        if (params != self.lastParams) return ;
        
        //保存当前数据数量
        self.totalNumber = result.total_count;
        
        //0.清空之前的数据
        [self.deals removeAllObjects];
        
        //1.取出团购数组
        [self.deals addObjectsFromArray:result.deals];
        
        //2.刷新UICollectionView
        [self.collectionView reloadData];
        
        //3.结束刷新
        [self.collectionView headerEndRefreshing];
        
        
        
    } failure:^(NSError *error) {
        if (params != self.lastParams) return ;
        
         [KVNProgress showErrorWithStatus:@"网络出错" onView:self.view];
        //结束刷新
        [self.collectionView headerEndRefreshing];
    }];
    
    //保存请求参数
    self.lastParams = params;
    
}

#pragma mark - 监听屏幕的旋转
//屏幕旋转控制器的尺寸改变时调用
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    //横屏 3列  竖屏2列
    int cols = (size.width == 1024) ? 3:2;
    
    //根据列数计算内边距
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    CGFloat inset = (size.width - cols *layout.itemSize.width) /(cols + 1);
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    //设置每一行之间的间距
    layout.minimumLineSpacing = inset;
}


#pragma mark - UICollectionView 数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self viewWillTransitionToSize:CGSizeMake(collectionView.width, 0) withTransitionCoordinator:nil];
    //控制上拉加载是否显示
    self.collectionView.footerHidden = (self.deals.count == self.totalNumber);
    
    //控制没有数据的提醒
    self.noDataView.hidden = (self.deals.count != 0);
    return self.deals.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}
#pragma mark - UICollectionView 代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetialViewController *detialVC = [[DetialViewController alloc] init];
    detialVC.deal = self.deals[indexPath.item];
    [self presentViewController:detialVC animated:YES completion:nil];
}
@end
