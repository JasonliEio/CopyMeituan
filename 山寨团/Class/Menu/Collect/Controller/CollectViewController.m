//
//  CollectViewController.m
//  山寨团
//
//  Created by jason on 15-2-9.
//  Copyright (c) 2015年 jason. All rights reserved.
//


#import "CollectViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DealCell.h"
#import "UIView+AutoLayout.h"
#import "FMDBTool.h"
#import "DetialViewController.h"
#import "MJRefresh.h"
#import "Deals.h"

NSString *const Done = @"完成";
NSString *const Edit = @"编辑";
#define JSString(str) [NSString stringWithFormat:@"    %@    ",str]

@interface CollectViewController ()<DealCellDelegate>
/*没有数据的提醒*/
@property (nonatomic,weak) UIImageView *noDataView;

@property (nonatomic,strong) NSMutableArray *deals;

@property (nonatomic,assign) int currentPage; //记录页码

@property (nonatomic,strong) UIBarButtonItem *backItem;//导航栏返回item
@property (nonatomic,strong) UIBarButtonItem *selectAllItem;
@property (nonatomic,strong) UIBarButtonItem *unSelectAllItem;
@property (nonatomic,strong) UIBarButtonItem *removeItem;
@end

@implementation CollectViewController

static NSString * const reuseIdentifier = @"deal";

//流水布局
- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    
    
    return [self initWithCollectionViewLayout:layout];
}

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        self.backItem = [UIBarButtonItem itemWithImageName:@"icon_back" highImageName:@"icon_back_highlighted" target:self action:@selector(backCollect)];
    }
    return _backItem;
}

- (UIBarButtonItem *)selectAllItem
{
    if (!_selectAllItem) {
        self.selectAllItem = [[UIBarButtonItem alloc] initWithTitle:JSString(@"全选") style:UIBarButtonItemStyleDone target:self action:@selector(selectAll)];
    }
    return _selectAllItem;
}


- (UIBarButtonItem *)unSelectAllItem
{
    if (!_unSelectAllItem) {
        self.unSelectAllItem = [[UIBarButtonItem alloc] initWithTitle:JSString(@"全不选") style:UIBarButtonItemStyleDone target:self action:@selector(unSelectAll)];
    }
    return _unSelectAllItem;
}

- (UIBarButtonItem *)removeItem
{
    if (!_removeItem) {
        self.removeItem = [[UIBarButtonItem alloc] initWithTitle:JSString(@"删除") style:UIBarButtonItemStyleDone target:self action:@selector(remove)];
        self.removeItem.enabled = NO;
    }
    return _removeItem;
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
        UIImageView *noDataView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
        [self.view addSubview:noDataView];
        [noDataView autoCenterInSuperview];
        self.noDataView = noDataView;
    }
    return _noDataView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"收藏的团购";
    self.collectionView.backgroundColor = cColor(230, 230, 230, 1.0);
    
    //1.返回
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.alwaysBounceVertical = YES;//设置scrollView永远有弹簧效果
    
    //加载第一页的收藏数据
    [self loadMoreCollectDeals];
    
    //监听通知收藏状态的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectStateChange:) name:CollectDidChangeNotification object:nil];
    
    //添加上拉加载
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreCollectDeals)];
    
    //设置导航栏右item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:Edit style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    
}

#pragma mark - 编辑
- (void)edit:(UIBarButtonItem*)item
{
    if ([item.title isEqualToString:Edit]) { //编辑模式
        item.title = Done;
        
        self.navigationItem.leftBarButtonItems = @[self.backItem,self.selectAllItem,self.unSelectAllItem,self.removeItem];
        
        for (Deals *deals in self.deals) {
            deals.editing = YES;
        }
        

        
    }else{   // 完成模式
        item.title = Edit;
        
        self.navigationItem.leftBarButtonItems = @[self.backItem];
        
        for (Deals *deals in self.deals) {
            deals.editing = NO;
        }
        
    }
    
    //刷新表格
    [self.collectionView reloadData];
}

//上拉加载更多收藏
- (void)loadMoreCollectDeals
{
    self.currentPage++;
    
    [self.deals addObjectsFromArray:[FMDBTool collectDeals:self.currentPage]];
    
    [self.collectionView reloadData];
    
    [self.collectionView footerEndRefreshing];
}


#pragma mark - 监听通知收藏状态的改变
- (void)collectStateChange:(NSNotification*)note
{
//    if ([note.userInfo[isCollectKey] boolValue]) {
//        //收藏成功
//        [self.deals insertObject:note.userInfo[CollectDealKey] atIndex:0];
//    }else{
//        //取消收藏成功(这里直接删会有问题，因为Deal 模型不是同一个，详见 Deals.m 的 - (BOOL)isEqual:(Deals*)other 方法！！)
//        [self.deals removeObject:note.userInfo[CollectDealKey]];
//    }
    
    [self.deals removeAllObjects];
    self.currentPage = 0;
    
    [self loadMoreCollectDeals];
}

- (void)backCollect
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    //当收藏团购的总数相等的时候隐藏上拉加载或者处于编辑状态的时候
    for (Deals *deals in self.deals) {
        if (deals.editing == YES ) {
            self.collectionView.footerHidden = YES;
        }else if (self.deals.count == [FMDBTool collectDealsCount]){
            self.collectionView.footerHidden = YES;
        }else{
            self.collectionView.footerHidden = NO;
        }
    }

    
    //当收藏团购的总数相等的时候隐藏上拉加载
    self.collectionView.footerHidden = (self.deals.count == [FMDBTool collectDealsCount]);
    
    //控制没有数据的提醒
    self.noDataView.hidden = (self.deals.count != 0);
    return self.deals.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
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

#pragma mark - 编辑模式下 左边三个item 的点击事件
//全选
- (void)selectAll
{
    self.removeItem.enabled = YES;
    for (Deals *deals in self.deals) {
        deals.checking = YES;
    }
    
    [self.collectionView reloadData];
}

//取消全选
- (void)unSelectAll
{
    self.removeItem.enabled = NO;
    for (Deals *deals in self.deals) {
        deals.checking = NO;
    }
    
    [self.collectionView reloadData];
}

//删除
- (void)remove
{
    NSMutableArray *tempRemove = [NSMutableArray array];
    for (Deals *deals in self.deals) {
        if (deals.isChecking) {
            [FMDBTool removeCollect:deals];
            
            //因为数组在遍历的时候是不能添加和删除的，所以创建一个临时的可变数组，
            //把需要删除的数据先存放到这个临时数组里面,等遍历结束再删除
            [tempRemove addObject:deals];
        }
    }
    
    //删除选择的
    [self.deals removeObjectsInArray:tempRemove];
    
    [self.collectionView reloadData];
    
    self.removeItem.enabled = NO;
}

#pragma mark - 代理，监听编辑状态下，删除按钮的disable状态
- (void)dealCellCheckingStateDidChange:(DealCell *)cell
{
    BOOL hasCheck = NO;
    for (Deals *deals in self.deals) {
        if (deals.isChecking) {
            hasCheck = YES;
            break;
        }
    }
    
    self.removeItem.enabled = hasCheck;
}
@end
