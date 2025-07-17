//
//  GJLASRCofigModel.h
//  GJLocalDigitalSDK
//
//  Created by guiji on 2025/2/7.
//

#import <Foundation/Foundation.h>



@interface GJLASRCofigModel : NSObject
/*
 *endPoint 默认中文=300 目前只支持中文
 *设置语言放在【[GJLDigitalManager manager] toStart:^(BOOL isSuccess, NSString *errorMsg)]之前生效
 */
@property (nonatomic, assign)NSInteger end_point;

@property (nonatomic, strong)NSString * lan;

@property (nonatomic, strong)NSString * type;

+ (GJLASRCofigModel*)manager;
@end


