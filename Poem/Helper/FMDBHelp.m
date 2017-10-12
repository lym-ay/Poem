//
//  FMDBHelp.m
//  RemoteControl
//
//  Created by olami on 2017/7/3.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "FMDBHelp.h"
#import "FMDB.h"
@interface FMDBHelp ()

@property(nonatomic,strong)NSString *fileName;//数据库文件的路径
@property(nonatomic,strong)FMDatabase *database; //数据库对象

@end

@implementation FMDBHelp
#pragma mark - 单例
+ (FMDBHelp*)sharedFMDBHelp {
    static FMDBHelp *help = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        help = [[FMDBHelp alloc] init];
        help.fileName = @"PoemDB";
    });
    return help;
}

#pragma amrk - 根据名称创建沙盒路径用来保存数据库文件
- (NSString*)dbPath {
    //说明fileName不为空
    if (self.fileName.length) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fullPath = [path stringByAppendingPathComponent:self.fileName];
//        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:@"database"]
//                                                        withIntermediateDirectories:NO
//                                                        attributes:nil
//                                                        error:nil];
        //NSLog(@"%@",fullPath);
        return fullPath;
    } else {
        return @"";
    }
}

#pragma mark - 创建数据库对象
//懒加载
- (FMDatabase*)database {
    if (!_database) {
        _database = [FMDatabase databaseWithPath:[self dbPath]];
    }
    return _database;
}

#pragma mark - 打开或者创建数据库
- (BOOL)openOrCreateDB {
    if ([self.database open]) {
        NSLog(@"数据库打开成功");
        return YES;
    } else {
        NSLog(@"数据库打开失败");
        return NO;
    }
}

#pragma mark - 无返回结果集的操作
- (BOOL)notResultSetWithSql:(NSString*)sql {
    //打开数据库
    BOOL isOpen = [self openOrCreateDB];
    if (isOpen) {
        //进行操作
        BOOL isSuccess = [self.database executeUpdate:sql];
        [self closeDB];
        //NSLog(@"打开数据库成功");
        return isSuccess;
    } else {
        //NSLog(@"打开数据库失败");
        return NO;
    }
}

#pragma mark - 关闭数据库的方法
- (void)closeDB {
    BOOL isClose = [self.database close];
    if (isClose) {
        //NSLog(@"关闭数据库成功");
    } else {
        //NSLog(@"关闭数据库失败");
    }
}

#pragma mark - 通用的查询方法
- (NSArray*)qureyWithSql:(NSString*)sql {
    //打开数据库
    BOOL isOpen = [self openOrCreateDB];
    if (isOpen) {
        //得到所有记录的结果集
        FMResultSet *set = [self.database executeQuery:sql];
        //声明一个可变数组,用来存放所有的记录
        NSMutableArray *array = [NSMutableArray array];
        //遍历结果集,取出每一条记录,将每一条记录转换为字典类型,并且存储到可变数组中
        while ([set next]) {
            //直接将一条记录转换为字典类型
            NSDictionary *dic = [set resultDictionary];
            [array addObject:dic];
        }
        //释放结果集
        [set close];
        [self closeDB];
        return array;
    } else {
        NSLog(@"打开数据库失败");
        return nil;
    }
}

//判断数据库中表是否存在
- (int)isExistTable:(NSString *)tableName {
    NSString *name =nil;
    int isExistTable =0;
    BOOL isOpen = [self openOrCreateDB];
    if (isOpen) {
        NSString * sql = [[NSString alloc]initWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",tableName];
        FMResultSet * rs = [self.database executeQuery:sql];
        while ([rs next]) {
            name = [rs stringForColumn:@"name"];
            if ([name isEqualToString:tableName])
            {
                isExistTable =1;
            }
        }
        [self.database close];
    }
    return isExistTable;
}


@end
