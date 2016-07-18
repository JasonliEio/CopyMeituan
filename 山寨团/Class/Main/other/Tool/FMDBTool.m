//
//  FMDBTool.m
//  山寨团
//
//  Created by jason on 15-2-10.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "FMDBTool.h"
#import "FMDB.h"
#import "Deals.h"

@implementation FMDBTool
static FMDatabase *_db;

+ (void)initialize
{
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"deal.sqlite"];
    _db = [FMDatabase databaseWithPath:file];
    if (![_db open]) return;
    
    //创建表格
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL)"];
    
}

+(int)collectDealsCount
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal;"];
    [set next];
    
    return [set intForColumn:@"deal_count"];

}

+(BOOL)isCollected:(Deals*)deal
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal WHERE deal_id = %@;",deal.deal_id]; // 查询个数
    [set next];
    
    return [set intForColumn:@"deal_count"] == 1;
}

+ (NSArray *)collectDeals:(int)page
{
    int size = 9; //每次9条
    int pos = (page - 1) * size;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d,%d;",pos,size];
    NSMutableArray *dealsArr = [NSMutableArray array];
    while (set.next) {
        Deals *deal = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"deal"]];
        [dealsArr addObject:deal];
    }
    return dealsArr;
}


+ (void)addCollect:(Deals *)deal
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deal];
    [_db executeUpdateWithFormat:@"INSERT INTO t_collect_deal(deal,deal_id) VALUES(%@,%@);",data,deal.deal_id];
}


+ (void)removeCollect:(Deals *)deal
{
    [_db executeUpdateWithFormat:@"DELETE FROM t_collect_deal WHERE deal_id = %@",deal.deal_id];
}
@end

