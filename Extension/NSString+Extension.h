//
//  NSString+Extension.h
//  testDemo
//
//  Created by yanminli on 2016/11/17.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
- (BOOL)isEmpty;
- (NSString *)md5HexDigest:(NSString*)input;//MD5加密
+ (NSString *)addPlusPlus:(NSString*)string;//字符串代表的数字加一
+ (NSString *)subtraction:(NSString*)string;//字符串代表的数字减一

@end
