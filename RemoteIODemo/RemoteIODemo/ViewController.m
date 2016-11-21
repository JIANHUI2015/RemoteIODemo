//
//  ViewController.m
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import "ViewController.h"
#import "RecordTool.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVAudioPlayerDelegate>
{
    RecordTool *recorder;
    BOOL isRecording;
    
    AVAudioPlayer *player;
    BOOL isPlaying;
}
@property (weak, nonatomic) IBOutlet UILabel *inputLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    isRecording = false;
    recorder = [[RecordTool alloc] init];
    
    isPlaying = false;
    
    /** 2.判断当前的输出源 */
    [self routeChange:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:)
                                                name:AVAudioSessionRouteChangeNotification
                                              object:[AVAudioSession sharedInstance]];
    
    
}

- (void)routeChange:(NSNotification*)notify{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
    for (AVAudioSessionPortDescription *s in [route inputs]) {
        NSLog(@"输入:%@",[s portName]);
        dispatch_async(dispatch_get_main_queue(), ^{
            _inputLabel.text = [[NSString alloc] initWithFormat:@"输入:%@",[s portName]];
        });
        
    }
}
- (IBAction)start:(UIButton *)sender {
    isRecording = !isRecording;
    if (isRecording) {
        [sender setTitle:@"Stop Record" forState:UIControlStateNormal];
        [recorder start];
    } else {
        [sender setTitle:@"Start Record" forState:UIControlStateNormal];
        [recorder stop];
    }
}
- (IBAction)play:(UIButton *)sender {
    if (isRecording) {
        NSLog(@"couldn't play while recording..");
        return;
    }
    
    if (!isPlaying) {
        NSString *path = [[NSString alloc] initWithFormat:@"%@/Documents/test.mp3",NSHomeDirectory()];
        NSURL *url = [NSURL URLWithString:path];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        player.delegate = self;
        if (error != NULL) {
            NSLog(@"error:%@",error);
        } else {
            [player play];
            isPlaying = true;
            [sender setTitle:@"Stop" forState:UIControlStateNormal];
        }
    } else {
        [player stop];
        isPlaying = false;
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_playBtn setTitle:@"Start" forState:UIControlStateNormal];
    isPlaying = false;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
