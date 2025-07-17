//
//  JWTGenerator.h
//  GJLocalDigitalSDK
//
//  Created by guiji on 2025/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface JWTGenerator : NSObject

+ (NSString *)generateJWTWithPayload:(NSDictionary *)payload
                          secretKey:(NSString *)secretKey;

@end

NS_ASSUME_NONNULL_END
