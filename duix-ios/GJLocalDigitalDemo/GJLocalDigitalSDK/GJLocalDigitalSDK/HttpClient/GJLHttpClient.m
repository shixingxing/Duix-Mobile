//
//  HttpClient.m
//  Xici
//
//  Created by XICI-Jacob on 10/31/13.
//
//

#import "GJLHttpClient.h"
#import "GJLOpenUDID.h"
#import <zlib.h>

@implementation GJLHttpClient


+ (GJLHttpClient *)manager {
    static dispatch_once_t onceToken;
    static GJLHttpClient *_sharedMangaer=nil;
    dispatch_once(&onceToken, ^{
        if (!_sharedMangaer) {
            _sharedMangaer=[[GJLHttpClient alloc]init];
        }
    });
    return _sharedMangaer;
}

- (id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

-(void)requestWithBaseURL:(NSString *)url
                     para:(NSDictionary *)parameters
                  headers:(NSDictionary *)headers
               httpMethod:(HttpMethod)httpMethod
                  success:(void (^)( id responseObject))success
                  failure:(void (^)(NSURLSessionDataTask * task,NSError *error))failure
{
    
    GJLAFHTTPSessionManager *manager = [GJLAFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[GJLAFJSONRequestSerializer serializer];

    double time=[[NSDate date] timeIntervalSince1970];
    NSString * token =self.token?:@"";
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * skipVersion=[[NSUserDefaults standardUserDefaults] valueForKey:@"skipVersion"];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    headers=@{@"deviceType":@"1",@"deviceID":[GJLOpenUDID value],@"token":token,@"version":app_Version,@"skipVersion":skipVersion?:@"0",@"packageName":bundleID};

    //申明返回的结果是json类型
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (httpMethod == HttpMethodPost_Form) {
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        httpMethod = HttpMethodPost;
        
    }
   else  if (httpMethod == HttpMethodGet_Form)
    {
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        httpMethod =    HttpMethodGet;
    }
    else
    {
         manager.requestSerializer=[GJLAFJSONRequestSerializer serializer];
         manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"image/jpg",@"audio/mpeg", nil];
    
      
    }
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
     manager.requestSerializer.timeoutInterval=60.0;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    if (httpMethod == HttpMethodPost) {
        [manager POST:url parameters:parameters headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            double time2=[[NSDate date] timeIntervalSince1970];
            NSLog(@"\nHttpClient====time:%f\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",time2-time,url,parameters,responseObject);
            success(responseObject);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"\nHttpClient==end==error=\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",url,parameters,error);
            failure(task,error);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        }];
    } else if (httpMethod==HttpMethodGet) {        
        [manager GET:url parameters:parameters headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            double time2=[[NSDate date] timeIntervalSince1970];
            NSLog(@"\nHttpClient====time:%f\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",time2-time,url,parameters,responseObject);
            success(responseObject);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"\nHttpClient====error=\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",url,parameters,error);
            failure(task,error);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        }];
    }
}

