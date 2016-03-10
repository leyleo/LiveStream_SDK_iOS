//
//  LiveStreamSessionManager.h
//  Pods
//
//  Created by liulei10 on 16/03/08.
//
//

#import <Foundation/Foundation.h>

@interface LiveStreamSessionManager : NSObject
/**
 单例方法，在使用该单例方法获得实例之前，需要通过LiveStreamSDK的 +(void)configWithAK:(NSString *_Nullable)ak andSK:(NSString *_Nullable)sk; 方法配置AK、SK.
 @return LiveStreamSessionManager实例
 */
+(instancetype _Nullable)manager;
#pragma mark - Request Method
/**
 获取频道列表
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeList:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 创建频道，成功时callback返回tube_id（频道Id）
 @param name 频道名称
 @param description 频道描述
 @param limit 并发限制
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)createTube:(NSString *_Nonnull)name
                                 description:(NSString *_Nullable)description
                                connectLimit:(NSInteger)limit
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 删除频道
 @param tubeId 频道Id
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)deleteTube:(NSString *_Nonnull)tubeId
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 更新频道信息
 @param tubeId 频道Id
 @param name 频道名称
 @param description 频道描述
 @param limit 并发限制
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)updateTube:(NSString *_Nonnull)tubeId
                                        name:(NSString *_Nullable)name
                                 description:(NSString *_Nullable)description
                                  conn_limit:(NSInteger)limit
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 查询频道信息，包括直播地址，推流地址等
 @param tubeId 频道Id
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)queryTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 开始直播，需要调用此方法成功后才能成功推送直播流
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)startTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 停止直播，停止后推送地址和直播地址失效
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)stopTube:(NSString *_Nonnull)tubeId
                                  callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
/**
 查询频道当前状态、在线人数等信息
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeStatus:(NSString *_Nonnull)tubeId
                                       callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
@end
