//
//  LiveStreamSDK.h
//  Pods
//
//  Created by liulei10 on 16/03/09.
//
//

#import <Foundation/Foundation.h>

@interface LiveStreamSDK : NSObject
/**
 配置LiveStreamSDK中的AK、SK.
 @param ak 通过SinaCloud控制面板查看AK
 @param sk 通过SinaCloud控制面板查看SK
 */
+(void)configWithAK:(NSString *_Nonnull)ak
              andSK:(NSString *_Nonnull)sk;
@end
