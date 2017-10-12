//
//  VoiceView.m
//  RemoteControl
//
//  Created by olami on 2017/7/20.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "VoiceView.h"
#import "Macro.h"
#import "OlamiRecognizer.h"
#import "YSCVolumeQueue.h"
#import "YSCVoiceWaveView.h"

#define OLACUSID   @"11a4afa5-d461-47f6-917b-8f8eaa9cb526"


typedef NS_ENUM(NSInteger, ProgramType) {
    CHANNEL,
    PROGRAMTYPE,
    PROGRAMSUBTYPE,
    PROGRAMTIME
};


@interface VoiceView () <OlamiRecognizerDelegate> {
    OlamiRecognizer *olamiRecognizer;
    
}

@property (strong, nonatomic) NSMutableArray *slotValue;//保存slot的值
@property (strong, nonatomic) NSMutableDictionary *slotDic;//保存slot的值
@property (copy, nonatomic) NSString *api;
@property (assign, nonatomic) long start_time;
@property (assign, nonatomic) long end_time;


@property (nonatomic, strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong)  UIView *voiceWaveParentView;


@end

@implementation VoiceView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupData];
        [self setupUI];
    }
    
    return self;
}




- (void)setupData {
    olamiRecognizer= [[OlamiRecognizer alloc] init];
    olamiRecognizer.delegate = self;
    [olamiRecognizer setAuthorization:@"bec0655e51074da2b1203fc2754114c5"
                                  api:@"asr" appSecret:@"31ed879d6d154823bf8fe94ef622a855" cusid:OLACUSID];
    
    [olamiRecognizer setLocalization:LANGUAGE_SIMPLIFIED_CHINESE];//设置语系，这个必须在录音使用之前初始化
    
    _slotValue = [[NSMutableArray alloc] init];
    _slotDic = [[NSMutableDictionary alloc] init];
    //接受搜索框发过来的文本
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchText:) name:@"searchText" object:nil];
}


- (void)setupUI {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, Kwidth, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR(255, 255, 255, 1);
    label.font = [UIFont fontWithName:FONTFAMILY size:18];
    label.text = @"说一下你想查的古诗的名字或者作者";
    [self addSubview:label];
    
    
    [self insertSubview:self.voiceWaveParentView atIndex:0];
    [self.voiceWaveView showInParentView:self.voiceWaveParentView];
    [self.voiceWaveView startVoiceWave];

}


- (void)backAction:(UIButton *)button {
    self.block();
}

- (void)okAction:(UIButton *)button {
    
}

- (void)start {
    [olamiRecognizer start];
}

- (void)stop {
    if (olamiRecognizer.isRecording) {
        [olamiRecognizer stop];
    }
}

