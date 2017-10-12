//
//  FMDBHelp.h
//  RemoteControl
//
//  Created by olami on 2017/7/3.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBHelp : NSObject
+ (FMDBHelp*)sharedFMDBHelp;
//无返回结果集的操作
- (BOOL)notResultSetWithSql:(NSString*)sql;
//查询操作
- (NSArray*)qureyWithSql:(NSString*)sql;
//查询表是否存在
- (int)isExistTable:(NSString *)tableName;
@end
