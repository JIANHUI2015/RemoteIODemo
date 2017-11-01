//
//  RecordTool.h
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol RecordToolDelegate
- (void)gotData:(AudioBuffer)ioData;
@end

@interface RecordTool : NSObject
@property (nonatomic, weak) id<RecordToolDelegate> delegate;
- (void)start;
- (void)stop;
@end
