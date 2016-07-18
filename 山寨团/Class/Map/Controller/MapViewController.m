//
//  MapViewController.m
//  山寨团
//
//  Created by jason on 15-2-12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "MapViewController.h"
#import "UIBarButtonItem+Extension.h"
#import <MapKit/MapKit.h>
#import "DealTool.h"
#import "MJExtension.h"
#import "Business.h"
#import "Deals.h"
#import "DealAnnotation.h"
#import "MetaDataTool.h"
#import "CategoryModel.h"
#import "DealsTopMenu.h"
#import "CategoriesViewController.h"

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic,strong) CLGeocoder *coder;

@property (nonatomic,copy) NSString *city;//保存用户所在的城市

/** 分类菜单 */
@property (weak, nonatomic) DealsTopMenu *categoryMenu;

/** 分类Popover */
@property (strong, nonatomic) UIPopoverController *categoryPopover;

/** 当前选中分类的名字 */
@property (nonatomic, copy) NSString *selectedCategoryName;

/** 请求参数 */
@property (nonatomic, strong) FindDealsParam *lastParams;

- (IBAction)localBtn:(UIButton *)sender;
@end

@implementation MapViewController
{
    CLLocationManager *locationManager;
}

- (CLGeocoder *)coder
{
    if (!_coder) {
        self.coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}

- (UIPopoverController *)categoryPopover
{
    if (_categoryPopover == nil) {
        
        CategoriesViewController *cv = [[CategoriesViewController alloc] init];
        self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:cv];
    }
    return _categoryPopover;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.返回
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithImageName:@"icon_back" highImageName:@"icon_back_highlighted" target:self action:@selector(back)];
    
    self.mapView.delegate = self;
    //标题
    self.title = @"地图";
    
    //iOS8下的获取用户localtion
    [self iOS8UserLocation];
    
    self.mapView.delegate = self;
    
    //设置地图跟踪用户的位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    
    //设置左上角分类菜单
    // 2.分类
    DealsTopMenu *categoryMenu = [DealsTopMenu menu];
    //点击方法
    [categoryMenu addTarget:self action:@selector(categoryMenuClickMap)];
    
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryMenu];
    self.categoryMenu = categoryMenu;
    self.navigationItem.leftBarButtonItems = @[backItem,categoryItem];
    
    //监听分类的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryMapDidChange:) name:CategoryDidChangeNotification object:nil];
}

#pragma mark - 监听区域的改变
-(void)categoryMapDidChange:(NSNotification*)note
{
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    //2.获得需要发给服务器的名称
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
    
    //3.先清除所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //4.重新发送请求给服务器
    [self mapView:self.mapView regionDidChangeAnimated:YES];
    
    //1.更换顶部item
    [self.categoryMenu setIcon:category.icon highIcon:category.highlighted_icon];
    [self.categoryMenu setTitle:category.name];
    [self.categoryMenu setSubtitle:subCategoryName];

}

/** 分类菜单 */
- (void)categoryMenuClickMap
{
    [self.categoryPopover presentPopoverFromRect:self.categoryMenu.bounds inView:self.categoryMenu permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate 地图代理
//当用户更新位置就会调用 (这个代理只管获取最新的城市名)
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //设置用户的位置为中心点
//    [mapView setCenterCoordinate:userLocation.location.coordinate];
//    
//    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(0.05, 0.05));
//    [mapView setRegion:region animated:YES];
    
    //通过经纬度获取 城市名字 : 反地理编码
    //通过城市获取 经纬度 : 地理编码
    
    /*获取城市名字*/ //(反地理编码)
    [self.coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *pm = [placemarks firstObject]; //取出一个地标
        //JSLog(@"%@",pm.locality); pm.locality这个也能获取城市，但是不靠谱，因为像上海和北京等，这个值就会是null
        
        
        if (error || placemarks.count == 0) {
            [KVNProgress showErrorWithStatus:@"数据获取失败" onView:self.view];
        }else{
            NSString *city = pm.locality ? pm.locality : pm.addressDictionary[@"State"];
            //传 苏州市 北京市  等等  带有“市”这个是无效的，所以去掉"市"
            self.city = [city substringToIndex:city.length - 1];
        }
    }];
}

//用户拖动地图就已地图中心为圆点，向服务器发送请求，加载团购数据
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    if (self.city == nil) return;
    FindDealsParam *params = [[FindDealsParam alloc] init];
    params.city = self.city;
    //经纬度
    params.longitude = @(mapView.region.center.longitude);
    params.latitude = @(mapView.region.center.latitude);
    //半径
    params.radius = @(5000);
    //类别
    if (self.selectedCategoryName) {
        params.category = self.selectedCategoryName;
    }
    
    [DealTool findDeals:params success:^(FindDealsResult *result) {
        //请求过期直接返回
        if (params != self.lastParams) return ;
        
        for (Deals *deal in result.deals) {
            CategoryModel *category = [MetaDataTool categoryWithDeal:deal];
            for (Business *bus in deal.businesses) {
                DealAnnotation *anno = [[DealAnnotation alloc] init];
                anno.coordinate = CLLocationCoordinate2DMake(bus.latitude, bus.longitude);
                anno.title = bus.name;
                anno.subtitle = deal.title;
                anno.icon = category.map_icon;
                if ([self.mapView.annotations containsObject:anno])  break;//包含重复的大头针就停止遍历
                [self.mapView addAnnotation:anno]; //添加大头针
            }
        }
        
    } failure:^(NSError *error) {
        //请求过期直接返回
        if (params != self.lastParams) return ;
        
        [KVNProgress showErrorWithStatus:@"网络异常" onView:self.view];
    }];
    
    //保存请求参数
    self.lastParams = params;

}

#pragma mark - 自定义大头针
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(DealAnnotation*)annotation
{
    if (![annotation isKindOfClass:[DealAnnotation class]]) return nil;
    
    //创建大头针控件
    static NSString *ID = @"xin";
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annoView == nil) {
        annoView  = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annoView.canShowCallout = YES; //可以弹出详细信息
//        annoView.leftCalloutAccessoryView = [UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"];
    }
    //设置模型
    annoView.annotation = annotation;
    
    //设置图片
    annoView.image = [UIImage imageNamed:annotation.icon];
    
    return annoView;
}

#pragma mark - 点击按钮获取用户当前位置
- (IBAction)localBtn:(UIButton *)sender {
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}



#pragma mark - IOS 8 获取用户位置 和 iOS 7 有所区别
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#ifdef __IPHONE_8_0
    if (
        ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedAlways) ||
        (![locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorized)
        ) {
        
        NSString *message = @"您的手机未开通定位服务,如欲开通定位服务,请至设置->隐私->定位服务,开启此应用的定位服务";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法定位" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        
        
    }else {
        
        [locationManager startUpdatingLocation];
    }
#else
    
#endif
    
    
}

- (void)iOS8UserLocation
{
#ifdef __IPHONE_8_0
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
#else
    
#endif
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
