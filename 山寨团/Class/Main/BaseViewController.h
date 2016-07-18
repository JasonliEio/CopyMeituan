//
//  BaseViewController.h
//  山寨团
//
//  Created by Jason on 15/2/8.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FindDealsParam;

@interface BaseViewController : UICollectionViewController

/*设置请求参数，交给子类实现*/
- (void)setUpParams:(FindDealsParam*)params;
@end
