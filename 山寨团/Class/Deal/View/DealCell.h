//
//  DealCell.h
//  山寨团
//
//  Created by jason on 15-2-4.
//  Copyright (c) 2015年 jason. All rights reserved.
// 自定义的 UICollectionViewCell

#import <UIKit/UIKit.h>
@class Deals,DealCell;
//代理，监听编辑状态下，删除按钮的disable状态
@protocol DealCellDelegate <NSObject>
@optional
- (void)dealCellCheckingStateDidChange:(DealCell*)cell;

@end

@interface DealCell : UICollectionViewCell

@property (nonatomic,weak) id<DealCellDelegate> delegate;
@property (nonatomic,strong) Deals *deal;


@end
