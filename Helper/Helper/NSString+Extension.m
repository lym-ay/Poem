//
//  NSString+Extension.m
//  testDemo
//
//  Created by yanminli on 2016/11/17.
//  Copyright © 2016年 s3graphics. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)
-(BOOL)isEmpty{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:charSet];
    return [trimmed isEqualToString:@""];

}
#pragma mark --密码md5加密
- (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    NSString* retStr = [[NSString stringWithString:ret] lowercaseString];
    return retStr;
}

#pragma mark --生成6位的随机数
- (NSString *)random6Code{
    NSString* strRandom = [[NSString alloc] init];
    for (int i=0; i<6; i++) {
        strRandom = [ strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
    }
    return strRandom;
}


+ (NSString *)addPlusPlus:(NSString *)string {
    int num = [string intValue];
    num++;
    NSString *tmp = [NSString stringWithFormat:@"%d",num];
    return tmp;
}

+ (NSString *)subtraction:(NSString *)string {
    int num = [string intValue];
    if (num ==0) {
        return string;
    }
    
    num--;
    NSString *tmp = [NSString stringWithFormat:@"%d",num];
    return tmp;

}


@end
