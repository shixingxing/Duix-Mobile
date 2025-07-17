# Silicon-Based Digital Human SDK

[简体中文](./README.md) | English

## I. Product Introduction

2D digital human virtual human SDK that can be driven in real-time through voice.

### 1. Suitable Scenarios

Low deployment cost: No need for customers to provide technical teams for cooperation, supports low-cost and rapid deployment on various terminals and large screens; Small network dependency: Can be implemented in various scenarios such as subway, bank, and government virtual assistant self-service; Diverse functions: Can meet the diverse needs of video, media, customer service, finance, radio and television and other industries according to customer needs.

### 2. Core Functions

Provide customized AI anchors, smart customer service and other multi-scene image rentals, support customers to deploy quickly and operate at low cost; Exclusive image customization: Support custom exclusive virtual assistant images, optional low-cost or deep image generation; Broadcast content customization: Support custom exclusive broadcast content, used in training, broadcasting and other scenarios; Real-time interactive Q&A: Support real-time dialogue, can also customize exclusive Q&A database, can meet consulting inquiries, voice chat, virtual companions, vertical scene customer service questions and other needs.<br><br>

## II. SDK Integration

### 1. Supported Systems and Hardware Versions

| Item                    | Description                                                                                                                        |
|:------------------------|:-----------------------------------------------------------------------------------------------------------------------------------|
| System                  | Supports Android 10+ system.                                                                                                       |
| CPU Architecture        | armeabi-v7a, arm64-v8a                                                                                                             |
| Hardware Requirements   | Requires devices with 8-core CPU or higher(Qualcomm 8 Gen2), 8GB memory or higher, and available storage space of 1GB or higher.   |
| Network                 | -                                                                                                                                  |
| Development IDE         | Android Studio Giraffe 2022.3.1 Patch 2                                                                                            |
| Memory Requirements     | Memory available for digital humans >= 800MB                                                                                       |

### 2. SDK Integration

add the following configuration in build.gradle:

```gradle
dependencies {
    // reference SDK project
    api project(":duix-sdk")
    ...
}
```


## III. SDK Invocation and API Description

### 1. Model checking and downloading

Before using the rendering service, it is necessary to synchronize the basic configuration and model files to local storage. The SDK provides a simple demonstration of the model download and decompression process using VirtualModelUtil.
If the model download is too slow or unable to download, developers can choose to cache the model package to their own storage service.

Function definition:
ai.guiji.duix.sdk.client.VirtualModelUtil

```
// Check if the basic configuration has been downloaded
boolean checkBaseConfig(Context context)

// Check if the model has been downloaded
boolean checkModel(Context context, String name)

// Basic configuration download
void baseConfigDownload(Context context, String url, ModelDownloadCallback callback)

// Model download
void modelDownload(Context context, String modelUrl, ModelDownloadCallback callback)
```

ModelDownloadCallback:
ai.guiji.duix.sdk.client.VirtualModelUtil$ModelDownloadCallback

```
interface ModelDownloadCallback {
    void onDownloadProgress(String url, long current, long total);
    void onUnzipProgress(String url, long current, long total);
    void onDownloadComplete(String url, File dir);
    void onDownloadFail(String url, int code, String msg);
}
```

Example call:

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


### 2. Initialize SDK

Build the DUIX object and add callback events in the render page onCreate() stage:

Function definition:
ai.guiji.duix.sdk.client.DUIX

```
// Build DUIX object
public DUIX(Context context, String modelName, RenderSink sink, Callback callback)

// Initialize DUIX service
void init()
```

DUIX object construction instructions:

| Parameter   | Type         | Description                                                                                                                                  |
|:------------|:-------------|:---------------------------------------------------------------------------------------------------------------------------------------------|
| context     | Context      | System context                                                                                                                               |
| modelName   | String       | Can pass the URL of the model download (already downloaded) or the cached file name                                                          |
| render      | RenderSink   | Rendering data interface, the SDK provides a default rendering component that inherits from this interface, or you can implement it yourself |
| callback    | Callback     | Various callback events handled by the SDK                                                                                                   |


The definition of callback:
ai.guiji.duix.sdk.client.Callback

```
interface Callback {
    void onEvent(String event, String msg, Object info);
}
```

Example call:

```kotlin
duix = DUIX(mContext, modelDir, mDUIXRender) { event, msg, info ->
    when (event) {
        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_READY -> {
            initOK()
        }

        ai.guiji.duix.sdk.client.Constant.CALLBACK_EVENT_INIT_ERROR -> {

        }
        // ...

    }
}
// Asynchronous callback result
duix?.init()
```

Confirm the initialization result in the init callback


### 3. Digital Human Avatar Display

Use the RenderSink interface to accept rendering frame data; the SDK provides an implementation of this interface, DUIXRenderer.java. You can also implement the interface yourself to customize rendering. The definition of RenderSink is as follows:

