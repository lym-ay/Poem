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
#import "PoemData.h"

#define OLACUSID   @"11a4afa5-d461-47f6-917b-8f8eaa9cb526"





@interface VoiceView () <OlamiRecognizerDelegate> {
    OlamiRecognizer *olamiRecognizer;
    
}


@property (strong, nonatomic) NSMutableDictionary *slotDic;//保存slot的值
@property (copy, nonatomic)   NSString *api;
@property (assign, nonatomic) long start_time;
@property (assign, nonatomic) long end_time;


@property (nonatomic, strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong)  UIView *voiceWaveParentView;
@property (nonatomic, strong) PoemData *poemData;


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
    _slotDic = [[NSMutableDictionary alloc] init];
    
    _poemData =[[PoemData alloc] init];
   
    
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
    NSArray *arry;
    if ([str isEqualToString:@"play"]) {
        _poemAction = PLAYPOEM;
        if (_slotDic.count != 0) {
            //根据slot的值进行处理
            switch (_slotDic.count) {
                case 1:{
                   
                    if ([_slotDic.allKeys containsObject:@"poem"]) {
                        NSString *value = [_slotDic objectForKey:@"poem"];
                        arry =[_poemData searchPoemofTitle:value];
                        
                    }else if ([_slotDic.allKeys containsObject:@"poet"]){
                        NSString *value = [_slotDic objectForKey:@"poet"];
                        arry =[_poemData searchPoemOfPoet:value];
                       
                    }else if ([_slotDic.allKeys containsObject:@"dynasty"]){
                        NSString *value = [_slotDic objectForKey:@"dynasty"];
                        arry =[_poemData searchPoemOfDynasty:value];
                        
                    }
                }
                    
                    break;
                case 2:{
                    if ([_slotDic.allKeys containsObject:@"poem"]
                          && [_slotDic.allKeys containsObject:@"poet"])  {
                        NSString *poem = _slotDic[@"poem"];
                        NSString *poet = _slotDic[@"poet"];
                        arry =[_poemData searchAuthorAndTitle:poet title:poem];
                     
               
                    }else  if ([_slotDic.allKeys containsObject:@"dynasty"]) {
                            NSString *dynasty = _slotDic[@"dynasty"];
                            arry =[_poemData searchPoemOfDynasty:dynasty];
                       
                        
                    }
                }
                    
                    break;
                    
                default:
                    break;
            }
            
        }else{//如果slot的值为空，则是随机选取10首诗歌发出去
            arry = [_poemData searchPoem];
        }
        
        NSDictionary *dic;
        if (arry.count != 0) {
            NSInteger count = arry.count;
            NSInteger index = arc4random()%count;
            dic = arry[index];
        }
        [self.delegate onResult:dic];
       
    }else if ([str isEqualToString:@"query_poet"]){//查询诗人
        _poemAction = QUERYPOET;
        if ([_slotDic.allKeys containsObject:@"dynasty"]) {
             NSString *value = _slotDic[@"dynasty"];
            arry =[_poemData searchPoetOfDynasty:value];
        }else if ([_slotDic.allKeys containsObject:@"content"]) {
            NSString *value = _slotDic[@"content"];
             arry =[_poemData searchPoetOfContent:value];
        }else if ([_slotDic.allKeys containsObject:@"poet"]) {
            NSString *value = _slotDic[@"poet"];
            arry =[_poemData searchPoetOfContent:value];
        }
        
        NSArray *resultArray = [self processResult:arry type:@"author"];
        
        [self.delegate queryResult:resultArray];
        
    }else if ([str isEqualToString:@"query_poem"]){//查询诗歌
        _poemAction = QUERYPOEM;
        if ([_slotDic.allKeys containsObject:@"dynasty"]) {
            NSString *value = _slotDic[@"dynasty"];
           
            arry =[_poemData searchPoemOfDynasty:value];
        }else if ([_slotDic.allKeys containsObject:@"content"]) {
             NSString *value = _slotDic[@"content"];
            
            arry =[_poemData searchPoemOfContent:value];
        }else if ([_slotDic.allKeys containsObject:@"poet"]) {
             NSString *value = _slotDic[@"poet"];
            arry =[_poemData searchPoemOfPoet:value];
        }
        
        NSArray *resultArray = [self processResult:arry type:@"title"];
        
        [self.delegate queryResult:resultArray];

        
        
            
    }else if ([str isEqualToString:@"query_poet_poem"]){//根据诗人和作品查询
        _poemAction = PLAYPOEM;
        NSString *poem = _slotDic[@"poem"];
        NSString *poet = _slotDic[@"poet"];
        arry =[_poemData searchAuthorAndTitle:poet title:poem];
        
        NSDictionary *dic;
        if (arry.count != 0) {
            NSInteger count = arry.count;
            NSInteger index = arc4random()%count;
            dic = arry[index];
        }
        [self.delegate onResult:dic];

            
    }
    
    
   
    
    
}


- (NSArray*)processResult:(NSArray*)result type:(NSString*)type{
    NSMutableArray *arry = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in result) {
        NSString *value = dic[type];
        [arry addObject:value];
    }
    
    return arry;
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
        [self.delegate intputString:input];
    }
    
    NSArray *slot = [semanticDic objectForKey:@"slots"];
    
    [_slotDic removeAllObjects];
    if (slot.count != 0) {
        for (NSDictionary *dic in slot) { 
            NSString* name = [dic objectForKey:@"name"];
            NSString* value = [dic objectForKey:@"value"];
            [_slotDic setObject:value forKey:name];//保存slot的值和value
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



- (void)sendText:(NSString *)text  {
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
