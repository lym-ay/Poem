//
//  WaveService.m
//  SendSignal
//
//  Created by olami on 2017/7/11.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "WaveService.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface WaveService(){
    int duration;
    int sampleRate;
    int numSamples;
    double freOfTone;
    AVAudioPlayer *_audioPlayer;
    

}

@end


#define KAmplitude 32767

/** Data "1" 高电平宽度 */
static  float          INFRARED_1_HIGH_WIDTH = 0.56f ;
/** Data "1" 低电平宽度 */
static float           INFRARED_1_LOW_WIDTH = 1.69f;  // 2.25 - 0.56
/** Data "0" 高电平宽度 */
static float          INFRARED_0_HIGH_WIDTH = 0.56f ;
/** Data "0" 低电平宽度 */
static float           INFRARED_0_LOW_WIDTH = 0.565f ;// 1.125-0.56
/** Leader code 高电平宽度 */
static float INFRARED_LEADERCODE_HIGH_WIDTH = 9.0f  ;
/** Leader code 低电平宽度 */
static float  INFRARED_LEADERCODE_LOW_WIDTH = 4.50f ;
/** Stop bit 高电平宽度 */
static float    INFRARED_STOPBIT_HIGH_WIDTH = 0.56f ;

@implementation WaveService


+ (WaveService*)shareInstance {
    static WaveService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WaveService alloc] init];
    });
    
    return instance;
}

-(id)init {
    if (self = [super init]) {
        duration = 10;
        sampleRate = 44100;
        numSamples = duration *sampleRate;
        freOfTone = 19000;
       
    }
    
    return  self;
}


-(NSData*)getTone:(double) time percent:(float)percent{
    int allNum = (int)(time/1000*sampleRate);
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    for (int i=0; i<allNum; i++) {
         double dVal =(double)(sin(2*M_PI*((double)freOfTone)*((double)i/44100)));
         short val = (short)(dVal*KAmplitude*percent);
         NSData *data = [NSData dataWithBytes:&val length:sizeof(short)];
         [pcmData appendData:data];
         short valMin = (short)(-val);
         NSData *data1 = [NSData dataWithBytes:&valMin length:sizeof(short)];
         [pcmData appendData:data1];
       
    }
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
 
    
    return data2;
}

-(NSData*)getTone {
   NSMutableData *pcmData = [[NSMutableData alloc] init];
   for (int i=0; i<numSamples; i++) {
      double dVal =(double)(sin(2*M_PI*((double)freOfTone)*((double)i/44100)));
      short val = (short)(dVal*KAmplitude);
      NSData *data = [NSData dataWithBytes:&val length:sizeof(short)];
      [pcmData appendData:data];
      short valMin = (short)(-val);
      NSData *data1 = [NSData dataWithBytes:&valMin length:sizeof(short)];
      [pcmData appendData:data1];

      
    }
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;
}

-(NSData*)getLow {
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    NSData *one = [self getTone:INFRARED_0_HIGH_WIDTH percent:1];
    [pcmData appendData:one];
    NSData *two = [self getTone:INFRARED_0_LOW_WIDTH percent:0];
    [pcmData appendData:two];

    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;
}

-(NSData*)getHight{
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    NSData *one = [self getTone:INFRARED_1_HIGH_WIDTH percent:1];
    [pcmData appendData:one];
    NSData *two = [self getTone:INFRARED_1_LOW_WIDTH percent:0];
    [pcmData appendData:two];
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;

}

- (NSData*)getLittleHigh{
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    NSData *one = [self getTone:INFRARED_1_HIGH_WIDTH percent:0.08f];
    [pcmData appendData:one];
    NSData *two = [self getTone:INFRARED_1_LOW_WIDTH percent:0];
    [pcmData appendData:two];
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;

}

-(NSData*)getTou{
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    for (int i=0; i<3; i++) {
        NSData *data = [self getTone:10 percent:0];
        [pcmData appendData:data];
        
        for (int j=1; j<4; j++) {
            NSData *data = [self getLittleHigh];
            [pcmData appendData:data];
        }
        
        NSData *data1 = [self getTone:10 percent:0];
        [pcmData appendData:data1];
    }
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;

}

-(NSData*)getLeaderCode{
   // NSLog(@"leadCode");
    
   
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    NSData *one = [self getTone:INFRARED_LEADERCODE_HIGH_WIDTH percent:1];
    [pcmData appendData:one];
    NSData *two = [self getTone:INFRARED_LEADERCODE_LOW_WIDTH percent:0];
    [pcmData appendData:two];
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;

}

-(NSData*)getUserCodetoWave:(short)userCode {
    //NSLog(@ "UserCode");
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    for (int i=0; i<16; i++) {
        if(((userCode >> i) & 0x1) == 1) { // 1
            NSData *data = [self getHight];
            [pcmData appendData:data];
            
        } else {                           // 0
            NSData *data = [self getLow];
            [pcmData appendData:data];

        }

    }
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;
}

-(NSData*)getDataCodeToWave:(char)dataCode {
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    for (int i=0; i<8; i++) {
        if(((dataCode >> i) & 0x1) == 1) { // 1
            NSData *data = [self getHight];
            [pcmData appendData:data];
            
        } else {                           // 0
            NSData *data = [self getLow];
            [pcmData appendData:data];
            
        }
        
    }
    
    for (int i=0; i<8; i++) {
        if(((dataCode >> i) & 0x1) == 1) { // 1
            NSData *data = [self getLow];
            [pcmData appendData:data];
            
        } else {                           // 0
            NSData *data = [self getHight];
            [pcmData appendData:data];
            
        }
        
    }

    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    
    
    return data2;

}