The definition of RenderSink is as follows:
ai.guiji.duix.sdk.client.render.RenderSink

```java
/**
 * Rendering pipeline, returns rendering data through this interface
 */
public interface RenderSink {

    // The buffer data in frame is arranged in bgr order
    void onVideoFrame(ImageFrame imageFrame);

}
```

Example call:

Use DUIXRenderer and DUIXTextureView control to simply implement rendering display; this control supports transparency and can be freely set background and foreground:

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
    binding.glTextureView.setEGLConfigChooser(8, 8, 8, 8, 16, 0) // Transparency
    binding.glTextureView.isOpaque = false           // Transparency
    binding.glTextureView.setRenderer(mDUIXRender)
    binding.glTextureView.renderMode =
        GLSurfaceView.RENDERMODE_WHEN_DIRTY      // Must be called after setting Render

    duix = DUIX(mContext, modelUrl, mDUIXRender) { event, msg, _ ->
    }
    // ...
}
```

### 4. Using streaming push PCM to drive digital human playback

**PCM format: 16k sample rate, single channel, 16 bit**

Function definition:
ai.guiji.duix.sdk.client.DUIX

```
// Notification service starts pushing audio
void startPush()

// Push PCM data
void pushPcm(byte[] buffer)

// Complete an audio push
void stopPush()

```

startPush, pushPcm, and stopPush need to be called in pairs, and pushPcm should not be too long. You can call stopPush to end the current session after a whole audio segment is pushed, and use startPush to restart the push for the next audio segment.


Example call:

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





### 5. Using wav file to drive digital human playback

Function definition:
ai.guiji.duix.sdk.client.DUIX

```
void playAudio(String wavPath) 
```

This function is compatible with the old WAV driver digital human interface, and internally it actually calls the PCM streaming method to implement the driver.

Parameter description:

| Parameter   | Type     | Description                                                                     |
|:------------|:---------|:--------------------------------------------------------------------------------|
| wavPath     | String   | Address or https network address of a 16k sample rate mono channel wav file     |


Example call:

```kotlin
duix?.playAudio(wavPath)
```


Audio playback status and progress callback:

```kotlin
object : Callback {
    fun onEvent(event: String, msg: String, info: Object) {
        when (event) {
            // ...

            "play.start" -> {
                // Start playing audio
            }

            "play.end" -> {
                // Complete playing audio
            }
            "play.error" -> {
                // Audio playback exception
            }
        }
    }
}
```

### 6. Terminate Current playback

Call this interface to terminate the playback when the digital human is playing.

Function definition:

```
boolean stopAudio();
```

Example call:

```kotlin
duix?.stopAudio()
```

### 7. Play the specified action interval

Support for new action interval annotation in the model (SpecialAction.json)

Function definition:
ai.guiji.duix.sdk.client.DUIX

```
/**
 * Play the specified action interval
 * @param name The name of the action interval can be obtained from @{ModelInfo.getSilenceRegional()} when the init callback is successful
 * @param now
 */
void startMotion(String name, boolean now)
```

Example call:

```kotlin
duix?.startMotion("Hello", true)
```


### 8. Randomly play action intervals

Randomly play scenes and old annotation protocols (config.json)

Function definition:

```
void startRandomMotion(boolean now);
```

Example call:

```kotlin
duix?.startRandomMotion(true)
```

## IV. Proguard configuration

If the code uses obfuscation, please configure in proguard-rules.pro:

```
-keep class ai.guiji.duix.DuixNcnn{*; }
```

<br>

## V. Precautions

1. The basic configuration folder and the corresponding model folder storage path must be correctly configured to drive rendering.
2. The audio file to be played should not be too large; a large audio file import will consume a lot of CPU, causing drawing stuck.<br><br>

## VI. Version Record

**<a>4.0.1</a>**

```text
1. Support PCM audio stream to drive digital humans and improve audio playback response speed.
2. Optimize the playback of action intervals, which can be specified according to the model configuration.
3. Customize audio player and remove Exoplayer playback dependency
4. Provide a concise model download synchronization management tool
```

**3.0.4**

```text
1. Fixed the issue that the default low-precision float of gl on some devices caused the image to not be displayed properly.
```

**3.0.3**

```text
1. Optimized local rendering.
```

<br>

## VII. Other Related Third-Party Open Source Projects

| Module                                           | Description                                         |
| :----------------------------------------------- | :-------------------------------------------------- |
| [ExoPlayer](https://github.com/google/ExoPlayer) | Media player                                        |
| [okhttp](https://github.com/square/okhttp)       | Networking framework                                |
| [onnx](https://github.com/onnx/onnx)             | Artificial intelligence framework                   |
| [ncnn](https://github.com/Tencent/ncnn)          | High-performance neural network computing framework |