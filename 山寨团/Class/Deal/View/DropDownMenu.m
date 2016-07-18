//
//  DropDownMenu.m
//  山寨团
//
//  Created by jason on 15-1-29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DropDownMenu.h"
#import "DropDownMainCell.h"
#import "DropDownSubCell.h"


@interface DropDownMenu ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;//主表

@property (weak, nonatomic) IBOutlet UITableView *subTableView;//次表

// 左边主表选中的行号
@property (nonatomic,assign) NSInteger selectedMainRow;
@end

@implementation DropDownMenu

+ (instancetype)dropdownMenu
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DropDownMenu" owner:nil options:nil] lastObject];
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mainTableView) {
        return [self.dataSource numberOfRowsInMainTable:self];
    } else {
        
        return [self.dataSource DropDown:self subDataForRowInMainTable:self.selectedMainRow].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.mainTableView) { //主表的cell
        cell = [DropDownMainCell cellWithTableView:tableView];
        
        //取出模型数据
        cell.textLabel.text = [self.dataSource DropDown:self titleForRowInMainTable:indexPath.row];
        if ([self.dataSource respondsToSelector:@selector(DropDown:iconForRowInMainTable:)]) {
            cell.imageView.image = [UIImage imageNamed:[self.dataSource DropDown:self iconForRowInMainTable:indexPath.row]];
        }
        if ([self.dataSource respondsToSelector:@selector(DropDown:selectedIocnForRowInMainTable:)]) {
            cell.imageView.highlightedImage = [UIImage imageNamed:[self.dataSource DropDown:self selectedIocnForRowInMainTable:indexPath.row]];
        }
        NSArray *mainData = [self.dataSource DropDown:self subDataForRowInMainTable:indexPath.row];
        if (mainData.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else{ //子表的cell
        cell = [DropDownSubCell cellWithTableView:tableView];
        
        NSArray *subData = [self.dataSource DropDown:self subDataForRowInMainTable:self.selectedMainRow];
        cell.textLabel.text = subData[indexPath.row];
        
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mainTableView) {
        //被点击的数据
        self.selectedMainRow = indexPath.row;
        
        // 刷新右边
        [self.subTableView reloadData];
        
        //通知代理 主表被点击了
        if ([self.delegate respondsToSelector:@selector(dropDown:didSelectRowInMainTable:)]){
            [self.delegate dropDown:self didSelectRowInMainTable:indexPath.row];
        }
    }else{
        //通知代理 次表被点击了
        if ([self.delegate respondsToSelector:@selector(dropDown:didSelectRowInSubTable:inMainTable:)]){
            [self.delegate dropDown:self didSelectRowInSubTable:indexPath.row inMainTable:self.selectedMainRow];
        }
    }
}
@end
