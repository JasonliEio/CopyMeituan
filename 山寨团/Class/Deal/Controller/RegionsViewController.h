//
//  RegionsViewController.h
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegionsViewController : UIViewController

@property (nonatomic,weak) UIPopoverController *popover;

@property (nonatomic, strong) NSArray *regions;

- (IBAction)changeCity;
@end
