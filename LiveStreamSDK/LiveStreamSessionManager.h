//
//  LiveStreamSessionManager.h
//  Pods
//
//  Created by liulei10 on 16/03/08.
//
//

#import <Foundation/Foundation.h>

@interface LiveStreamSessionManager : NSObject
+(void)configWithAK:(NSString *_Nullable)ak andSK:(NSString *_Nullable)sk;
+(instancetype _Nullable)manager;
-(instancetype _Nullable)initWithAK:(NSString *_Nullable)ak andSK:(NSString *_Nullable)sk;
#pragma mark - Request Method
/**
 获取频道列表
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeList:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))callback;
@end
