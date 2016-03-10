//
//  LiveStreamSessionManager.m
//  Pods
//
//  Created by liulei10 on 16/03/08.
//
//

#import "LiveStreamSessionManager.h"

NSString * const BaseUrl = @"http://liveapi.sinacloud.com";
NSString * const ErrorDomain = @"com.sinacloud.LiveStreamSession";

@interface LiveStreamSessionManager()<NSURLSessionDataDelegate>
{
    NSString *_ak;
    NSString *_sk;
}
@property (nonatomic, readonly, strong) NSURLSession *session;
@property (readonly, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, readonly, strong) NSArray <NSURLSessionTask *> *dataTasks;

@end

@implementation LiveStreamSessionManager
#pragma mark - Init

+(instancetype)manager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(instancetype)init
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ak = [defaults valueForKey:@"com.sinacloud.LiveStreamSDKAK"];
    NSString *sk = [defaults valueForKey:@"com.sinacloud.LiveStreamSDKSK"];
    NSAssert(ak != nil, @"empty ak, please config ak in LiveStreamSDK class first");
    NSAssert(sk != nil, @"empty sk, please config sk in LiveStreamSDK class first");
    return [self initWithAK:ak andSK:sk configuration:nil];
}

-(instancetype)initWithAK:(NSString *)ak
                    andSK:(NSString *)sk
            configuration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _ak = ak;
        _sk = sk;
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        [self setConfig:configuration withAk:ak andSk:sk];
        _sessionConfiguration = configuration;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
    }
    return self;
}

#pragma mark - Method
-(NSURLSessionDataTask *_Nullable)getTubeList:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/list",BaseUrl]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

-(NSURLSessionDataTask *_Nullable)createTube:(NSString *_Nonnull)name
                                 description:(NSString *_Nullable)description
                                connectLimit:(NSInteger)limit
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))callback
{
    if (!name) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find name"]);
        }
        return nil;
    }
    NSMutableString *paramString = [[NSMutableString alloc] initWithFormat:@"conn_limit=%ld&name=%@",limit,name];
    if (description) {
        [paramString appendFormat:@"&description=%@",name];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/create?%@",BaseUrl,paramString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

-(NSURLSessionDataTask *_Nullable)deleteTube:(NSString *_Nonnull)tubeId
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/delete?tube_id=%@",BaseUrl, tubeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

-(NSURLSessionDataTask *_Nullable)updateTube:(NSString *_Nonnull)tubeId
                                        name:(NSString *_Nullable)name
                                 description:(NSString *_Nullable)description
                                  conn_limit:(NSInteger)limit
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSMutableString *paramString = [[NSMutableString alloc] initWithFormat:@"tube_id=%@&conn_limit=%ld",tubeId,limit];
    if (name) {
        [paramString appendFormat:@"&name=%@",name];
    }
    if (description) {
        [paramString appendFormat:@"&description=%@",description];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/update?%@",BaseUrl,paramString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

-(NSURLSessionDataTask *_Nullable)queryTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/query?tube_id=%@",BaseUrl, tubeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

-(NSURLSessionDataTask *_Nullable)startTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/start?tube_id=%@",BaseUrl, tubeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}
/**
 停止直播，停止后推送地址和直播地址失效
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)stopTube:(NSString *_Nonnull)tubeId
                                  callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/stop?tube_id=%@",BaseUrl, tubeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}
/**
 查询频道当前状态、在线人数等信息
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeStatus:(NSString *_Nonnull)tubeId
                                       callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback
{
    if (!tubeId) {
        if (callback) {
            callback(nil, [self errorWithCode:-1 andMessage:@"can't find tubeId"]);
        }
        return nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/tube/status?tube_id=%@",BaseUrl, tubeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [self startRequest:request callback:callback];
}

#pragma mark - Private
/**
 生成NSError对象
 */
-(NSError *)errorWithCode:(NSInteger)code andMessage:(NSString *)message
{
    return [NSError errorWithDomain:ErrorDomain code:code userInfo:@{@"code":@(code),@"message":message}];
}

/**
 将NSDictionary转换为JSON字符串二进制格式
 */
-(NSData *)dataOfDictionary:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    return data;
}
/**
 请求的统一处理入口
 */
-(NSURLSessionDataTask *_Nullable)startRequest:(NSURLRequest *)request
                                      callback:(nullable void (^)(id _Nullable responseObject, NSError * _Nullable error))callback
{
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (callback) {
                callback(nil, error);
            }
        } else {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200) {
                NSError *error = nil;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!jsonDic || ![jsonDic isKindOfClass:[NSDictionary class]]) {
                    if (callback) {
                        callback(nil, [self errorWithCode:99999 andMessage:@"unexpect return format"]);
                    }
                } else {
                    NSInteger code = [[jsonDic valueForKey:@"code"] integerValue];
                    
                    if (callback) {
                        if (code != 0) {
                            NSString *message = [jsonDic valueForKey:@"message"];
                            callback(nil, [self errorWithCode:code andMessage:message]);
                        } else {
                            id data = [jsonDic valueForKey:@"data"];
                            callback(data, nil);
                        }
                    }
                }
            } else {
                if (callback) {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:httpResp.statusCode userInfo:nil];
                    callback(nil, error);
                }
            }
        }
    }];
    [task resume];
    return task;
}

-(void)setConfig:(NSURLSessionConfiguration *)configuration
          withAk:(NSString *)ak
           andSk:(NSString *)sk
{
    NSString *authHeader = [self authorationHeader:ak andSk:sk];
    [configuration setTimeoutIntervalForRequest:30];
    [configuration setHTTPAdditionalHeaders:@{@"Accept":@"application/json",@"Authorization":authHeader}];
}
-(NSString *)authorationHeader:(NSString *)ak
                         andSk:(NSString *)sk
{
    NSString *auth = [NSString stringWithFormat:@"%@:%@",ak,sk];
    NSData *authData = [auth dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    return authHeader;
}
@end
