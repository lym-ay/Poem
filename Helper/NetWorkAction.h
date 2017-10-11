//
//  NetWorkAction.h
//  RemoteControl
//
//  Created by olami on 2017/8/4.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetworkCompleteHandler)(id result);
typedef void(^NetworkCompleteError)(NSError *error);
@interface NetWorkAction : NSObject
//+ (NetWorkAction*)shareInstance;
- (void)postHttp:(NSString *)httpUrl postData:(NSDictionary *)data complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError;
- (void)downLoad:(NSString *)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError;
- (void)getHttp:(NSString*)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError;

@end