- (BOOL)isRecording{
    return [olamiRecognizer isRecording];
}
- (void)onResult:(NSData *)result {
    NSError *error;
    __weak typeof(self) weakSelf = self;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:result
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if (error) {
        NSSLog(@"error is %@",error.localizedDescription);
    }else{
        NSString *jsonStr=[[NSString alloc]initWithData:result
                                               encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr is %@",jsonStr);
        NSString *ok = [dic objectForKey:@"status"];
        if ([ok isEqualToString:@"ok"]) {
            NSDictionary *dicData = [dic objectForKey:@"data"];
            NSDictionary *asr = [dicData objectForKey:@"asr"];
            if (asr) {//如果asr不为空，说明目前是语音输入
                [weakSelf processASR:asr];
            }
            NSDictionary *nli = [[dicData objectForKey:@"nli"] objectAtIndex:0];
            NSDictionary *desc = [nli objectForKey:@"desc_obj"];
            int status = [[desc objectForKey:@"status"] intValue];
            if (status != 0) {// 0 说明状态正常,非零为状态不正常或者result为空
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noresult" object:nil userInfo:nil]];
                
            }else{
                NSDictionary *semantic = [[nli objectForKey:@"semantic"]
                                          objectAtIndex:0];
                [weakSelf processSemantic:semantic];
                
            }
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noresult" object:nil userInfo:nil]];
        }
    }
    
    
    
}

- (void)onBeginningOfSpeech {
    [self.delegate onBeginningOfSpeech];
}

- (void)onEndOfSpeech {
    [self.delegate onEndOfSpeech];
    
}


- (void)onError:(NSError *)error {
    [self.delegate onError:error];
}

-(void)onCancel {
    [self.delegate onCancel];
}

- (void)voiceRecognizeFailure {
    [self.delegate voiceFailure];
}

- (void)voiceRecognizeSuccess {
    [self.delegate voiceSuccess];
}


#pragma mark -- 处理语音和语义的结果

//处理modify
- (void)processModify:(NSString*) str {
    NSDictionary *resultDic;//保存传输的结果
    if ([str isEqualToString:@"query_parade_name"]
        || [str isEqualToString:@"watch_channel"]
       ) {//查看那个频道
        NSString *channelName = _slotValue[0];
        if (channelName) {
            resultDic = @{@"channel":channelName};
            
            
            
        }
       
       
    }else if ([str isEqualToString:@"rules"]){
        
        
    }else if ([str isEqualToString:@"query_tvplay"]||
              [str isEqualToString:@"can_tvplay"]||
              [str isEqualToString:@"recommend_tvplay"]||
              [str isEqualToString:@"recommend_new_tvplay"]||
              [str isEqualToString:@"query_tvplay_play"]
              ){//询问分类
        if (_slotDic.count != 0) {
            for (NSString *name in _slotDic.allKeys) {
                //节目分类
                if ([name isEqualToString:@"type"]) {//我要看言情剧
                    NSString *value = [_slotDic objectForKey:name];
                    resultDic = @{@"program_subtype":value};
                    
                }else if ([name isEqualToString:@"area"]) {//我要看美剧之类的，按照地区分类
                    NSString *value = [_slotDic objectForKey:name];
                    resultDic = @{@"program_subtype":value};
                }
            }
        }else{//我要看电视剧之类的大分类
            resultDic = @{@"program_type":@"电视剧"};
        }
        
        
    }
    ////////////query_tvshow modify////////////////////////
    else if ([str isEqualToString:@"query_tvshow"]||
             [str isEqualToString:@"recommend_tvshow"]||
             [str isEqualToString:@"can_tvshow"]||
             [str isEqualToString:@"recommend_new_tvshow"]||
             [str isEqualToString:@"query_tvshow_play"]){
        if (_slotDic.count != 0) {
            for (NSString *name in _slotDic.allKeys) {
                //节目分类
                if ([name isEqualToString:@"program_classify"]) {
                    NSString *value = [_slotDic objectForKey:name];
                    resultDic = @{@"program_subtype":value};
                }
            }
        }
        
    }else if ([str isEqualToString:@"query_tvshow_play"]){
        if (_slotDic.count != 0) {
            for (NSString *name in _slotDic.allKeys) {
                //节目分类
                if ([name isEqualToString:@"program_classify"]) {//分类
                    NSString *value = [_slotDic objectForKey:name];
                    resultDic = @{@"program_subtype":value};
                }else if ([name isEqualToString:@"area"]) {//我要看美剧之类的，按照地区分类
                    NSString *value = [_slotDic objectForKey:name];
                    resultDic = @{@"program_subtype":value};
                }
            }
        }
    }
    
    else if ([str isEqualToString:@"watch_a_program"]){//查看具体的节目
       
    }
    /////////////////////换台//////////////////////////////////////
    else if ([str isEqualToString:@"flip_number"]){//转到xx台
        

    }else if ([str isEqualToString:@"flip_channel_next"]){//下一个台
        

        
    }else if ([str isEqualToString:@"flip_channel_last"]){//上一个台
        

    }else if ([str isEqualToString:@"flip_channel"]){//换一个台
        
        
    }
    ///////////////控制音量/////////////////////////////
    else if ([str isEqualToString:@"turn_volume_up"]){//声音调大一点
       
    }else if ([str isEqualToString:@"turn_volume_down"]){//声音调小一点
        
    }else if ([str isEqualToString:@"turn_volume_muteon"]){//设为静音
        
    }
    ///////////////按照时间段来查询节目////////////////////
    else if ([str isEqualToString:@"query_parade_name_time"]){
        
    }
    //////////////菜单功能////////////////////
    else if ([str isEqualToString:@"function"]){
        
    }
  //////////////电影/////////////
    else if ([str isEqualToString:@"query_movie"]||
             [str isEqualToString:@"recommend"]||
             [str isEqualToString:@"recommend_new "]||
             [str isEqualToString:@"recommend_cinema"]||
             [str isEqualToString:@"can"]){
        resultDic = @{@"program_type":@"电影"};
    }
   
    //把识别的结果发出去
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"voiceValue" object:resultDic userInfo:nil]];

    
}
 


#pragma mark--slot节点处理函数
//菜单功能处理函数
- (void)processFunction {
    
}

 

//处理ASR节点
- (void)processASR:(NSDictionary*)asrDic {
    NSString *result  = [asrDic objectForKey:@"result"];
    if (result.length == 0) { //如果结果为空，则弹出警告框
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noresult" object:nil userInfo:nil]];
    } 
    
}

//处理Semantic节点
- (void)processSemantic:(NSDictionary*)semanticDic {
    NSString *input = [semanticDic objectForKey:@"input"];
    if (input) {
        
    }
    
    NSArray *slot = [semanticDic objectForKey:@"slots"];
    [_slotValue removeAllObjects];
    [_slotDic removeAllObjects];
    if (slot.count != 0) {
        for (NSDictionary *dic in slot) {
            NSString* name = [dic objectForKey:@"name"];
            NSString* val = [dic objectForKey:@"value"];
            [_slotDic setObject:val forKey:name];//保存slot的值和value
            [_slotValue addObject:val];
            NSDictionary *datetime = [dic objectForKey:@"datetime"];
            if (datetime) {
                NSString *type = [datetime objectForKey:@"type"];
                if ([type isEqualToString:@"time_recommend"]) {
                    
                }
                
                NSDictionary *data = [datetime objectForKey:@"data"];
                _start_time = [[data objectForKey:@"start_time"] longValue];
                _end_time = [[data objectForKey:@"end_time"] longValue];
                
            }
        }
        
        
        
    }
    
    NSArray *modify = [semanticDic objectForKey:@"modifier"];
    if (modify.count != 0) {
        for (NSString *s in modify) {
            [self processModify:s];
            
        }
        
    }
    
}

//调节声音
- (void)onUpdateVolume:(float)volume {
     CGFloat normalizedValue = volume/100;
    [_voiceWaveView changeVolume:normalizedValue];

}



- (void)searchText:(NSNotification*)id {
    NSString *text = (NSString*)id.object;
    [olamiRecognizer sendText:text];
}



//#############################################
- (YSCVoiceWaveView *)voiceWaveView
{
    if (!_voiceWaveView) {
        self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
    }
    
    return _voiceWaveView;
}

- (UIView *)voiceWaveParentView
{
    if (!_voiceWaveParentView) {
        self.voiceWaveParentView = [[UIView alloc] init];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _voiceWaveParentView.frame = CGRectMake(0, -10 , screenSize.width, 200*nKheight);
       
    }
    
    return _voiceWaveParentView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
