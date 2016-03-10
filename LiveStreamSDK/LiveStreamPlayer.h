//
//  LiveStreamPlayer.h
//  Pods
//
//  Created by liulei10 on 16/03/09.
//
//

#import <UIKit/UIKit.h>
/**
 播放器的状态
 
 LSPlayerStatusUnknow=0 未知状态
 
 LSPlayerStatusIniting 正在初始化
 
 LSPlayerStatusInitFailed 初始化失败
 
 LSPlayerStatusInited 初始化完成
 
 LSPlayerStatusReadyToPlay 缓冲完成，开始播放
 
 LSPlayerStatusFailed 播放失败
 */
typedef NS_ENUM(NSInteger, LSPlayerStatus) {
    LSPlayerStatusUnknow,
    LSPlayerStatusIniting,
    LSPlayerStatusInitFailed,
    LSPlayerStatusInited,
    LSPlayerStatusReadyToPlay,
    LSPlayerStatusFailed
};


@protocol LiveStreamPlayerDelegate <NSObject>
/**
 LiveStreamPlayer的代理方法，用来监听播放状态
 @param status 播放器的状态
 */
-(void)statusChanged:(LSPlayerStatus)status;
@end

@interface LiveStreamPlayer : UIView
/// 频道Id
@property(nonatomic, readonly, strong) NSString *tubeId;
/// 频道名称
@property(nonatomic, readonly, strong) NSString *tubeName;
/// 频道描述
@property(nonatomic, readonly, strong) NSString *tubeDescription;

@property(nonatomic, weak) id<LiveStreamPlayerDelegate> delegate;
/**
 初始化方法
 @param tubeId 频道Id
 @return LiveStreamPlayer实例
 */
-(instancetype)initWithTubeId:(NSString *)tubeId;
/**
 设置频道Id
 @param tubeId 频道Id
 */
-(void)setupTubeId:(NSString *)tubeId;
/**
 开始播放，需要在收到 LSPlayerStatusInited 初始化完成的回调通知之后调用该方法
 */
-(void)play;
/**
 暂停播放
 */
-(void)pause;
@end

