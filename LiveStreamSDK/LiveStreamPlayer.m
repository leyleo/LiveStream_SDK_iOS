//
//  LiveStreamPlayer.m
//  Pods
//
//  Created by liulei10 on 16/03/09.
//
//

#import "LiveStreamPlayer.h"
#import "LiveStreamSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

#if DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [L %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

@interface LiveStreamPlayer()
{
    AVPlayerItem *currentItem;
    id timeObserver;
}
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) AVPlayerItem *highItem;
@property(nonatomic, strong) AVPlayerItem *lowItem;
@property(nonatomic, assign) LSPlayerStatus status;
@end

@implementation LiveStreamPlayer

-(instancetype)initWithTubeId:(NSString *)tubeId
{
    self = [super init];
    if (self) {
        [self setupTubeId:tubeId];
    }
    return self;
}

-(void)setupTubeId:(NSString *)tubeId
{
    _tubeId = tubeId;
    [self setupTubeItems];
    [self checkNetwork];
}

-(void)setupTubeItems
{
    self.backgroundColor = [UIColor blackColor];
    [self changeStatusTo: LSPlayerStatusIniting];
    __weak __typeof__(self) weakSelf = self;
    [[LiveStreamSessionManager manager] queryTube:_tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf processResult:responseObject error:error];
    }];
}

-(void)checkNetwork
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
}

-(void)processResult:(id)result error: (NSError *)error
{
    if (error) {
        [self changeStatusTo: LSPlayerStatusInitFailed];
    } else if (result && [result isKindOfClass:[NSDictionary class]]){
        [self configDetails:result];
        if (self.highItem || self.lowItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareToPlay];
            });
        } else {
            [self changeStatusTo: LSPlayerStatusInitFailed];
        }
    } else {
        [self changeStatusTo: LSPlayerStatusInitFailed];
    }
}

-(void)changeStatusTo:(LSPlayerStatus)newStatus
{
    self.status = newStatus;
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusChanged:)]) {
        [self.delegate statusChanged:self.status];
    }
}

-(void)configDetails:(NSDictionary *)detail
{
    if (detail) {
        _tubeId = [detail valueForKey:@"tube_id"];
        _tubeName = [detail valueForKey:@"name"];
        _tubeDescription = [detail valueForKey:@"description"];
        NSDictionary *playUrl = [detail objectForKey:@"play_url"];
        NSString *highUrl = playUrl ? [playUrl valueForKey:@"hls_origin"] : nil;
        NSString *lowUrl = playUrl ? [playUrl valueForKey:@"hls_low"] : nil;
        if (highUrl && ![highUrl hasPrefix:@"http"]) {
            highUrl = [NSString stringWithFormat:@"http://%@",highUrl];
        }
        _highItem = highUrl ? [AVPlayerItem playerItemWithURL:[NSURL URLWithString:highUrl]] : nil;
        if (lowUrl && ![lowUrl hasPrefix:@"http"]) {
            lowUrl = [NSString stringWithFormat:@"http://%@",lowUrl];
        }
        _lowItem = lowUrl ? [AVPlayerItem playerItemWithURL:[NSURL URLWithString:lowUrl]] : nil;
        self.lowItem ? [self.lowItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil] : nil;
        self.highItem ? [self.highItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil] : nil;
#if DEBUG
        self.highItem ? [self.highItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil] : nil;
        self.lowItem ? [self.lowItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil] : nil;
#endif
    }
}

-(void)prepareToPlay
{
    if (self.player) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
        if (timeObserver) {
            [self.player removeTimeObserver:timeObserver];
        }
        self.playerLayer = nil;
        self.player = nil;
    }

    NetworkStatus netStatus = [self currentStatus];
    if (netStatus == ReachableViaWiFi) {
        // Wifi网络环境
        currentItem = self.highItem ?: self.lowItem;
    } else if (netStatus == ReachableViaWWAN) {
        // 移动网络
        currentItem = self.lowItem ?: self.highItem;
    } else {
        // 无网络
        currentItem = self.highItem ?: self.lowItem;
    }
    self.player = [AVPlayer playerWithPlayerItem:currentItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.playerLayer.frame = self.layer.bounds;
#if DEBUG
    timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        DLog(@"当前播放：%.2f",current);
    }];
#endif
    [self.layer addSublayer:self.playerLayer];
    [self changeStatusTo: LSPlayerStatusInited];
}

-(void)play
{
    if (self.player) {
        DLog(@"==play==");
        [self.player play];
    }
}

-(void)dealloc
{
    self.lowItem ? [self.lowItem removeObserver:self forKeyPath:@"status"] : nil;
    
    self.highItem ? [self.highItem removeObserver:self forKeyPath:@"status"] : nil;
#if DEBUG
    self.highItem ? [self.highItem removeObserver:self forKeyPath:@"loadedTimeRanges"] : nil;
    self.lowItem ? [self.lowItem removeObserver:self forKeyPath:@"loadedTimeRanges"] : nil;
#endif
    if (self.player && timeObserver) {
        [self.player removeTimeObserver:timeObserver];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)pause
{
    if (self.player) {
        DLog(@"==pause==");
        [self.player pause];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"] && item == currentItem) {
        if (item.status == AVPlayerStatusReadyToPlay) {
            [self changeStatusTo:LSPlayerStatusReadyToPlay];
        } else if (item.status == AVPlayerStatusFailed) {
            [self changeStatusTo:LSPlayerStatusFailed];
        } else if (item.status == AVPlayerStatusUnknown) {
            [self changeStatusTo:LSPlayerStatusUnknow];
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"] && item == currentItem)
    {
        NSArray *array=item.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        DLog(@"共缓冲：%.2f + %.2f = %.2f",startSeconds, durationSeconds,totalBuffer);
    }
}

-(void)reachabilityChanged:(NSNotification *)notify
{
    Reachability *reach = [notify object];
    if (reach.currentReachabilityStatus == ReachableViaWiFi) {
        // 网络为Wifi
        [self changeStatusTo:LSPlayerStatusIniting];
        [self prepareToPlay];
    } else if (reach.currentReachabilityStatus == ReachableViaWWAN) {
        // 为移动网络
        [self changeStatusTo:LSPlayerStatusIniting];
        [self prepareToPlay];
    } else {
        // 无网络
    }
}

-(NetworkStatus)currentStatus
{
    DLog(@"current status: %ld",[[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]);
    return [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
}
@end
