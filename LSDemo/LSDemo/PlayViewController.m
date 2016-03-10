//
//  PlayViewController.m
//  LSDemo
//
//  Created by liulei10 on 16/03/09.
//  Copyright © 2016 SAE. All rights reserved.
//

#import "PlayViewController.h"
#import "LiveStreamPlayer.h"

@interface PlayViewController ()<LiveStreamPlayerDelegate>
{
    BOOL isPlaying;
}
@property (weak, nonatomic) IBOutlet LiveStreamPlayer *playerView;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerView.delegate = self;
    [self.playerView setupTubeId:self.tubeId];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)statusChanged:(LSPlayerStatus)status
{
    NSLog(@"status changed: %ld",status);
    if (status == LSPlayerStatusIniting) {
        self.statusButton.enabled = NO;
        isPlaying = NO;
        [self.statusButton setTitle:@"加载中" forState:UIControlStateDisabled];
    } else if (status == LSPlayerStatusInited) {
        self.title = self.playerView.tubeName;
        isPlaying = YES;
        [self.playerView play];
        [self.statusButton setTitle:@"缓冲中" forState:UIControlStateDisabled];
    } else if (status == LSPlayerStatusReadyToPlay) {
        self.statusButton.enabled = YES;
        [self.statusButton setTitle:@"暂停" forState:UIControlStateNormal];
    } else if (status == LSPlayerStatusFailed) {
        self.statusButton.enabled = NO;
        [self.statusButton setTitle:@"加载失败" forState:UIControlStateDisabled];
    } else if (status == LSPlayerStatusInitFailed) {
        self.statusButton.enabled = NO;
        [self.statusButton setTitle:@"初始化失败" forState:UIControlStateDisabled];
    } else if (status == LSPlayerStatusUnknow) {
        self.statusButton.enabled = NO;
        [self.statusButton setTitle:@"未知状态" forState:UIControlStateDisabled];
    }
}
- (IBAction)statusAction:(id)sender {
    isPlaying = !isPlaying;
    [self updateStatus];
}

-(void)updateStatus
{
    if (isPlaying) {
        [self.playerView play];
        [self.statusButton setTitle:@"暂停" forState:UIControlStateNormal];
    } else {
        [self.playerView pause];
        [self.statusButton setTitle:@"播放" forState:UIControlStateNormal];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
