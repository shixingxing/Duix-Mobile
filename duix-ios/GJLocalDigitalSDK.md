## 硅基本地版DUIX-PRO SDK使⽤⽂档 (1.2.0)

简体中文 | [English](./GJLocalDigitalSDK_en.md)

### 物料准备
 GJLocalDigitalSDK.framework (需设置为 Embed & Sign)
 

 
      

### 开发环境
开发工具: Xcode

最低系统要求: iOS 12.0+

设备要求: iPhone 8 及以上机型

## 快速开始
```
NSInteger result = [[GJLDigitalManager manager] initBaseModel:weakSelf.basePath 
                                                 digitalModel:weakSelf.digitalPath 
                                                    showView:weakSelf.showView];

if (result == 1) {
    // 2. 启动渲染
    [[GJLDigitalManager manager] toStart:^(BOOL isSuccess, NSString *errorMsg) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 3. 启动流式驱动
                [[GJLDigitalManager manager] toStartRuning];
            });
        } else {
            [SVProgressHUD showInfoWithStatus:errorMsg];
        }
    }];
}
     
```
## 调用流程
```
1.准备资源：同步数字人所需的基础配置和模型文件

2.初始化服务：initBaseModel:digitalModel:showView:

3.启动渲染：toStart:

4.驱动播报：toWavPcmData:（流式驱动）

5.停止播报：stopPlaying:（主动停止）

6.释放资源：toStop（结束渲染）
```

### SDK回调

```
/*
*数字人渲染报错
*错误码说明：
*    0  = 未授权 
*   -1 = 未初始化 
*   50009 = 资源超时/未配置
*/
@property (nonatomic, copy) void (^playFailed)(NSInteger code,NSString *errorMsg);

/*
*音频播放结束回调
*/
@property (nonatomic, copy) void (^audioPlayEnd)(void);

/*
*音频播放进度回调
/
@property (nonatomic, copy) void (^audioPlayProgress)(float current,float total);
```

## 方法


### 初始化配置

```
/**
 * 初始化数字人服务
 * @param basePath    基础模型路径（固定不变）
 * @param digitalPath 数字人模型路径（替换数字人时更新此路径）
 * @param showView    数字人渲染视图
 * @return 状态码 1=成功, 0=未授权, -1=失败
 */
-(NSInteger)initBaseModel:(NSString*)basePath digitalModel:(NSString*)digitalPath showView:(UIView*)showView;
```




### 渲染数字人控制

```
/*
*启动数字人渲染
*/
-(void)toStart:(void (^) (BOOL isSuccess, NSString *errorMsg))block;
```


```
/*
*停止渲染并释放资源
*/
-(void)toStop;
```


```
/*
*恢复播放（暂停后调用）
*/
-(void)toPlay;
```

```
/*
*暂停数字人播放
*/
-(void)toPause;
```


### 背景管理

```
/**
 * 动态替换背景
 * @param bbgPath JPG格式背景图路径
 */
-(void)toChangeBBGWithPath:(NSString*)bbgPath;
```




### 音频控制

```
/*
*audioData播放音频流 ，参考demo里面GJLPCMManager类里toSpeakWithPath 转换成pcm的代码
*驱动数字人播报(PCM流)
*/
-(void)toWavPcmData:(NSData*)audioData;
```

```
/*
* 开始音频流播放
*/
- (void)startPlaying;
```


```
/*
* 结束音频流播放
*/
- (void)stopPlaying:(void (^)( BOOL isSuccess))success;
```


```
/*
*设置静音模式
*/
-(void)toMute:(BOOL)isMute;
```

```
/*
*清空音频缓冲区
*/
-(void)clearAudioBuffer;
```

```
/*
*暂停播放音频流
*/
-(void)toPausePcm;
```


```
/*
*恢复播放音频流
*/
-(void)toResumePcm;
```

```
/*
* 是否启用录音
*/
-(void)toEnableRecord:(BOOL)isEnable;
```


### 流式会话管理
```
/*
*启动流式会话
*/
-(void)toStartRuning;
```

```
/*
*开始新会话（单句/段落）
*/
-(void)newSession;
```

```
/*
*结束当前会话
*/
-(void)finishSession;
```


```
/*
*继续会话（finish后调用）
*/
-(void)continueSession;
```







## 动作控制

### 随机动作
 
```
/*
* 启用随机动作（建议在首段音频开始时调用）
* 返回：0=不支持, 1=成功
*/
-(NSInteger)toRandomMotion;
```

### 开始动作

```
/*
* 启用开始动作（首段音频开始时调用）
* 返回：0=不支持, 1=成功
*/
-(NSInteger)toStartMotion;
```

### 结束动作
```
/*
* 结束动作（末段音频结束时调用）
*isQuickly: YES=立即结束, NO=等待动作完成
*返回：0=不支持, 1=成功
*/
-(NSInteger)toSopMotion:(BOOL)isQuickly;
```

### 状态查询
// 获取数字人模型尺寸（需初始化后调用）
-(CGSize)getDigitalSize;

// 检查授权状态（1=已授权）
-(NSInteger)isGetAuth;



