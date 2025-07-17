//
//  GJHttpManager.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2023/12/14.
//

#import "GJHttpManager.h"
#import "GJLDigitalManager.h"
#import "GJLHttpClient.h"
//#import "SaveAudioModel.h"
#import "GJLASRCofigModel.h"
#define GJNetworkErrorMsg @"网络异常，请稍后尝试"
@implementation GJHttpManager
+ (GJHttpManager *)manager
{
    static GJHttpManager * manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[GJHttpManager  alloc] init];
    });
    return manager;
}
-(NSString*)getBaseUrl
{
    NSString *sdkurl = GJSDKBaseUrl;
    if (self.modeType == 2) {
        sdkurl = GJSDKBaseDevUrl;
    } else if (self.modeType == 1) {
        sdkurl = GJSDKBaseTestUrl;
    }
    return sdkurl;
}
-(NSString*)getWsUrl
{
    NSString *sdkurl = GJSDKWebSocketUrl;
    if (self.modeType == 2) {
        sdkurl = GJSDKWebSocketDevUrl;
    } else if (self.modeType == 1) {
        sdkurl = GJSDKWebSocketTestUrl;
    }
    return sdkurl;
}
//授权
+ (void)getApplicationSigWithAppId:(NSString *)appId appKey:(NSString *)appKey block:(void (^) (BOOL isSuccess, NSString *msg, NSString *appsign))block {
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:appId forKey:@"appId"];
    [dict setValue:appKey forKey:@"appKey"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,GJLGETAPPSIG];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodPost success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
      //  NSDictionary *data_dic=dic[@"data"];
        if (success == 1) {
            NSString *data = dic[@"data"]?:@"";
            block(YES,message,data);
        } else {
            block(NO,message,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil);
    }];
}

+ (void)getdDigitalUrlWithConversationId:(NSString *)conversationId block:(void (^) (BOOL isSuccess, NSString *msg, NSString *digitalUrl))block {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    [dict setValue:conversationId forKey:@"conversationId"];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,GJGETCONVERSATIONBYID];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodGet success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            NSDictionary *data = dic[@"data"];
            NSDictionary *detailDto = data[@"detailDto"];
            NSDictionary *localModelInfo = detailDto[@"localModelInfo"];
            if ([localModelInfo isKindOfClass:[NSDictionary class]]) {
                NSString *modelResourcePath =  [GJLGlobalFunc changeType:localModelInfo[@"modelResourcePath"]];
                block(YES,message,modelResourcePath);
            } else {
                block(YES,message,@"");
            }
        } else {
            block(NO,message,@"");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,@"");
    }];
}

//检查是否存在可用时长
+ (void)checkDurationWithAppId:(NSString *)appId block:(void (^) (BOOL isSuccess, NSString *msg))block {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
   // [dict setValue:appId forKey:@"appId"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@?appId=%@",baseUrl,GJCHECKDURATION,appId];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodGet success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            block(YES,message);
        } else {
            block(NO,message);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg);
    }];
}

//创建会话
+ (void)toCreateSession:(NSString *)sig chatSessionId:(NSString*)chatSessionId conversationId:(NSString*)conversationId block:(void (^) (BOOL isSuccess, NSString *msg,NSString *sessionId,id responseObject))block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setValue:sig forKey:@"sig"];
//    [dict setValue:chatSessionId forKey:@"chatSessionId"];
//    [dict setValue:conversationId forKey:@"conversationId"];
//    
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@?sig=%@&chatSessionId=%@&conversationId=%@",baseUrl,CREATESESSIONV2,sig,chatSessionId,conversationId];
    if(conversationId==nil || [conversationId isKindOfClass:[NSNull class]] || ([conversationId isKindOfClass:[NSString class]] && conversationId.length==0 ))
    {
        url = [NSString stringWithFormat:@"%@%@?sig=%@&chatSessionId=%@",baseUrl,CREATESESSIONV2,sig,chatSessionId];
    }

    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];


    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodGet_Form success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        NSDictionary *data_dic=dic[@"data"];
   
        if([data_dic isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *conversationDto=data_dic[@"conversationDto"];
            if([conversationDto isKindOfClass:[NSDictionary class]])
            {
                [GJLASRCofigModel manager].end_point=[[GJLGlobalFunc changeType:conversationDto[@"asrEndPoint"]] integerValue];
                if([GJLASRCofigModel manager].end_point==0)
                {
                    [GJLASRCofigModel manager].end_point=300;
                }
            }
       
    
        }
        if ([data_dic isKindOfClass:[NSDictionary class]])
        {
            NSString * sessionId=data_dic[@"sessionId"]?:@"";
            if (success == 1) {
                block(YES,message,sessionId,responseObject);
            } else {
                block(NO,message,nil,responseObject);
            }
        }
        else
        {
            block(NO,message,nil,responseObject);
        }
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil,nil);
    }];
}
//结束会话
+ (void)toEndSession:(NSString *)sig sessionId:(NSString*)sessionId chatSessionId:(NSString*)chatSessionId block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:sig forKey:@"sig"];
    [dict setValue:sessionId forKey:@"sessionId"];
    [dict setValue:chatSessionId forKey:@"chatSessionId"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,GJLENDSESSION];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodGet_Form success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            block(YES,message,responseObject);
        } else {
            block(NO,message,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil);
    }];
}
//心跳
+ (void)toHeartBeat:(NSString *)sig sessionId:(NSString*)sessionId chatSessionId:(NSString*)chatSessionId block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:sig forKey:@"sig"];
    [dict setValue:sessionId forKey:@"sessionId"];
    [dict setValue:chatSessionId forKey:@"chatSessionId"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,GJLHEARTBEAT];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodGet_Form success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            block(YES,message,responseObject);
        } else {
            block(NO,message,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil);
    }];
}
//创建tts链接
+ (void)toCreateTTS:(NSString *)content conversationId:(NSString*)conversationId isWav:(BOOL)isWav block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:content forKey:@"content"];
    [dict setValue:conversationId forKey:@"conversationId"];
    [dict setValue:[NSNumber numberWithBool:isWav] forKey:@"isWav"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,CREATETTS];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodPost success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            block(YES,message,responseObject);
        } else {
            block(NO,message,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil);
    }];
}
+(void)toReport:(NSMutableArray*)data_arr block:(void (^) (BOOL isSuccess, NSString *msg,id responseObject))block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(int i=0;i<data_arr.count;i++)
    {
       // SaveAudioModel * saveAudioModel=data_arr[i];
        
    }
//    [dict setValue:[NSNumber numberWithDouble:audio_duration] forKey:@"duration"];
    NSString * baseUrl=[[GJHttpManager manager] getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseUrl,CREATETTS];
    [[GJLHttpClient manager] requestWithBaseURL:url para:dict headers:nil httpMethod:HttpMethodPost success:^(id responseObject) {
        NSDictionary * dic=responseObject;
        NSInteger success=[dic[@"success"]?:@"" integerValue];
        NSString * message=dic[@"message"]?:@"";
        if (success == 1) {
            block(YES,message,responseObject);
        } else {
            block(NO,message,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,GJNetworkErrorMsg,nil);
    }];
}
@end
