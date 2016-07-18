//
//  DealsTopMenu.m
//  山寨团
//
//  Created by Jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DealsTopMenu.h"
@interface DealsTopMenu ()
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end


@implementation DealsTopMenu

+ (instancetype)menu
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DealsTopMenu" owner:nil options:nil] lastObject];
}

//这个方法会在加载xib文件的时候调用
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //禁止默认的拉升
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.imageButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subTitleLabel.text = subtitle;
}

- (void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon
{
    [self.imageButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.imageButton setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
}

@end
