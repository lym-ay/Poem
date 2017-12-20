//
//  OlamiRecognizer.h
//  OlamiRecognizer
//
//  Copyright 2017, VIA Technologies, Inc. & OLAMI Team.
//
//  http://olami.ai
//


#define Version 1.3.6

#import <Foundation/Foundation.h>

@protocol OlamiRecognizerDelegate <NSObject>

@optional
/**
 * Callback when recognition result returned
 */
- (void)onResult:(NSData*)result;
/*
 * Callback when process cancelled
 */
- (void)onCancel;


/*
 * Callback when error occurred
 */
- (void)onError:(NSError *)error;

/*
 * Callback when speech volume changed.
 * The value will be 0 to 100.
 */
- (void)onUpdateVolume:(float) volume;

/***
 * Callback when voice recording started
 */
- (void)onBeginningOfSpeech;

/**
 * Callback when voice recording stopped
 *
 */
- (void)onEndOfSpeech;

/**
 * Callback when ASR failure
 *
 */
- (void)voiceRecognizeFailure;

/**
 * Callback when ASR Success
 *
 */
- (void)voiceRecognizeSuccess;
@end

typedef NS_ENUM(NSInteger, LanguageLocalization) {
    LANGUAGE_SIMPLIFIED_CHINESE = 0, //简体中文
    LANGUAGE_TRADITIONA_CHINESE = 1  //繁體中文
};



@interface OlamiRecognizer : NSObject
@property (nonatomic, weak) id<OlamiRecognizerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isRecording;//Check if voice recording is running
@property (nonatomic, assign, readonly) BOOL isRecognizing;//Check if ASR is running
- (void)start;//Start voice recording
- (void)stop;//Stop voice recording
- (void)cancel;//Cancel current process
//Set the language
- (void)setLocalization:(LanguageLocalization)location;
/**
 *CUSID;//End-user identifier.
 *appKey;//The 'APP KEY' you have, provided by OLAMI developer service.
 *api;//API name.
 *appSecret;//The 'APP SECRET' you have, provided by OLAMI developer service.
 */
- (void)setAuthorization:(NSString*)appKey api:(NSString*)api appSecret:(NSString*)appSecret cusid:(NSString*)CUSID;
- (void)setVADTimeoutFrontSIL:(unsigned int)value;//Set timeout of the VAD in milliseconds to stop voice recording automatically. The vaule will be 1000 to 10000, default is 3000.
- (void)setVADTimeoutBackSIL:(unsigned int)value;//Set timeout of the VAD in milliseconds to stop voice recording automatically. The vaule will be 1000 to 10000, default is 2000.
- (void)setInputType:(int) type;//Set 0 for text input, 1 for voice input.
- (void)setLatitudeAndLongitude:(double) latitude longitude:(double)longit;//Set latitude and longitude information
- (void)sendText:(NSString*)text;//Send text to get NLU recognition result.
@end

