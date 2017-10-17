//
//  PoemData.h
//  RemoteControl
//
//  Created by olami on 2017/10/12.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoemData : NSObject
//+ (PoemData*)sharedPoemData;
//按照诗名查询诗歌
- (NSArray *)searchPoemofTitle:(NSString*)title;//通过名称查询诗歌
//根据诗人和诗歌查询诗歌
- (NSArray *)searchAuthorAndTitle:(NSString*)author title:(NSString*)title;
 
//随机查询诗歌
- (NSArray *)searchPoem;

//按照朝代查询诗人
- (NSArray *)searchPoetOfDynasty:(NSString*)dynasty;
//按照诗歌内容查询诗人
- (NSArray *)searchPoetOfContent:(NSString*)content;
//按照诗名查询诗人
- (NSArray *)searchPoetOfPoem:(NSString*)poem;


//按照诗歌内容查询诗歌
- (NSArray *)searchPoemOfContent:(NSString*)content;
//按照诗人查询诗歌
- (NSArray *)searchPoemOfPoet:(NSString*)poet;
//按照朝代查询诗歌
- (NSArray *)searchPoemOfDynasty:(NSString*)dynasty;


@end


