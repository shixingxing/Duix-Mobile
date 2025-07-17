//
//  GJHttpManager.h
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/14.
//

#import <Foundation/Foundation.h>



@interface GJHttpManager : NSObject
+ (GJHttpManager *)manager;
/*
 modeType 0 默认生产  1测试  2开发
 */
@property (nonatomic, assign) NSInteger modeType;

-(NSString*)getBaseUrl;

-(NSString*)getWsUrl;
//授权
+ (void)getApplicationSigWithAppId:(NSString *)appId appKey:(NSString *)appKey block:(void (^) (BOOL isSuccess, NSString *msg, NSString *appsign))block;
//获取数字人资源下载地址
+ (void)getdDigitalUrlWithConversationId:(NSString *)conversationId block:(void (^) (BOOL isSuccess, NSString *msg, NSString *digitalUrl))block;
//检查是否存在可用时长
+ (void)checkDurationWithAppId:(NSString *)appId block:(void (^) (BOOL isSuccess, NSString *msg))block;
//创建会话 chatSessionId app会话id
+ (void)toCreateSession:(NSString *)sig chatSessionId:(NSString*)chatSessionId conversationId:(NSString*)conversationId block:(void (^) (BOOL isSuccess, NSString *msg,NSString *sessionId,id responseObject))block;
//结束会话
+ (void)toEndSession:(NSString *)sig sessionId:(NSString*)sessionId chatSessionId:(NSString*)chatSessionId block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block;
//心跳
+ (void)toHeartBeat:(NSString *)sig sessionId:(NSString*)sessionId chatSessionId:(NSString*)chatSessionId block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block;
//创建tts链接
+ (void)toCreateTTS:(NSString *)content conversationId:(NSString*)conversationId isWav:(BOOL)isWav block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block;

+(void)toReport:(NSMutableArray*)data_arr block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block;
@end


