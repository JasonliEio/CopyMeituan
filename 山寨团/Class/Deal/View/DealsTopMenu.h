//
//  DealsTopMenu.h
//  山寨团
//
//  Created by Jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealsTopMenu : UIView

+ (instancetype)menu;

- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

-(void)setIcon:(NSString*)icon highIcon:(NSString*)highIcon;
@end
