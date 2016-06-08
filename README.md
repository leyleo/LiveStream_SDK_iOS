# LiveStream_iOS

SinaCloud 在线直播API的iOS版SDK。需要在http://www.sinacloud.com开通使用。

## 使用方法

#### 方法一：使用CocoaPods

* 首先在**Podfile**中添加

```
pod 'LiveStreamSDK', :git=> 'https://github.com/leyleo/LiveStream_SDK_iOS.git'
```

* 然后执行`pod install`
* 打开**xcworkspace**文件

#### 方法二：直接添加源代码

* 将`LiveStreamSDK`目录拷贝进工程
* 添加第三方依赖`Reachability`，[点此下载](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html)，记得将其需要的`SystemConfiguration.framework`添加到`Project->Targets->Build Phases->Link Binary with Libaries`.

## Quick Start

* 配置AK、SK

建议在项目初始化阶段进行配置。需要通过SinaCloud在线直播服务的控制面板查看AK、SK.

```
[LiveStreamSDK configWithAK:@"xxx" andSK:@"xxxxx"];
```

* 查看当前已有的频道列表信息

```
NSURLSessionDataTask *task = [[LiveStreamSessionManager manager] getTubeList:^(id responseObject, NSError *error) {
    if (!error) {
        // 请求成功，获得列表信息
    } else {
        // 处理错误信息
    }
}];
```

## 详细API说明

### LiveStreamSDK

用来配置整个SDK所需要的AK、SK。参数需要到SinaCloud在线直播服务的控制面板进行查看。

> 注意：建议在项目初始化时配置这两个参数。

```
/**
 配置LiveStreamSDK中的AK、SK. 
 @param ak 通过SinaCloud控制面板查看AK
 @param sk 通过SinaCloud控制面板查看SK
 */
+(void)configWithAK:(NSString *_Nonnull)ak
              andSK:(NSString *_Nonnull)sk;
```

### LiveStreamSessionManager

用来处理SDK的API请求服务。该类采用单例模式。

#### 初始化

```
/**
 单例方法，在使用该单例方法获得实例之前，需要通过LiveStreamSDK的 +(void)configWithAK:(NSString *_Nullable)ak andSK:(NSString *_Nullable)sk; 方法配置AK、SK.
 @return LiveStreamSessionManager实例
 */
+(instancetype _Nullable)manager;
```

#### 获取频道列表

```
/**
 获取频道列表
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeList:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
请求成功时，回调方法返回`NSArray`类型的`responseObject`，如下

```
[{
    "conn_limit" = 0;
    "create_time" = "2016-03-02 17:45:31";
    description = inittest;
    name = hello;
    status = 1;
    "tube_id" = xxxxxxx;
},...,{
...
}]
```
> 返回参数说明：

* conn_limit 频道并发数限制
* create_time 频道创建时间
* description 频道描述信息
* name 频道名称
* status 频道状态：0 表示未开启；1 表示无信号；2 表示正在播放
* tube_id 频道唯一标示Id

#### 创建频道

```
/**
 创建频道，成功时callback返回tube_id（频道Id）
 @param name 频道名称
 @param description 频道描述
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)createTube:(NSString *_Nonnull)name
                                 description:(NSString *_Nullable)description
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
请求成功时，回调方法返回`NSDictionary`类型的`responseObject`.

> 返回参数说明：

* tube_id 频道唯一标示Id

#### 删除频道
                                    
```
/**
 删除频道
 @param tubeId 频道Id
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)deleteTube:(NSString *_Nonnull)tubeId
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
#### 更新频道信息

```
/**
 更新频道信息
 @param tubeId 频道Id
 @param name 频道名称
 @param description 频道描述
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)updateTube:(NSString *_Nonnull)tubeId
                                        name:(NSString *_Nullable)name
                                 description:(NSString *_Nullable)description
                                    callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
#### 查询频道信息

```
/**
 查询频道信息，包括直播地址，推流地址等
 @param tubeId 频道Id
 @param callback 回调方法
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)queryTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;                                                                      
```
请求成功时，回调方法返回`NSDictionary`类型的`responseObject`，如下：

```
{
    description = 1457604486;
    name = 1457604486;
    "play_url" =     {
        "hls_low" = "hls.sinacloud.com/play_low/xxxxxxxxx.m3u8";
        "hls_origin" = "hls.sinacloud.com/play/xxxxxxxxx.m3u8";
    };
    "publish_url" = "rtmp://live2.sinacloud.com/publish/xxxxxxxxx";
    status = 0;
    "tube_id" = xxxxxxxxx;
}
```

> 返回参数说明：

* description 频道描述信息
* name 频道名称
* status 频道状态：0 表示未开启；1 表示无信号；2 表示正在播放
* tube_id 频道唯一标示Id
* publish_url 推流地址
* play_url NSDictionary 类型
	* hls_low 低品质HLS播放地址
	* hls_origin 原品质HLS播放地址

#### 开始直播

> 注意：在往服务器上推流之前，请确保先调用该方法开启直播状态。

```
/**
 开始直播，需要调用此方法成功后才能成功推送直播流
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)startTube:(NSString *_Nonnull)tubeId
                                   callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
#### 停止直播

```
/**
 停止直播，停止后推送地址和直播地址失效
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)stopTube:(NSString *_Nonnull)tubeId
                                  callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```
#### 查询频道当前状态

```
/**
 查询频道当前状态、在线人数等信息
 @param tubeId 频道Id
 @return NSURLSessionDataTask实例
 */
-(NSURLSessionDataTask *_Nullable)getTubeStatus:(NSString *_Nonnull)tubeId
                                       callback:(nullable void (^)(id _Nullable responseObject, NSError *_Nullable error))callback;
```

### LiveStreamPlayer

简易直播流HLS播放器视图，根据当前网络自动切换播放品质。继承自`UIView`，需要通过在对应视图控制器中添加`LiveStreamPlayerDelegate`的代理方法来监听播放器的状态。

#### 初始化
通过频道Id初始化播放器。

```
/**
 初始化方法
 @param tubeId 频道Id
 @return LiveStreamPlayer实例
 */
-(instancetype)initWithTubeId:(NSString *)tubeId;
```
#### 属性

```
@property(nonatomic, readonly, strong) NSString *tubeId; // 频道Id
@property(nonatomic, readonly, strong) NSString *tubeName; // 频道名称
@property(nonatomic, readonly, strong) NSString *tubeDescription; // 频道描述
@property(nonatomic, weak) id<LiveStreamPlayerDelegate> delegate; // 代理
```

#### 相关方法

```
/**
 开始播放，需要在收到 LSPlayerStatusInited 初始化完成的回调通知之后调用该方法
 */
-(void)play;
```
```
/**
 暂停播放
 */
-(void)pause;
```

#### LiveStreamPlayerDelegate

代理方法如下，当状态改变时触发：

```
/**
 LiveStreamPlayer的代理方法，用来监听播放状态
 @param status 播放器的状态
 */
-(void)statusChanged:(LSPlayerStatus)status;
```

#### LSPlayerStatus

播放器的状态：
 
* LSPlayerStatusUnknow=0 未知状态
* LSPlayerStatusIniting 正在初始化
* LSPlayerStatusInitFailed 初始化失败
* LSPlayerStatusInited 初始化完成
* LSPlayerStatusReadyToPlay 缓冲完成，开始播放
* LSPlayerStatusFailed 播放失败