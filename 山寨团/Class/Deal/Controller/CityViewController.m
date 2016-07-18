//
//  CityViewController.m
//  山寨团
//
//  Created by jason on 15-2-2.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "CityViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MJExtension.h"
#import "CityGroupModel.h"
#import "UIView+AutoLayout.h"
#import "CityResultViewController.h"

@interface CityViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) NSArray *cityGroups;

@property (weak, nonatomic) IBOutlet UITableView *cityTableView;

@property (weak, nonatomic) IBOutlet UIButton *coverView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak,nonatomic) CityResultViewController *cityResult;

- (IBAction)coverClick;
@end

@implementation CityViewController

//懒加载创建显示搜索结果的控制器
- (CityResultViewController *)cityResult
{
    if (!_cityResult) {
        CityResultViewController *cityResult = [[CityResultViewController alloc] init];
        [self addChildViewController:cityResult];//只有两个控制器是父子关系，才可以把整个dismiss掉
        self.cityResult = cityResult;
        
        [self.view addSubview:self.cityResult.view];
        
        //距离父控件底部左右都是0，除了顶部
        [self.cityResult.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        
        //搜索到的结果的view的顶部就是搜索框的顶部
        [self.cityResult.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:10];
    }
    return _cityResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"切换城市";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"btn_navigation_close" highImageName:@"btn_navigation_close_hl" target:self action:@selector(close)];
    self.cityTableView.sectionIndexColor = [UIColor blackColor];
    
    
    //加载城市数据
    self.cityGroups = [CityGroupModel objectArrayWithFilename:@"cityGroups.plist"]; //把plist文件转化为模型数组
    
    //设置搜索周边的颜色
    self.searchBar.tintColor = cColor(32, 191, 179, 1.0);
    
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 搜索框代理方法
//搜索框开始编辑调用
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //1.隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //2.修改搜索框的背景
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield_hl"]];
    
    //显示搜索框右边取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    
    //3.显示遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.alpha = 0.5;
    }];
}

//结束编辑调用
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //1.显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //2.修改搜索框背景
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield"]];
    
    //隐藏搜索框右边取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    
    //隐藏遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.coverView.alpha = 0;
    }];
    
    self.cityResult.view.hidden = YES;
    searchBar.text = nil;
}

//取消按钮代理方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

//搜索框文字改变 调用次代理方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length){
        self.cityResult.view.hidden = NO;
        self.cityResult.searchText = searchText;
        
    }else{
        self.cityResult.view.hidden = YES;
    }
}


//点击遮盖隐藏
- (IBAction)coverClick {
    [self.searchBar resignFirstResponder];
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cityGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CityGroupModel *group = self.cityGroups[section];
    return group.cities.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"city";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    CityGroupModel *group = self.cityGroups[indexPath.section];
    
    
    cell.textLabel.text = group.cities[indexPath.row];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityGroupModel *group = self.cityGroups[indexPath.section];
    
    //发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CityDidChangeNotification object:nil userInfo:@{SelectCityName :group.cities[indexPath.row]}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- 代理方法
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CityGroupModel *group = self.cityGroups[section];
    return group.title;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.cityGroups valueForKey:@"title"];//KVC 直接取出 title
}

@end