-(NSData*)getStopBit{
    return [self getTone:INFRARED_STOPBIT_HIGH_WIDTH percent:1];
}

-(NSData*)getRepeatCode{
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    NSData *data0 = [self getTone:110 percent:0];
    [pcmData appendData:data0];
    
    NSData *data1 = [self getTone:9.0 percent:1];
    [pcmData appendData:data1];

    
    NSData *data2 = [self getTone:2.25 percent:0];
    [pcmData appendData:data2];

    
    NSData *data3 = [self getTone:0.56 percent:1];
    [pcmData appendData:data3];
    
    NSData *data4 = [[NSData alloc] initWithData:pcmData];
    
    
    return data4;

}

-(NSData*)getWave:(short)userCode dataCode:(char)dataCode{
    NSMutableData *pcmData = [[NSMutableData alloc] init];
    [pcmData appendData:[self getTou]];
    [pcmData appendData:[self getLeaderCode]];
    [pcmData appendData:[self getUserCodetoWave:userCode]];
    [pcmData appendData:[self getDataCodeToWave:dataCode]];
    [pcmData appendData:[self getStopBit]];
    [pcmData appendData:[self getRepeatCode]];
    [pcmData appendData:[self getTou]];
    
    NSData *data2 = [[NSData alloc] initWithData:pcmData];
    return data2;
    
}

-(void)addWavHead:(NSMutableData*)wavData FrameSize:(int)nframeSize{
    typedef struct WAVE_HEADER{
        char    fccID[4];       //内容为""RIFF
        unsigned int dwSize;   //最后填写，WAVE格式音频的大小
        char    fccType[4];     //内容为"WAVE"
    }WAVE_HEADER;
    
    typedef struct WAVE_FMT{
        char    fccID[4];          //内容为"fmt "
        unsigned int  dwSize;     //内容为WAVE_FMT占的字节数，为16
        unsigned short wFormatTag; //如果为PCM，改值为 1
        unsigned short wChannels;  //通道数，单通道=1，双通道=2
        unsigned int  dwSamplesPerSec;//采用频率
        unsigned int  dwAvgBytesPerSec;/* ==dwSamplesPerSec*wChannels*uiBitsPerSample/8 */
        unsigned short wBlockAlign;//==wChannels*uiBitsPerSample/8
        unsigned short uiBitsPerSample;//每个采样点的bit数，8bits=8, 16bits=16
    }WAVE_FMT;
    
    typedef struct WAVE_DATA{
        char    fccID[4];       //内容为"data"
        unsigned int dwSize;
    }WAVE_DATA;
    
    WAVE_HEADER pcmHEADER;
    WAVE_FMT    pcmFMT;
    WAVE_DATA   pcmDATA;
    
    /* WAVE_HEADER */
    memcpy(pcmHEADER.fccID, "RIFF", strlen("RIFF"));
    memcpy(pcmHEADER.fccType, "WAVE", strlen("WAVE"));
    pcmHEADER.dwSize = 44+nframeSize;
    [wavData appendBytes:&pcmHEADER length:sizeof(WAVE_HEADER)];
    
    /* WAVE_FMT */
    memcpy(pcmFMT.fccID, "fmt ", strlen("fmt "));
    pcmFMT.dwSize = 16;
    pcmFMT.wFormatTag = 1;//pcm为1
    pcmFMT.wChannels = 2;//单通道1 双通道为2
    pcmFMT.dwSamplesPerSec = 44100;//采样频率44100
    pcmFMT.uiBitsPerSample = 16;//每次采样位数
    /* ==dwSamplesPerSec*wChannels*uiBitsPerSample/8 */
    pcmFMT.dwAvgBytesPerSec = pcmFMT.dwSamplesPerSec*pcmFMT.wChannels*pcmFMT.uiBitsPerSample/8;
    /* ==wChannels*uiBitsPerSample/8 */
    pcmFMT.wBlockAlign = pcmFMT.wChannels*pcmFMT.uiBitsPerSample/8;
    [wavData appendBytes:&pcmFMT length:sizeof(WAVE_FMT)];
    
    
    /* WAVE_DATA */
    memcpy(pcmDATA.fccID, "data", strlen("data"));
    pcmDATA.dwSize = nframeSize;
    
    [wavData appendBytes:&pcmDATA length:sizeof(WAVE_DATA)];
}

-(void)playCode:(short)userCode dataCode:(char)dataCode{
    NSData *pcmData = [self getWave:userCode dataCode:dataCode];
    //给音频数据添加wave头
    NSMutableData *wavData = [[NSMutableData alloc] init];
    [self addWavHead:wavData FrameSize:pcmData.length];
    [wavData appendData:pcmData];
    
    NSError *error;
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }

    //播放音频数据
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:wavData error:&error];
    if (error) {
        NSLog(@"error log is %@",error.localizedDescription);
    }else{
      [_audioPlayer play];
    }

}


- (void)sendSignal:(NSString *)userCode dataCode:(NSString*)dataCode {
    short utfUserCode = (short)strtoul([userCode UTF8String],0,16);//字符串转换为16进制
    char  utfDataCode = (char)strtoul([dataCode UTF8String],0,16);
    [self playCode:utfUserCode dataCode:utfDataCode];
    
}

@end
