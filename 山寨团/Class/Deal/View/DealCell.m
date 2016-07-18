//
//  DealCell.m
//  山寨团
//
//  Created by jason on 15-2-4.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DealCell.h"
#import "Deals.h"
#import "UIImageView+WebCache.h"
#import "lineLabel.h"

@interface DealCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet lineLabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
/**
 属性名不能以new开头
 */
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;

@property (weak, nonatomic) IBOutlet UIImageView *check;//打勾的小图标


//遮盖的点击
- (IBAction)coverClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cover;

@end

@implementation DealCell

- (void)setDeal:(Deals *)deal
{
    _deal = deal;
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    
    //购买数
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已购买%d",deal.purchase_count];
    
    //原价
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@",deal.list_price];
    
    //现价
    self.currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@",deal.current_price];
    
    NSUInteger dotLoc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    if (dotLoc!=NSNotFound) {
        //超过两位小数
        if (self.currentPriceLabel.text.length - dotLoc > 3) {
            self.currentPriceLabel.text = [self.currentPriceLabel.text substringToIndex:dotLoc + 3];
        }
    }
    
    //是否显示新单图片
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *nowStr = [fmt stringFromDate:[NSDate date]];
    //隐藏：发布日期 < 今天
    self.dealNewView.hidden = ([deal.publish_date compare:nowStr] == NSOrderedAscending);
    
    //根据模型属性来控制蒙板的显示和隐藏
    self.cover.hidden = !deal.isEditing;
    
    //根据模型属性来控制打勾的显示和隐藏
    self.check.hidden = !deal.checking;
    
}

//给cell加背景
- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];
}


- (IBAction)coverClick:(UIButton *)sender {
    
    //设置模型
    self.deal.checking = !self.deal.isChecking;
    
    //修改状态
    self.check.hidden = !self.check.isHidden;
    
    if ([self.delegate respondsToSelector:@selector(dealCellCheckingStateDidChange:)]) {
        [self.delegate dealCellCheckingStateDidChange:self];
    }
   
}
@end
