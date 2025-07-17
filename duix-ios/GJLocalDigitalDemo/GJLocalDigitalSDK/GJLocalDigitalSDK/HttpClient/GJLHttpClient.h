//
//  HttpClient.h
//  Xici
//
//  Created by XICI-Jacob on 10/31/13.
//
//

#import "GJLAFNetworking.h"

typedef enum HttpMethod{
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPost_Form, // post表单请求
    HttpMethodGet_Form, // GET表单请求
}HttpMethod;



@interface GJLHttpClient : NSObject
{
    NSString *lastUploadString;
}

@property(nonatomic,strong)NSString* token;
+ (GJLHttpClient *)manager;

- (void)requestWithBaseURL:(NSString *)url
      para:(NSDictionary *)parameters
     headers:(NSDictionary *)headers
    httpMethod:(HttpMethod)httpMethod
    success:(void (^)( id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;



- (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                 savePathURL:(NSURL *)fileURL
                                 pathExtension:(NSString*)pathExtern
                                    progress:(void (^)(NSProgress *))progress
                                     success:(void (^)(NSURLResponse *response, NSURL *filePath))success
                                         fail:(void (^)(NSError *error))fail;

- (void)requestImageWithURL:(NSString *)url
                       para:(NSDictionary *)parameters
                    headers:(NSDictionary *)headers
                  imageData:(NSData *)imageData
                   fileName:(NSString *)fileName
                    success:(void (^)( id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask * task,NSError *error))failure;
@end
