//
//  InfraredData.m
//  RemoteControl
//
//  Created by olami on 2017/7/3.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "InfraredData.h"
#import "FMDBHelp.h"
#import "Macro.h"



#define DBName @"RemoteControlDB"


@interface InfraredData(){
   
}

@end

@implementation InfraredData

#pragma mark - 单例
+ (InfraredData*)sharedInfraredData {
    static InfraredData *help = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        help = [[InfraredData alloc] init];
    });
    return help;
}

- (id)init {
    if (self = [super init]) {
        [[FMDBHelp sharedFMDBHelp] createDBWithName:DBName];
    }
    
    return self;
}

 


- (void)createTable {
     NSString *createTableSql =
    [NSString stringWithFormat:@"create table if not exists %@('pulseID' text primary key not null,'chineseName' text,'userCode' text,'deviceName' text,'pulseData' text,'datacodeValue' text)",_tableName];
    
    BOOL isCreate =  [[FMDBHelp sharedFMDBHelp] notResultSetWithSql:createTableSql];
    if (isCreate) {
        NSLog(@"create pulseTable done!");
    }else{
        NSLog(@"create pulseTable failure!");
    }
}

- (void)parserJSON:(NSData*)jsonData{
    [self generateData:jsonData];
}



-(void)generateData:(NSData*)data {
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
    if (err) {
        NSSLog(@"Infrared generateData error is %@",err.localizedDescription);
        return;
    }
    
    NSString *userCode = [dic objectForKey:@"usercode"];
    NSString *deviceName = [dic objectForKey:@"devicename"];
    NSArray *dataCodeArry = [dic objectForKey:@"datacode"];
    NSString *city = [dic objectForKey:@"city"];
    NSString *deviceNameEn = [dic objectForKey:@"devicename_en"];
    _tableName = [NSString stringWithFormat:@"%@%@",city,deviceNameEn];//表的名称是城市+设备英文名
    [self createTable];
    for (int i=0; i<dataCodeArry.count; i++) {
        NSDictionary *dicData = dataCodeArry[i];
        NSString *chineseName = [dicData objectForKey:@"chinesename"];
        NSString *idNum = [dicData objectForKey:@"id"];
        NSString *dataCodeValue = [dicData objectForKey:@"datacodevalue"];
        NSString *pulseData = [dicData objectForKey:@"pulsedata"];
        
        NSString *insertSql = [NSString stringWithFormat:@"insert into '%@'(pulseID,chineseName,userCode,deviceName,pulseData,datacodeValue) values ('%@','%@','%@','%@','%@','%@')",_tableName,idNum,chineseName,userCode,deviceName,pulseData,dataCodeValue];
        [[FMDBHelp sharedFMDBHelp] notResultSetWithSql:insertSql];

    }
    
    
}




- (NSString *)searchPulseData:(NSString*)pulseID {
    NSString *searchSql = [NSString stringWithFormat:@"select pulseData from '%@' where pulseID = '%@'",_tableName,pulseID];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    NSString *result = nil;
    if (arry.count != 0) {
        NSDictionary *dic = arry[0];
        result = [dic objectForKey:@"pulseData"];
    }

   
    //NSLog(@"result is %@",result);
    return result;
}

- (NSDictionary *)searchData:(NSString*)index {
    NSString *searchSql = [NSString stringWithFormat:@"select usercode,datacodevalue from '%@' where pulseID = '%@'",_tableName,index];
    NSArray *arry = [[FMDBHelp sharedFMDBHelp] qureyWithSql:searchSql];
    NSDictionary *dic = nil;
    if (arry.count != 0) {
        dic = arry[0];
    }
    //NSLog(@"result is %@",dic);
    return dic;
}

- (int)isExistTable:(NSString *)tableName {
    return [[FMDBHelp sharedFMDBHelp] isExistTable:tableName];
}

@end
