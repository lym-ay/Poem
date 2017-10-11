//
//  NetWorkAction.m
//  RemoteControl
//
//  Created by olami on 2017/8/4.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "NetWorkAction.h"
#import "AFNetworking.h"

@implementation NetWorkAction
//+ (NetWorkAction*)shareInstance {
//    static NetWorkAction *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[NetWorkAction alloc] init];
//    });
//    
//    return instance;
//}


- (void)getHttp:(NSString *)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",@"application/x-javascript",nil];
    
    
    [manager GET:httpUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
             NSLog(@"%@",[r allHeaderFields]);
             handler(responseObject);
             
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             handleError(error);
             
             
         }];
    
}



- (void)postHttp:(NSString *)httpUrl postData:(NSDictionary *)data complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间为5秒
    //[manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 5.0f;
    //[manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    
    
    [manager POST:httpUrl parameters:data progress:^(NSProgress * _Nonnull uploadProgress) {
    
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handleError(error);
    }];

}

 

- (void)downLoad:(NSString *)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.确定请求的URL地址
    NSURL *url = [NSURL URLWithString:httpUrl];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
        // NSLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *path = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:response.suggestedFilename];
        
        //下载文件的存储目录
        return [NSURL fileURLWithPath:path];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完成调用的方法
        //NSLog(@"下载完成：");
        //NSLog(@"%@--%@",response,filePath);
      
        //NSLog(@"filePath1 is %@",filePath);
        if (error) {
            handleError(error);
        }else {
            handler([filePath path]);
        }
        
    }];
    
    //开始启动任务
    [task resume];

}
@end
