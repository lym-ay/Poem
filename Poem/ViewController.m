//
//  ViewController.m
//  Poem
//
//  Created by olami on 2017/10/11.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "ViewController.h"
#import "Macro.h"

#import "JMCircleAnimationView.h"
#import "VoiceView.h"
#import "MBProgressHUD.h"


@interface ViewController ()<UITextFieldDelegate,VoiceViewDelegate>{
    MBProgressHUD *hub;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) JMCircleAnimationView* circleView;//语音识别的动画
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIView *voiceBackView;

@property (nonatomic, strong) VoiceView       *voiceView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    [self setupUI];
    
    
    
    
}


- (void)setupUI {
    _voiceView = [[VoiceView alloc] initWithFrame:CGRectMake(0, 0, Kwidth, 128*nKheight)];
    _voiceBackView.backgroundColor = COLOR(24, 49, 69, 1);
    _voiceView.delegate = self;
    [_voiceBackView addSubview:_voiceView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)voiceButton:(id)sender {
    if (self.voiceView.isRecording) {
        [self.voiceView stop];
        
    }else{
        [self.voiceView start];
        
    }
//    NSDictionary *dic =[_poemData searchTitle:@"虞美人·春花秋月何时了"];
//    //NSLog(@"dic is %@",dic);
//    NSString *content = [dic objectForKey:@"content"];
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    
//    
//    _textView.attributedText = attributedString;
}


#pragma mark--懒加载
- (JMCircleAnimationView *)circleView
{
    if (!_circleView) {
        _circleView = [JMCircleAnimationView viewWithButton:self.voiceButton];
        [self.voiceButton addSubview:_circleView];
    }
    return _circleView;
}

#pragma mark --Voice delegate
- (void)onUpdateVolume:(float)volume {
    
}

- (void)onResult:(NSArray *)result {
    //如果是一首诗，直接展示
    if (result.count == 1) {
        NSDictionary *resultDictionary = result[0];
        NSString *title = [resultDictionary objectForKey:@"title"];
        NSString *content = [resultDictionary objectForKey:@"content"];
        NSString *explanation = [resultDictionary objectForKey:@"explanation"];
        NSString *appreciation = [resultDictionary objectForKey:@"appreciation"];
        NSString *author = [resultDictionary objectForKey:@"author"];
        NSString *allString = [NSString stringWithFormat:@"%@\n%@%@%@%@",title,author,content,explanation,appreciation];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[allString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                _textView.attributedText = attributedString;
        });
        
        
    }else{
        for (NSDictionary *resultDictionary in result) {
            NSString *title = [resultDictionary objectForKey:@"title"];
            NSString *author = [resultDictionary objectForKey:@"author"];
        }
    }
}

- (void)onEndOfSpeech {
    //录音结束的时候，让button按钮为空
    [_voiceButton setEnabled:NO];
    [self.circleView startAnimation];
    
}

- (void)onBeginningOfSpeech {
    
}

- (void)onCancel {
    
}

//识别失败
- (void)voiceFailure {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_voiceButton setEnabled:YES];
        [self.circleView removeFromSuperview];
        self.circleView = nil;
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"识别失败！"
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        [self presentViewController:alertController animated:YES completion:^{
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
            });
            
        }];
        
        
    });
    
    
}

//识别成功
- (void)voiceSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.circleView removeFromSuperview];
        self.circleView = nil;
        [_voiceButton setEnabled:YES];
    });
}



- (void)onError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        hub.label.text = @"网络出错，请稍后再试";
        hub.mode = MBProgressHUDModeText;
        [hub showAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hub hideAnimated:YES];
        });
        
    });
    
    if (error) {
        NSSLog(@"voice reconginze error is %@",error.localizedDescription);
    }
}

//弹出对话框，警告用户
- (void)openAlertView {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"没有数据，请重试！"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    [self presentViewController:alertController animated:YES completion:^{
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
        });
        
    }];
}


 

@end
