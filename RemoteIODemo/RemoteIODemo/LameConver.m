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
    
    FILE *file = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+");
    
    fwrite(mp3buffer, recvLen, 1, file);
    fclose(file);
}

- (void)converWav:(NSString *)wavPath toMp3:(NSString *)mp3Path successBlock:(successBlock)block{
    
    @try {
        FILE *fwav = fopen([wavPath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        fseek(fwav, 1024*4, SEEK_CUR); //跳过源文件的信息头，不然在开头会有爆破音
        FILE *fmp3 = fopen([mp3Path cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0); //设置wav的采样率
        lame_set_num_channels(lame, 2); //声道，不设置默认为双声道
//        lame_set_mode(lame, 0);
        lame_init_params(lame);
        
        const int PCM_SIZE = 640 * 2; //双声道*2 单声道640即可
        const int MP3_SIZE = 8800; //计算公式wav_buffer.length * 1.25 + 7200
        short int pcm_buffer[PCM_SIZE];
        unsigned char mp3_buffer[MP3_SIZE];
        
        int read, write;
        
        do {
            read = fread(pcm_buffer, sizeof(short int), PCM_SIZE, fwav);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
//                write = lame_encode_buffer(lame, pcm_buffer, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read/2, mp3_buffer, MP3_SIZE);
//                write = lame_encode_buffer_float(lame, pcm_buffer, pcm_buffer, read/2, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, fmp3);
        } while (read != 0);
        lame_close(lame);
        fclose(fmp3);
        fclose(fwav);
    } @catch (NSException *exception) {
        NSLog(@"catch exception");
    } @finally {
        block();
    }
    
    
}

- (void)dealloc {
    lame_close(lame);
}

@end
