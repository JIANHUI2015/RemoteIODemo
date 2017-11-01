//
//  LameConver.h
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^successBlock)();
@interface LameConver : NSObject

/**
 PCM流转MP3文件

 @param pcmbuffer pcmbuffer
 @param path 输入路径
 */
- (void)convertPcmToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path;

/**
 wav文件转mp3文件

 @param wavPath wav文件路径（输入）
 @param mp3Path mp3文件路径（输出）
 */
- (void)converWav:(NSString *)wavPath toMp3:(NSString *)mp3Path successBlock:(successBlock)block;
@end
