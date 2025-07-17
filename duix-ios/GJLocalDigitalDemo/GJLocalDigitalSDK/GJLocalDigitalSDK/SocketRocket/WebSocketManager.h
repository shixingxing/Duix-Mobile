//
//  WebSocketManager.h
//  GuiYuSiri
//
//  Created by guiji on 2021/8/11.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

typedef void (^onMessage)(id message);
typedef void (^onError)(NSError*err);
typedef void (^onSucess)(NSInteger type);
@interface WebSocketManager : NSObject<SRWebSocketDelegate>
{
    NSTimer * web_timer;
}
+(WebSocketManager*)manager;
@property (nonatomic, strong)SRWebSocket * webSocket;
@property (nonatomic, copy) onSucess on_success;
@property (nonatomic, copy) onMessage on_message;
@property (nonatomic, copy) onError on_err;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign)double time1;
@property (nonatomic, assign)BOOL isASRSucess;
@property (nonatomic, assign) NSInteger connect_count;
-(void)toStart:(NSDictionary*)dic;
-(void)reconnect;
-(void)sendMesage:(NSString*)mesage;
-(void)stopWebSocket;
- (void)sendData:(NSData *)data;

@end


