//
//  WavToMp3Controller.m
//  RemoteIODemo
//
//  Created by JIANHUI on 2017/11/1.
//  Copyright © 2017年 HaiLife. All rights reserved.
//

#import "WavToMp3Controller.h"
#import "LameConver.h"
#import <AVFoundation/AVFoundation.h>
@interface WavToMp3Controller () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *fileArray;

@property (nonatomic, copy) NSString *wavPath;
@property (nonatomic, copy) NSString *mp3Path;

@end

@implementation WavToMp3Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isPlaying = NO;
    
    [self loadFile];
    
    [self setupUI];
}

- (void)loadFile {
    _wavPath = [[NSBundle mainBundle] pathForResource:@"test_wav" ofType:@"wav"];
    _mp3Path = [[NSString alloc] initWithFormat:@"%@/Documents/wav_to_mp3.mp3",NSHomeDirectory()];
    
    _fileArray = [[NSMutableArray alloc] init];
    [_fileArray addObject:@"test_wav.wav"];
}

- (void)setupUI {
    self.navigationItem.title = @"WavToMp3";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(8, 20, 100, 50);
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    CGSize screenSize = [UIApplication sharedApplication].keyWindow.screen.bounds.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backBtn.frame), screenSize.width, screenSize.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UILabel *head = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 100)];
    head.text = @"点击WAV文件转换为MP3，点击MP3文件开始播放";
    head.numberOfLines = 0;
    _tableView.tableHeaderView = head;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    cell.textLabel.text = _fileArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LameConver *conver = [[LameConver alloc] init];
        [conver converWav:_wavPath toMp3:_mp3Path successBlock:^{
            NSLog(@"转码成功");
            [_fileArray addObject:@"wav_to_mp3.mp3"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }]; 
    } else if (indexPath.row == 1){
        [self playMp3];
    }
}

- (void)dismiss {
    if (_isPlaying) {
        [_player stop];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)playMp3 {
//    if (_isPlaying) {
//        NSLog(@"播放中...");
//        return;
//    }
    
    NSURL *url = [NSURL URLWithString:_mp3Path];
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!error) {
        [_player play];
        _isPlaying = true;
    } else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
