//
//  VoiceView.h
//  RemoteControl
//
//  Created by olami on 2017/7/20.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//


//这个页面定义了 语音输入的页面
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PoemAction) {
    PLAYPOEM,
    QUERYPOEM,
    QUERYPOET
};

@protocol VoiceViewDelegate <NSObject>

//intputString
- (void)intputString:(NSString*)input;

//返回查询的结果
- (void)queryResult:(NSArray*)arry;

//返回诗歌具体内容
- (void)onResult:(NSDictionary*)result;


//取消本次会话
- (void)onCancel;

//识别失败
- (void)onError:(NSError *)error;

//音量的大小 音频强度范围时0到100
//- (void)onUpdateVolume:(float) volume;


//开始录音
- (void)onBeginningOfSpeech;

//结束录音
- (void)onEndOfSpeech;

//语音识别失败
- (void)voiceFailure;

//语音识别成功
- (void)voiceSuccess;

@end

typedef void (^CloseViewBlock)(void);

@interface VoiceView : UIView
@property (nonatomic, strong) CloseViewBlock block;
@property (nonatomic, weak) id<VoiceViewDelegate> delegate;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) PoemAction poemAction;
- (void)sendText:(NSString*)text;//发送文本请求
- (void)start;
- (void)stop;
 
@end
