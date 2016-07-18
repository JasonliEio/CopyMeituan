//
//  SortsViewController.m
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "SortsViewController.h"
#import "SortsModel.h"
/*********************************************///因为这个按钮仅仅用在这个控制器里面，所以直接写在这里
#pragma mark -              自定义Button
@interface SortButton :UIButton //申明

@property (nonatomic,strong) SortsModel *sort;

@end

@implementation SortButton //实现
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.bgImage = @"btn_filter_normal";
        self.selectedBgImage = @"btn_filter_selected";
        self.titleColor = [UIColor blackColor];
        self.selectedTitleColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

//设置按钮标题
- (void)setSort:(SortsModel *)sort
{
    _sort = sort;
    
    [self setTitle:sort.label forState:UIControlStateNormal];

}

@end
/******************************************************************************/

#pragma mark -               控制器的方法
@interface SortsViewController ()

@property (nonatomic,weak) SortButton *selectedButton;

@end

@implementation SortsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置popView中控件现实的尺寸就是xib的尺寸
    self.preferredContentSize = self.view.size;
    
    //根据排序模型的个数，创建对应按钮
    CGFloat buttonX = 20;
    CGFloat buttonW = self.view.width - 2*buttonX;
    CGFloat buttonP = 15;//按钮的间距
    
    NSArray *sorts = [MetaDataTool shareMetaData].sorts;
    long count = sorts.count;
    CGFloat contentH = 0;//scrollView滚动范围
    for (long i = 0; i<count; i++) {
        //创建按钮（这个按钮仅仅用在这个控制器里面）
        SortButton *button = [[SortButton alloc]init];
        //取出模型
        button.sort = sorts[i];

        //设置尺寸
        button.x = buttonX;
        button.width = buttonW;
        button.height = 30;
        button.y = buttonP + i *(buttonP + button.height);
        //监听按钮点击
        [button addTarget:self action:@selector(sortbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        //内容的高度
        contentH = button.maxY +buttonP;
    }
    
    //设置contentSize
    UIScrollView *scrollView = (UIScrollView*)self.view;
    scrollView.contentSize = CGSizeMake(0, contentH);
}

//第三个popView按钮的点击
- (void)sortbuttonClick:(SortButton*)button
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SortDidChangeNotification object:nil userInfo:@{SelectSort : button.sort}];
    
    self.selectedButton.selected = NO;
    
    button.selected = YES;
    
    self.selectedButton = button;
}

@end
