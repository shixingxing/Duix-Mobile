# 硅基数字人SDK

简体中文 | [English](./README_en.md)

## 一、产品介绍

2D 数字人虚拟人SDK ,可以通过语音完成对虚拟人实时驱动。

### 1. 适用场景

部署成本低: 无需客户提供技术团队进行配合,支持低成本快速部署在多种终端及大屏;
网络依赖小:可落地在地铁、银行、政务等多种场景的虚拟助理自助服务上;
功能多样化:可根据客户需求满足视频、媒体、客服、金融、广电等多个行业的多样化需求

### 2. 核心功能

提供定制形象的 AI 主播,智能客服等多场景形象租赁,支持客户快速部署和低成本运营;
专属形象定制:支持定制专属的虚拟助理形象,可选低成本或深度形象生成;
播报内容定制:支持定制专属的播报内容,应用在培训、播报等多种场景上;
实时互动问答:支持实时对话,也可定制专属问答库,可满足咨询查询、语音闲聊、虚拟陪伴、垂类场景的客服问答等需求。

## 二、SDK集成

### 1. 支持的系统和硬件版本

| 项目     | 描述                                                 |
|--------|----------------------------------------------------|
| 系统     | 支持 Android 10+ 系统。                                 |
| CPU架构  | armeabi-v7a, arm64-v8a                             |
| 硬件要求   | 要求设备 CPU8 核极以上(骁龙8 Gen2),内存 8G 及以上。可用存储空间 1GB 及以上。 |
| 网络     | 无。                                                 |
| 开发 IDE | Android Studio Giraffe \mid 2022.3.1 Patch 2       |
| 内存要求   | 可用于数字人的内存 >= 800MB                                 |

### 2. SDK集成

在 build.gradle 中增加配置如下

```gradle
dependencies {
    // 引用SDK项目
    api project(":duix-sdk")
    ...
}
```

## 三、SDK调用及API说明


### 1. 模型检查及下载

使用渲染服务前需要将基础配置及模型文件同步到本地存储中,SDK中提供了VirtualModelUtil简单演示了模型下载解压流程。
若模型下载过慢或无法下载，开发者可以选择将模型包缓存到自己的存储服务。

函数定义:
ai.guiji.duix.sdk.client.VirtualModelUtil

```
// 检查基础配置是否已下载
boolean checkBaseConfig(Context context)

// 检查模型是否已下载
boolean checkModel(Context context, String name)

// 基础配置下载
void baseConfigDownload(Context context, String url, ModelDownloadCallback callback)

// 模型下载
void modelDownload(Context context, String modelUrl, ModelDownloadCallback callback)
```

其中ModelDownloadCallback:
ai.guiji.duix.sdk.client.VirtualModelUtil$ModelDownloadCallback

```
interface ModelDownloadCallback {
    // 下载进度
    void onDownloadProgress(String url, long current, long total);
    // 解压进度
    void onUnzipProgress(String url, long current, long total);
    // 下载解压完成
    void onDownloadComplete(String url, File dir);
    // 下载解压失败
    void onDownloadFail(String url, int code, String msg);
}
```

调用示例:

```kotlin
if (!VirtualModelUtil.checkBaseConfig(mContext)){
    VirtualModelUtil.baseConfigDownload(mContext, baseConfigUrl, callback)
}
```

```kotlin
if (!VirtualModelUtil.checkModel(mContext, modelUrl)){
    VirtualModelUtil.modelDownload(mContext, modelUrl, callback)
}
```


### 2. 初始化SDK

在渲染页onCreate()阶段构建DUIX对象并调用init接口

函数定义:
ai.guiji.duix.sdk.client.DUIX

```
// 构建DUIX对象
public DUIX(Context context, String modelName, RenderSink sink, Callback callback)

// 初始化DUIX服务
void init()
```

DUIX对象构建说明:

| 参数         | 类型         | 描述                                  |
|------------|------------|-------------------------------------|
| context    | Context    | 系统上下文                               |
| modelName  | String     | 可以传递模型下载的URL(已下载完成)或缓存的文件名          |
| render     | RenderSink | 渲染数据接口，sdk提供了默认的渲染组件继承自该接口，也可以自己实现  |
| callback   | Callback   | SDK处理的各种回调事件                        |


其中Callback的定义:
ai.guiji.duix.sdk.client.Callback

```
interface Callback {
    void onEvent(String event, String msg, Object info);
}
```

调用示例:

```kotlin
duix = DUIX(mContext, modelUrl, mDUIXRender) { event, msg, info ->
    when (event) {
        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_READY -> {
            initOK()
        }

        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_ERROR -> {
            initError()
        }
        // ...

    }
}
// 异步回调结果
duix?.init()
```

在init回调中确认初始化结果


### 3. 数字人形象展示

使用RenderSink接口接受渲染帧数据，SDK中提供了该接口实现DUIXRenderer.java。也可以自己实现该接口自定义渲染。

其中RenderSink的定义如下:
ai.guiji.duix.sdk.client.render.RenderSink

```java
/**
 * 渲染管道，通过该接口返回渲染数据
 */
public interface RenderSink {

    // frame中的buffer数据以bgr顺序排列
    void onVideoFrame(ImageFrame imageFrame);

}
```

调用示例:

