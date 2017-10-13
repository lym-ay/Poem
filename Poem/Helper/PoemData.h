//
//  PoemData.h
//  RemoteControl
//
//  Created by olami on 2017/10/12.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoemData : NSObject
+ (PoemData*)sharedPoemData;
- (NSArray *)searchTitle:(NSString*)title;//通过名称查询诗歌



@end


