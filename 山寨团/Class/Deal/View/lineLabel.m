//
//  lineLabel.m
//  山寨团
//
//  Created by jason on 15-2-5.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "lineLabel.h"

@implementation lineLabel

//在原价上画一条线
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect]; //调用super 的方法 就可以拿到值了
    
    /*Two*/
    //画一个矩形
    UIRectFill(CGRectMake(0, rect.size.height*0.5, rect.size.width, 1));
    
    /*
    //One
    //设置颜色
    //[[UIColor orangeColor] set];
    
    //画线
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //设置起点
    CGContextMoveToPoint(ctx, 0, rect.size.height*0.5);
    
    //设置终点
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height*0.5);
    
    //渲染
    CGContextStrokePath(ctx);
    */
}

@end
