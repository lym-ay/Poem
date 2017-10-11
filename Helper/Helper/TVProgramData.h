//
//  TVProgramData.h
//  RemoteControl
//
//  Created by olami on 2017/7/3.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

//保存电视节目的信息

#import <Foundation/Foundation.h>

@interface TVProgramData : NSObject
@property (nonatomic, copy) NSString *program_type;         //节目大分类
@property (nonatomic, copy) NSString *program_subtype;      //节目小分类
@property (nonatomic, copy) NSString *channel_id;           //频道ID
@property (nonatomic, copy) NSString *channel_title;        //频道名称
@property (nonatomic, copy) NSString *program_id;           //节目ID
@property (nonatomic, copy) NSString *program_title;        //节目名称
@property (nonatomic, copy) NSString *ctrl_number;          //遥控器对应的节目号
@property (nonatomic, copy) NSString *start_time;           //节目播放开始时间
@property (nonatomic, copy) NSString *end_time;             //节目播放结束时间
@property (nonatomic, copy) NSString *episode_number;       //节目第几集

@end
