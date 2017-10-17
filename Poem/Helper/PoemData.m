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
//+ (PoemData*)sharedPoemData {
//    static PoemData *help = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        help = [[PoemData alloc] init];
//    });
//    return help;
//}

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


//根据名称查询诗歌
- (NSArray *)searchPoemofTitle:(NSString*)title{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where title like  '%%%@%%'limit 10",_tableName,title];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}


//根据诗人和诗歌查询
- (NSArray *)searchAuthorAndTitle:(NSString*)author title:(NSString*)title{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where author like  '%%%@%%' and title like '%%%@%%' limit 10",_tableName,author,title];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}


//随机查询诗歌
- (NSArray *)searchPoem{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' limit 50",_tableName];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

//////////////////////////////////////////////////
//按照朝代查询诗人
- (NSArray *)searchPoetOfDynasty:(NSString*)dynasty{
    NSString *searchSql = [NSString stringWithFormat:@"select distinct author from '%@' where dynasty='%@'",_tableName,dynasty];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

//按照诗歌内容查询诗人
- (NSArray *)searchPoetOfContent:(NSString*)content{
    NSString *searchSql = [NSString stringWithFormat:@"select author from '%@' where content like  '%%%@%%'",_tableName,content];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
    
}
//按照诗名查询诗人
- (NSArray *)searchPoetOfPoem:(NSString*)poem{
    NSString *searchSql = [NSString stringWithFormat:@"select author from '%@' where poem like  '%%%@%%'",_tableName,poem];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}
//////////////////////////////////////////////

//按照诗句查询诗歌
- (NSArray *)searchPoemOfContent:(NSString*)content{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where content like  '%%%@%%' limit 10",_tableName,content];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

//按照诗人查询诗歌
- (NSArray *)searchPoemOfPoet:(NSString*)poet{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where author = '%@' limit 50",_tableName,poet];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

//按照朝代查询诗歌
- (NSArray *)searchPoemOfDynasty:(NSString*)dynasty{
    NSString *searchSql = [NSString stringWithFormat:@"select title,content,explanation,appreciation,author from '%@' where dynasty = '%@'limit 50",_tableName,dynasty];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    return arry;
}

- (int)isExistTable:(NSString *)tableName {
    return [[FMDBHelp sharedFMDBHelp] isExistTable:tableName];
}



 

@end
