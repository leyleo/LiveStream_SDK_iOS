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


//-(NSURLSessionDataTask *)createTube:(NSString *)name
//                        description:(NSString *)description
//                       connectLimit:(NSInteger)limit;
//-(NSURLSessionDataTask *)deleteTube:(NSString *)tubeId;
//-(NSURLSessionDataTask *)queryTubeInfo:(NSString *)tubeId;
@end

@implementation LiveStreamSessionManager
#pragma mark - Init
+(void)configWithAK:(NSString *_Nullable)ak andSK:(NSString *_Nullable)sk
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:ak forKey:@"com.sinacloud.LiveStreamSessionAK"];
    [defaults setValue:sk forKey:@"com.sinacloud.LiveStreamSessionSK"];
}
+(instancetype)manager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *ak = [defaults valueForKey:@"com.sinacloud.LiveStreamSessionAK"];
        NSString *sk = [defaults valueForKey:@"com.sinacloud.LiveStreamSessionSK"];
        NSAssert(ak != nil, @"empty ak, please config ak & sk first");
        NSAssert(sk != nil, @"empty sk, please config ak & sk first");
        _sharedObject = [[self alloc] initWithAK:ak andSK:sk];
    });
    return _sharedObject;
}

-(instancetype)initWithAK:(NSString *)ak andSK:(NSString *)sk
{
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
    NSString *urlString = [NSString stringWithFormat:@"%@/tube/query",BaseUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [_session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            if (callback) {
                callback(nil, error);
            }
        } else {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200) {
                NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSError *error = nil;
                id jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSLog(@"success");
                if (callback) {
                    callback(jsonDic, nil);
                }
            } else {
                NSLog(@"response: %ld",httpResp.statusCode);
                if (callback) {
                    NSError *error = [NSError errorWithDomain:ErrorDomain code:httpResp.statusCode userInfo:nil];
                    callback(nil, error);
                }
            }
        }
    }];
    [task resume];
    return task;
}

#pragma mark - Private
-(void)setConfig:(NSURLSessionConfiguration *)configuration
          withAk:(NSString *)ak
           andSk:(NSString *)sk
{
    NSString *auth = [NSString stringWithFormat:@"%@:%@",ak,sk];
    NSData *authData = [auth dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedDataWithOptions:0]];
    [configuration setHTTPAdditionalHeaders:@{@"Accept":@"application/json",@"Authorization":authHeader}];
}
@end
