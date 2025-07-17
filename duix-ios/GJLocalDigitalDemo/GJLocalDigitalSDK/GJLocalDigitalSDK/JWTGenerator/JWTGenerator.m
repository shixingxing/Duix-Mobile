//
//  JWTGenerator.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2025/5/15.
//

#import "JWTGenerator.h"
#import <CommonCrypto/CommonHMAC.h>
@implementation JWTGenerator
+ (NSString *)generateJWTWithPayload:(NSDictionary *)payload
                          secretKey:(NSString *)secretKey {
    // 1. 处理特殊字符的Header
    NSDictionary *header = @{
        @"alg": @"HS256",
        @"typ": @"JWT"
    };
    
    // 2. Base64URL编码Header
    NSData *headerData = [NSJSONSerialization dataWithJSONObject:header options:0 error:nil];
    NSString *headerBase64 = [[self base64EncodedStringFromData:headerData] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    headerBase64 = [headerBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    headerBase64 = [headerBase64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    // 3. 处理Payload中的特殊字符
    NSMutableDictionary *processedPayload = [payload mutableCopy];
    [payload enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *encodedValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
            [processedPayload setValue:encodedValue forKey:key];
        }
    }];
    
    // 4. Base64URL编码Payload
    NSData *payloadData = [NSJSONSerialization dataWithJSONObject:processedPayload options:0 error:nil];
    NSString *payloadBase64 = [[self base64EncodedStringFromData:payloadData] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    payloadBase64 = [payloadBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    payloadBase64 = [payloadBase64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    // 5. 生成签名
    NSString *signingInput = [NSString stringWithFormat:@"%@.%@", headerBase64, payloadBase64];
    NSData *signingInputData = [signingInput dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [secretKey dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, keyData.bytes, keyData.length, signingInputData.bytes, signingInputData.length, digest);
    NSData *signatureData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *signatureBase64 = [[self base64EncodedStringFromData:signatureData] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    signatureBase64 = [signatureBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    signatureBase64 = [signatureBase64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    // 6. 组合JWT
    return [NSString stringWithFormat:@"%@.%@.%@", headerBase64, payloadBase64, signatureBase64];
}

+ (NSString *)base64EncodedStringFromData:(NSData *)data {
    return [data base64EncodedStringWithOptions:0];
}
@end
