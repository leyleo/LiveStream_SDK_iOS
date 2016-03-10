//
//  LiveStreamSDK.m
//  Pods
//
//  Created by liulei10 on 16/03/09.
//
//

#import "LiveStreamSDK.h"

@implementation LiveStreamSDK
+(void)configWithAK:(NSString *_Nonnull)ak andSK:(NSString *_Nonnull)sk
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:ak forKey:@"com.sinacloud.LiveStreamSDKAK"];
    [defaults setValue:sk forKey:@"com.sinacloud.LiveStreamSDKSK"];
    [defaults synchronize];
}
@end
