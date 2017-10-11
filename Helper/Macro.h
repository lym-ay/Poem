//
//  Macro.h
//  RemoteControl
//
//  Created by olami on 2017/7/4.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#ifndef Macro_h
#define Macro_h


#import "NSString+Extension.h"

#define COLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define RandomColor [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1.0];
#define Kwidth [UIScreen mainScreen].bounds.size.width
#define Kheight [UIScreen mainScreen].bounds.size.height
#define nKwidth [UIScreen mainScreen].bounds.size.width/375
#define nKheight [UIScreen mainScreen].bounds.size.height/667
#define SCREEN_FRAME ([UIScreen mainScreen].bounds)

#define FONTFAMILY            @"PingFang-SC-Regular"
 

#define NSSLog(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr,"%s %s:%d %s\n",[str UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
}

 

#define TangshiUrl @"http://api.jisuapi.com/tangshi/search"//获取节目的URL


#endif /* Macro_h */
