//
//  GJLASRCofigModel.m
//  GJLocalDigitalSDK
//
//  Created by guiji on 2025/2/7.
//

#import "GJLASRCofigModel.h"
static GJLASRCofigModel * manager = nil;
@implementation GJLASRCofigModel

+ (GJLASRCofigModel *)manager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[GJLASRCofigModel alloc] init];
    });
    return manager;
}
-(id)init
{
    self=[super init];
    if(self)
    {
      //  self.sampleRate=16000;
        self.end_point=300;
        self.lan=@"zh";
        self.type=@"ali";
        // self.playImageQueue= dispatch_queue_create("com.duixsdk.playImageQueue", DISPATCH_QUEUE_CONCURRENT);
        //        self.mat_type=0;
    }
    return self;
}
@end
