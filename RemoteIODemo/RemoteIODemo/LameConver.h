//
//  LameConver.h
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface LameConver : NSObject
- (void)convertPcmToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path;
@end
