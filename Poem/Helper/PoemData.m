//
//  PoemData.m
//  RemoteControl
//
//  Created by olami on 2017/7/3.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "FMDBHelp.h"
#import "PoemData.h"



#define DBName @"PoemDB"

#define NSSLog(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"%s %s:%d %s\n",[str UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
}


@interface PoemData()
@property (nonatomic,copy) NSString *tableName;


@end

@implementation PoemData

#pragma mark - 单例
+ (PoemData*)sharedPoemData {
    static PoemData *help = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        help = [[PoemData alloc] init];
    });
    return help;
}

- (id)init {
    if (self = [super init]) {
        //把数据库拷贝到相应的目录下
        [self copyDB];
        _tableName = @"PoemTable";
    }
    
    return self;
}


//把生成的数据库文件拷贝到当前目录下面
- (void)copyDB {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
                                                               
                                                               NSUserDomainMask,
                                                               
                                                               YES);
    
    NSString *documentFolderPath = [searchPaths objectAtIndex:0];
    NSString *dbFilePath = [documentFolderPath stringByAppendingPathComponent:DBName];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isExist = [fm fileExistsAtPath:dbFilePath];
    
    if (!isExist) {
        
        //拷贝数据库
        //获取工程里，数据库的路径,因为我们已在工程中添加了数据库文件，所以我们要从工程里获取路径
        
        NSString *backupDbPath = [[NSBundle mainBundle]
                                  
                                  pathForResource:@"PoemDB"
                                  
                                  ofType:@"sqlite"];
        
        //这一步实现数据库的添加，
        
        // 通过NSFileManager 对象的复制属性，把工程中数据库的路径拼接到应用程序的路径上
        
        BOOL cp = [fm copyItemAtPath:backupDbPath toPath:dbFilePath error:nil];
        if (cp) {
            NSLog(@"copy success");
        }else {
            NSLog(@"copy failure");
        }
        
    }else {
        NSLog(@"db is created");
    }

}



- (NSArray *)searchTitle:(NSString*)title{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where title like  '%%%@%%'limit 10",_tableName,title];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

- (int)isExistTable:(NSString *)tableName {
    return [[FMDBHelp sharedFMDBHelp] isExistTable:tableName];
}

@end