///// 上传图片接口
///// @param url 上传地址
///// @param parameters 入参
///// @param headers 请求头
///// @param imageData 图片data
///// @param fileName 图片的名字
///// @param success 成功回调
///// @param failure 失败回调
//- (void)requestImageWithURL:(NSString *)url
//                       para:(NSDictionary *)parameters
//                    headers:(NSDictionary *)headers
//                  imageData:(NSData *)imageData
//                   fileName:(NSString *)fileName
//                    success:(void (^)( id responseObject))success
//                    failure:(void (^)(NSURLSessionDataTask * task,NSError *error))failure {
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    //申明请求的数据是json类型
//    manager.requestSerializer=[AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
////    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"deviceType"];
//    [manager.requestSerializer setValue:[OpenUDID value] forHTTPHeaderField:@"deviceID"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"image/jpg",@"image/png",@"image/gif",@"video/mp4", nil];
//    double time=[[NSDate date] timeIntervalSince1970];
//    [manager POST:url parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpg/png/jpeg/gif/tiff/mp4/wav/m4a"];
//
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        success(responseObject);
//        double time2=[[NSDate date] timeIntervalSince1970];
//        NSLog(@"\nHttpClient====time:%f\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",time2-time,url,parameters,responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"\nHttpClient====error=\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",url,parameters,error);
//        failure(task,error);
//    }];
//}
- (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                 pathExtension:(NSString*)pathExtern
                                    progress:(void (^)(NSProgress *))progress
                                     success:(void (^)(NSURLResponse *response, NSURL *filePath))success
                                        fail:(void (^)(NSError *error))fail
{
    NSLog(@"url:%@",url);

    GJLAFHTTPSessionManager *manager = [self managerWithBaseURL:nil sessionConfiguration:NO];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"image/jpg",@"image/png",@"audio/wav",@"audio/mpeg", nil];
    NSURL *urlpath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlpath];
    NSLog(@"fileURL:%@",fileURL.absoluteString) ;
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString * filename=[response suggestedFilename];
        if (pathExtern!=nil) {
            filename= [filename stringByDeletingPathExtension];
            filename=[NSString stringWithFormat:@"%@.%@",filename,pathExtern];
        }
        return [fileURL URLByAppendingPathComponent:filename];
//        return fileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            fail(error);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        } else {
            success(response,filePath);
            [manager invalidateSessionCancelingTasks:YES resetSession:YES];
        }
    }];
    [downloadtask resume];
    return downloadtask;
}

- (GJLAFHTTPSessionManager *)managerWithBaseURL:(NSString *)baseURL  sessionConfiguration:(BOOL)isconfiguration {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    GJLAFHTTPSessionManager *manager = nil;
    NSURL *url = [NSURL URLWithString:baseURL];
    if (isconfiguration) {
        
        manager = [[GJLAFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:configuration];
    } else {
        manager = [[GJLAFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    manager.requestSerializer = [GJLAFHTTPRequestSerializer serializer];
    manager.responseSerializer = [GJLAFHTTPResponseSerializer serializer];
    return manager;
}
/// 上传图片接口
/// @param url 上传地址
/// @param parameters 入参
/// @param headers 请求头
/// @param imageData 图片data
/// @param fileName 图片的名字
/// @param success 成功回调
/// @param failure 失败回调
- (void)requestImageWithURL:(NSString *)url
                       para:(NSDictionary *)parameters
                    headers:(NSDictionary *)headers
                  imageData:(NSData *)imageData
                   fileName:(NSString *)fileName
                    success:(void (^)( id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask * task,NSError *error))failure {

    GJLAFHTTPSessionManager *manager = [GJLAFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[GJLAFJSONRequestSerializer serializer];
    manager.responseSerializer = [GJLAFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"deviceType"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"image/jpg",@"image/png",@"image/gif",@"video/mp4", nil];
//    [manager.requestSerializer setValue:@"multipart/form-data; boundary=32343211" forHTTPHeaderField:@"Content-Type"];
//    __weak typeof(self)weakSelf = self;
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * skipVersion=[[NSUserDefaults standardUserDefaults] valueForKey:@"skipVersion"];
    NSString * token = self.token?:@"";
    headers=@{@"deviceType":@"1",@"deviceID":[GJLOpenUDID value],@"token":token,@"version":app_Version,@"skipVersion":skipVersion?:@"0"};
    double time=[[NSDate date] timeIntervalSince1970];
    [manager POST:url parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"imageFile" fileName:fileName mimeType:@"image/jpg/png/jpeg/gif/tiff/mp4/wav/m4a"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        double time2=[[NSDate date] timeIntervalSince1970];
        NSLog(@"\nHttpClient====time:%f\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",time2-time,url,parameters,responseObject);
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
//        if (GYCODE.integerValue == 503) {
//            [weakSelf tokenInvalid];
//        } else if (GYCODE.integerValue == 1006) {
//            //token失效
//            [weakSelf tokenInvalid];
//        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\nHttpClient====error=\nurl=%@:\nparameters=\n%@\nresponseObject=\n%@",url,parameters,error);
        failure(task,error);
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
}

@end
