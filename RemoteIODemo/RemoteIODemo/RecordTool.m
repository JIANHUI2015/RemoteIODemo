//
//  RecordTool.m
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import "RecordTool.h"
#import "LameConver.h"

#define kInputBus 1
#define kOutputBus 0
@interface RecordTool()
{
    AVAudioSession *audioSession;
    AUGraph auGraph;
    AudioUnit remoteIOUnit;
    AUNode remoteIONode;
    AURenderCallbackStruct inputProc;
    NSMutableData *mData;
    
    LameConver *cover;
    NSString *outPath;
    AVPlayer *player;
}
@end

@implementation RecordTool

static OSStatus CallBack(
                            void						*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp 		*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList 			*ioData)
{
    RecordTool *THIS=(__bridge RecordTool*)inRefCon;
    OSStatus renderErr = AudioUnitRender(THIS->remoteIOUnit, ioActionFlags,
                                         inTimeStamp, 1, inNumberFrames, ioData);
    
    [THIS->cover convertPcmToMp3:ioData->mBuffers[0] toPath:THIS->outPath];
    [THIS.delegate gotData:ioData->mBuffers[0]];
    return renderErr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initRemoteIO];
        [self initLame];
    }
    return self;
}

- (void)initLame {
    cover = [[LameConver alloc] init];
    outPath = [[NSString alloc] initWithFormat:@"%@/Documents/test.mp3",NSHomeDirectory()];
}

- (void)initRemoteIO
{
    audioSession = [AVAudioSession sharedInstance];
    
    NSError *error;
    // set Category for Play and Record
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setPreferredSampleRate:(double)44100.0 error:&error];
    [audioSession setPreferredInputNumberOfChannels:1 error:&error];

    //init RemoteIO
    CheckError(NewAUGraph(&auGraph),"couldn't NewAUGraph");
    CheckError(AUGraphOpen(auGraph),"couldn't AUGraphOpen");
    
    AudioComponentDescription componentDesc;
    componentDesc.componentType = kAudioUnitType_Output;
    componentDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDesc.componentFlags = 0;
    componentDesc.componentFlagsMask = 0;
    
    CheckError (AUGraphAddNode(auGraph,&componentDesc,&remoteIONode),"couldn't add remote io node");
    CheckError(AUGraphNodeInfo(auGraph,remoteIONode,NULL,&remoteIOUnit),"couldn't get remote io unit from node");
    
    //set BUS
    UInt32 oneFlag = 1;
    CheckError(AudioUnitSetProperty(remoteIOUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Output,
                                    kOutputBus,
                                    &oneFlag,
                                    sizeof(oneFlag)),"couldn't kAudioOutputUnitProperty_EnableIO with kAudioUnitScope_Output");
    
    CheckError(AudioUnitSetProperty(remoteIOUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &oneFlag,
                                    sizeof(oneFlag)),"couldn't kAudioOutputUnitProperty_EnableIO with kAudioUnitScope_Input");
    
    AudioStreamBasicDescription mAudioFormat;
    mAudioFormat.mSampleRate         = 44100.0;//采样率
    mAudioFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
    mAudioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    mAudioFormat.mFramesPerPacket    = 1;//每个数据包多少帧
    mAudioFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
    mAudioFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
    mAudioFormat.mBytesPerFrame      = mAudioFormat.mBitsPerChannel*mAudioFormat.mChannelsPerFrame/8;//每帧的bytes数
    mAudioFormat.mBytesPerPacket     = mAudioFormat.mBytesPerFrame*mAudioFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
    mAudioFormat.mReserved           = 0;
    UInt32 size = sizeof(mAudioFormat);
    
    CheckError(AudioUnitSetProperty(remoteIOUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    1,
                                    &mAudioFormat,
                                    size),"couldn't set kAudioUnitProperty_StreamFormat with kAudioUnitScope_Output");
    
    CheckError(AudioUnitSetProperty(remoteIOUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &mAudioFormat,
                                    size),"couldn't set kAudioUnitProperty_StreamFormat with kAudioUnitScope_Input");
    
    inputProc.inputProc = CallBack;
    inputProc.inputProcRefCon = (__bridge void *)(self);
    CheckError(AUGraphSetNodeInputCallback(auGraph, remoteIONode, 0, &inputProc),"Error setting io output callback");

    CheckError(AUGraphInitialize(auGraph),"couldn't AUGraphInitialize" );
    CheckError(AUGraphUpdate(auGraph, NULL),"couldn't AUGraphUpdate" );
}

- (void)start {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    if ([fileMgr fileExistsAtPath:outPath]) {
        [fileMgr removeItemAtPath:outPath error:&error];
        NSLog(@"删除mp3文件");
    }
    
    CheckError(AUGraphStart(auGraph),"couldn't AUGraphStart");
    CAShow(auGraph);
}

- (void)stop {
    CheckError(AUGraphStop(auGraph), "couldn't AUGraphStop");
}

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    exit(1);
    
}

@end
