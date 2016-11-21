//
//  LameConver.m
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import "LameConver.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>
lame_t lame;
@implementation LameConver

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initLame];
    }
    return self;
}

- (void)initLame {
    lame = lame_init();
    lame_set_in_samplerate(lame, 44100.0);
    lame_set_num_channels(lame, 1);
    lame_set_mode(lame, MONO);
    lame_init_params(lame);
}

- (void)convertPcmToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path{
    int pcmLength = pcmbuffer.mDataByteSize;
    short *bytes = (short *)pcmbuffer.mData;
    int nSamples = pcmLength/2;
    unsigned char mp3buffer[pcmLength];

    int recvLen = lame_encode_buffer(lame, bytes, NULL, nSamples, mp3buffer, pcmLength);
    NSLog(@"pcmLength:%d",pcmLength);
    
    NSLog(@"recvLen-%d",recvLen);
    
    FILE *file = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+");

    fwrite(mp3buffer, recvLen, 1, file);
    fclose(file);
}

- (void)dealloc {
    //释放lame
    lame_close(lame);
}

@end