使用DUIXRenderer及DUIXTextureView控件简单实现渲染展示,该控件支持透明通道可以自由设置背景及前景

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // ...
    mDUIXRender =
        DUIXRenderer(
            mContext,
            binding.glTextureView
        )

    binding.glTextureView.setEGLContextClientVersion(GL_CONTEXT_VERSION)
    binding.glTextureView.setEGLConfigChooser(8, 8, 8, 8, 16, 0) // 透明
    binding.glTextureView.isOpaque = false           // 透明
    binding.glTextureView.setRenderer(mDUIXRender)
    binding.glTextureView.renderMode =
        GLSurfaceView.RENDERMODE_WHEN_DIRTY      // 一定要在设置完Render之后再调用

    duix = DUIX(mContext, modelUrl, mDUIXRender) { event, msg, _ ->
    }
    // ...
}
```


### 4. 使用流式推送PCM驱动数字人播报

**PCM格式:16k采样率单通道16位深**

函数定义:
ai.guiji.duix.sdk.client.DUIX

```
// 通知服务开始推送音频
void startPush()

// 推送PCM数据
void pushPcm(byte[] buffer)

// 完成一段音频推送(音频推送完就调要该函数，而不是等播放完成再调用。)
void stopPush()

```

startPush、pushPcm、stopPush需要成对调用，pushPcm不宜过长。可以在一整段音频推送完后调用stopPush结束当前会话，下一段音频再使用startPush重新开启推送。

调用示例:

```kotlin
val thread = Thread {
            duix?.startPush()
            val inputStream = assets.open("pcm/2.pcm")
            val buffer = ByteArray(320)
            var length = 0
            while (inputStream.read(buffer).also { length = it } > 0){
                val data = buffer.copyOfRange(0, length)
                duix?.pushPcm(data)
            }
            duix?.stopPush()
            inputStream.close()
}
thread.start()
```


### 5. 启动wav音频驱动数字人播报

函数定义:
ai.guiji.duix.sdk.client.DUIX

```
void playAudio(String wavPath) 
```

该函数兼容旧的wav驱动数字人接口，在内部实际是调用了PCM推流方式实现驱动。


参数说明:

| 参数      | 类型     | 描述                    |
|---------|--------|-----------------------|
| wavPath | String | 16k采样率单通道16位深的wav本地文件 |


调用示例:

```kotlin
duix?.playAudio(wavPath)
```

音频播放状态及进度回调:

```kotlin
object : Callback {
    fun onEvent(event: String, msg: String, info: Object) {
        when (event) {
            // ...

            "play.start" -> {
                // 开始播放音频
            }

            "play.end" -> {
                // 完成播放音频
            }
            "play.error" -> {
                // 音频播放异常
            }
        }
    }
}
```

### 6. 终止当前播报

当数字人正在播报时调用该接口终止播报。

函数定义:

```
boolean stopAudio();
```

调用示例如下：

```kotlin
duix?.stopAudio()
```

### 7. 播放指定动作区间

模型中支持新的动作区间标注(SpecialAction.json)

函数定义:
ai.guiji.duix.sdk.client.DUIX

```
/**
 * 播放指定动作区间
 * @param name 动作区间名称，在init成功回调时，可以在@{ModelInfo.getSilenceRegion()}中获取到可用的动作区间
 * @param now 是否立即播放 true: 立即播放; false: 等待当前静默区间或动作区间播放完毕后播放
 */
void startMotion(String name, boolean now)
```

调用示例如下：

```kotlin
duix?.startMotion("打招呼", true)
```

### 8. 随机播放动作区间

随机播放场景及旧的标注协议(config.json)

函数定义:

```
/**
 * 随机播放一个动作区间
 * @param now 是否立即播放 true: 立即播放; false: 等待当前静默区间或动作区间播放完毕后播放
 */
void startRandomMotion(boolean now);
```

调用示例如下：

```kotlin
duix?.startRandomMotion(true)
```


## 四. Proguard配置

如果代码使用了混淆，请在proguard-rules.pro中配置：

```
-keep class ai.guiji.duix.DuixNcnn{*; }
```
git 
## 五、注意事项

1. 驱动渲染初始化前需要确保基础配置文件及模型下载到指定位置。
2. 播放的PCM音频不宜过长，播放的PCM缓存在内存中，过长的音频流可能导致内存溢出。
3. 替换预览模型可以在MainActivity.kt文件中修改modelUrl的值，使用SDK中自带的文件下载解压管理以获得完整的模型文件。
4. 音频驱动的格式: 16k采样率单通道16位深度
5. 设备性能不足时可能导致音频特征提取的速度跟不上音频播放的速度，可以使用duix?.setReporter()函数添加一个监控观察帧渲染返回的信息。

## 六、版本记录

**<a>4.0.1</a>**
1. 支持PCM音频流驱动数字人，提升音频播放响应速度。
2. 优化动作区间播放，可根据模型配置指定播放动作区间。
3. 自定义音频播放器，去除Exoplayer播放依赖
4. 提供简洁的模型下载同步管理工具

**<a>3.0.5</a>**

```text
1. 更新arm32位cpu的libonnxruntime.so版本以修复兼容问题。
2. 修改动作区间播放函数，可以使用随机播放和顺序播放，需要主动调用停止播放动作区间以回到静默区间。
```

**<a>3.0.4</a>**

```text
1. 修复部分设备gl默认float低精度导致无法正常显示形象问题。
```

**<a>3.0.3</a>**

```text
1. 优化本地渲染。
```

## 七、其他相关的第三方开源项目

| 模块 | 描述 |
|-----------|--|
| [onnx](https://github.com/onnx/onnx) | 人工智能框架 |
| [ncnn](https://github.com/Tencent/ncnn) | 高性能神经网络计算框架 |
