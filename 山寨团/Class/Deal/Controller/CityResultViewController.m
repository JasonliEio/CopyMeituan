//
//  CityResultViewController.m
//  山寨团
//
//  Created by jason on 15-2-3.
//  Copyright (c) 2015年 jason. All rights reserved.
//
#define kTableHeadViewH 30
#import "CityResultViewController.h"
#import "MJExtension.h"
#import "MetaDataTool.h"
#import "CityModel.h"

@interface CityResultViewController ()

@property (nonatomic,strong) NSArray *cities;
@property (nonatomic,strong) NSArray *resultCities;

@end

@implementation CityResultViewController

- (NSArray *)cities
{
    if (!_cities) {
        self.cities = [MetaDataTool shareMetaData].cities;
    }
    return _cities;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}


- (void)setSearchText:(NSString *)searchText
{
    _searchText = [searchText copy];
    
    //根据关键字搜索想要的城市
    
    searchText = searchText.lowercaseString;//搜索的条件转换成小写 （uppercaseString 大写）
    /*
     //1.通过 forIn的方法筛选
     self.resultCities = [NSMutableArray array];
     
     for (CityModel *city in self.cities) {
     if ([city.name containsString:searchText] || [city.pinYin.uppercaseString containsString:searchText] || [city.pinYinHead.uppercaseString containsString:searchText]) {
     [self.resultCities addObject:city];
     }
     }
     */
    
    //2.过滤器
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or pinYin contains %@ or pinYinHead contains %@",searchText,searchText,searchText];
    self.resultCities = [self.cities filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.resultCities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"city";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    CityModel *city = self.resultCities[indexPath.row];
    cell.textLabel.text = city.name;
    
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0, tableView.frame.size.width, kTableHeadViewH)];
    titleLabel.textColor=cColor(32, 191, 179, 1.0);
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.text=[NSString stringWithFormat:@"共有%d个搜索结果",self.resultCities.count];
    [myView addSubview:titleLabel];
    return myView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableHeadViewH;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityModel *city = self.resultCities[indexPath.row];

    //发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CityDidChangeNotification object:nil userInfo:@{SelectCityName :city.name}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
