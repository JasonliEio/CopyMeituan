//
//  DetialViewController.m
//  山寨团
//
//  Created by jason on 15-2-9.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DetialViewController.h"
#import "Deals.h"
#import "lineLabel.h"
#import "UIImageView+WebCache.h"
#import "MJExtension.h"
#import "RestrictionsModel.h"
#import "DealTool.h"
#import "FMDBTool.h"

@interface DetialViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *detialWebV;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mum;

@property (weak, nonatomic) IBOutlet UILabel *detialTitle;//标题

@property (weak, nonatomic) IBOutlet UILabel *detialDesc;//描述

@property (weak, nonatomic) IBOutlet UILabel *recentPrice;//现价

@property (weak, nonatomic) IBOutlet lineLabel *originalPrice;//原价

@property (weak, nonatomic) IBOutlet UIImageView *detialImage;//图

@property (weak, nonatomic) IBOutlet UIButton *outTime; //团购剩余时间
@property (weak, nonatomic) IBOutlet UIButton *hadSell; //已售出

@property (weak, nonatomic) IBOutlet UIButton *RestrictionsAnyTime; // 支持随时退
@property (weak, nonatomic) IBOutlet UIButton *RestrictionsExpire; //支持过期退

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn; //收藏按钮


- (IBAction)share;
- (IBAction)collect;
- (IBAction)buy;
- (IBAction)back;
@end

@implementation DetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置详情左边信息
    [self setUpLeftDetial];
    
    //设置收藏状态
    self.collectionBtn.selected = [FMDBTool isCollected:self.deal];
    
}

#pragma mark - 设置详情的右边信息
- (void)setUpRightDetial
{
    self.view.backgroundColor = cColor(230, 230, 230, 1.0);
    self.detialWebV.delegate = self;
    self.detialWebV.hidden = YES;
    [self.detialWebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];

}

#pragma marl - 设置详情的左边信息
- (void)setUpLeftDetial
{
    
    //加载更详细的团购数据
    GetSingleParam *params = [[GetSingleParam alloc] init];
    params.deal_id = self.deal.deal_id;
    [DealTool getSingleDeals:params success:^(GetSIngleDealResult *result) {
        if (result.deals.count) {
            self.deal = [result.deals lastObject];
            // 更新左边的内容
            [self updateLeftData];
            
            //设置详情右边信息
            [self setUpRightDetial];
        }else {
            
        }
    } failure:^(NSError *error) {
        [KVNProgress showErrorWithStatus:@"网络出错" onView:self.view];
    }];
    
}

- (void)updateLeftData
{
    self.detialTitle.text = self.deal.title;
    self.detialDesc.text = self.deal.desc;
    self.recentPrice.text = [NSString stringWithFormat:@"¥ %@",self.deal.current_price];
    self.originalPrice.text = [NSString stringWithFormat:@"¥ %@",self.deal.list_price];
    [self.detialImage sd_setImageWithURL:[NSURL URLWithString:self.deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    [self.hadSell setTitle:[NSString stringWithFormat:@"已售出%d",self.deal.purchase_count] forState:UIControlStateNormal];
    
    //设置剩余时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *dead = [fmt dateFromString:self.deal.purchase_deadline]; //过期时间
    dead = [dead dateByAddingTimeInterval:24*60*60]; //追加一天
    NSDate *now = [NSDate date]; //当前时间
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:now toDate:dead options:0];
    
    if (cmps.day > 30) {
        [self.outTime setTitle:@"一个月内不会过期" forState:UIControlStateNormal];
    }else{
        [self.outTime setTitle:[NSString stringWithFormat:@"%d天%d小时%d分",cmps.day,cmps.hour,cmps.minute] forState:UIControlStateNormal];
    }
    
    //设置退款信息
    self.RestrictionsAnyTime.selected = self.deal.restrictions.is_refundable; //是否支持随时退
    self.RestrictionsExpire.selected = self.deal.restrictions.is_refundable;; //是否支持过期退

}


- (NSUInteger)supportedInterfaceOrientations //这个控制器支持那些方向
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - webViewDelegate 
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if ([webView.request.URL.absoluteString isEqualToString:self.deal.deal_h5_url]) {
        //第一次进来url加载完毕
            NSString *ID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
        
            NSString *urlStr = [NSString stringWithFormat:@"http://lite.m.dianping.com/group/deal/moreinfo/%@",ID];
        [self.detialWebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];

    }else{
        
        // 用来拼接所有的JS
        NSMutableString *js = [NSMutableString string];
        // 删除header
        [js appendString:@"var header = document.getElementsByTagName('header')[0];"];
        [js appendString:@"header.parentNode.removeChild(header);"];
        // 删除顶部的购买
        [js appendString:@"var box = document.getElementsByClassName('cost-box')[0];"];
        [js appendString:@"box.parentNode.removeChild(box);"];
        // 删除底部的购买
        [js appendString:@"var buyNow = document.getElementsByClassName('buy-now')[0];"];
        [js appendString:@"buyNow.parentNode.removeChild(buyNow);"];
        
        // 利用webView执行JS
        [webView stringByEvaluatingJavaScriptFromString:js];

        //显示webView
        webView.hidden = NO;
        
        //隐藏菊花
        [self.mum stopAnimating];
        
    }
}


- (IBAction)share {
    
    
}

//收藏
- (IBAction)collect {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[CollectDealKey] = self.deal;
    
    if (self.collectionBtn.isSelected) { //取消收藏
        [FMDBTool removeCollect:self.deal];
        [KVNProgress showSuccessWithStatus:@"取消收藏成功" onView:self.view];
        
//        info[isCollectKey] = @NO;
    }else{ //收藏
        [FMDBTool addCollect:self.deal];
        [KVNProgress showSuccessWithStatus:@"收藏成功" onView:self.view];
        
//        info[isCollectKey] = @YES;
    }
    
    //按钮的选中取反
    self.collectionBtn.selected = !self.collectionBtn.isSelected;
    
    //发通知（从收藏界面进入的详情界面，里面的收藏和取消收藏，跨控制器，用通知比较好）
    [[NSNotificationCenter defaultCenter] postNotificationName:CollectDidChangeNotification object:nil userInfo:info];
}

#pragma mark - 购买
- (IBAction)buy {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.deal.deal_url]];
}

- (IBAction)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
