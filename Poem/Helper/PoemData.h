//
//  PoemData.h
//  RemoteControl
//
//  Created by olami on 2017/10/12.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoemData : NSObject
@property (nonatomic,copy) NSString *dbName;
@property (nonatomic,copy) NSString *tableName;
 
- (NSDictionary *)searchTitle:(NSString*)title;


//查询表是否存在
- (int)isExistTable:(NSString *)tableName;
@end


