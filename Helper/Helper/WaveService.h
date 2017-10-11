//
//  WaveService.h
//  SendSignal
//
//  Created by olami on 2017/7/11.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaveService : NSObject
+ (WaveService*)shareInstance;
- (void)sendSignal:(NSString *)userCode dataCode:(NSString*)dataCode;
@end
