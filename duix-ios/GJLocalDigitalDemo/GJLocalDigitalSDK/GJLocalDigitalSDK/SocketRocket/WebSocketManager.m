//
//  WebSocketManager.m
//  GuiYuSiri
//
//  Created by guiji on 2021/8/11.
//

#import "WebSocketManager.h"
#import "GJLGCDTimer.h"
#import "GJHttpManager.h"
@interface WebSocketManager()

@property (nonatomic, strong) GJLGCDTimer *reconnectTimer;
@property (nonatomic, strong) dispatch_queue_t reconnect_timer_queue;
@property (nonatomic, strong)NSMutableDictionary * headDic;
@end
@implementation WebSocketManager
static WebSocketManager *_sharedSingleton = nil;
+(WebSocketManager*)manager
{

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          
            if (_sharedSingleton==nil) {

                _sharedSingleton = [[WebSocketManager alloc] init];
            }

          
        });
        return _sharedSingleton;
}
-(id)init
{
    self=[super init];
    if(self)
    {
        self.headDic=[[NSMutableDictionary alloc] init];
        self.reconnect_timer_queue= dispatch_queue_create("com.digitalsdk.reconnect_timer_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
#pragma mark ---------------------与websocket建立连接--------------------------
-(void)reconnect
{
    self.time1=[[NSDate date] timeIntervalSince1970];
    if(self.webSocket!=nil)
    {
        self.webSocket.delegate = nil;
        [self.webSocket close];
         self.webSocket = nil;
    }
    if ([web_timer isValid]) {
        [web_timer invalidate];
        web_timer=nil;
    }
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    [NSThread detachNewThreadSelector:@selector(toStartContent) toTarget:self withObject:nil];
 

}
-(void)toStart:(NSDictionary*)dic
{
    [self.headDic removeAllObjects];
    [self.headDic addEntriesFromDictionary:dic];
    self.connect_count=0;
    [self reconnect];
}
-(void)toStartContent
{
    

    NSString *url =[[GJHttpManager manager] getWsUrl];
    NSLog(@"url:%@",url);

// url根据公司的要求，样式和参数不同
    NSMutableURLRequest* request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval=60;
    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//这个很关键，一定要设置
//    [request setValue:auth forHTTPHeaderField:@"auth"];//这里就是你自己对应的参数
//    [request setValue:uuid forHTTPHeaderField:@"uuid"];//这里就是你自己对应的参数
//    [request setValue:endpoint forHTTPHeaderField:@"endpoint"];//这里就是你自己对应的参数

    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocket.delegate = self;
    [self.webSocket open];
}
#pragma mark - SRWebSocketDelegate // 代理方法
// 连接成功
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{

  //  [self sendHeart];
    double time2=[[NSDate date] timeIntervalSince1970];
    NSLog(@"连接时长:%f",time2-self.time1);
//每30秒发送一次心跳
    web_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(sendHeart) userInfo:nil repeats:YES];
//  心跳间隔时间和心跳内容询问后台
    NSLog(@"Websocket Connected");
    self.isOpen=YES;
    if(self.on_success)
    {
        self.on_success(1);
    }
}
// 连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
// 这里可进行重连
    self.isOpen=NO;
    
    if(error!=nil)
    {
        self.connect_count++;
        if(self.connect_count>10)
        {
            [self toStopReconnectTimer];
            __weak typeof(self)weakSelf = self;
            self.reconnectTimer =[GJLGCDTimer scheduledTimerWithTimeInterval:5 repeats:NO queue:self.reconnect_timer_queue block:^{
                [weakSelf reconnect];
            }];
        }
        else
        {
            [self reconnect];
        }
      
    }
    
    if (self.on_err) {
        self.on_err(error);
    }
    NSLog(@":( Websocket Failed With Error %@", error);
}
// 接收数据
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
// 在这里进行数据的处理
//    NSLog(@"message返回:%@",message);
    if (self.on_message)
    {
        self.on_message(message);
   }
    
//    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
//    id jsonObject = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:nil];
//    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"Unexpected message: %@", jsonObject);
//        return;
//    }
//    NSDictionary * dic=jsonObject;
//    if([dic isKindOfClass:[NSDictionary class]])
//    {
//        if (self.on_message) {
//            self.on_message(dic);
//        }
//    }
   
//    NSString * code_str=[dic objectForKey:@"code"]?:@"";
//   // NSString * msg_str=[dic objectForKey:@"msg"];
//
//    if ([code_str integerValue]==0) {
//        NSString * data_str=[dic objectForKey:@"data"]?:@"";
//        int position=[data_str intValue];
//        if (position>0)
//        {
//
//            if (self.on_message) {
//                self.on_message(position);
//            }
//          
//        }
//    }
    
}
// 连接关闭
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
// 判断是何种情况的关闭，如果是人为的就不需要重连，如果是其他情况，就重连
  //  [SVProgressHUD showInfoWithStatus:@"webSocket Closed"];
    NSLog(@"webSocket Closed!:%@",reason);
}
// 接收服务器发送的pong消息
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"Websocket received pong");
}
// 发送心跳
- (void)sendHeart{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setValue:@"ping" forKey:@"eventType"];
//    NSString *heartBeat = [GJLGlobalFunc dataToJsonString:dict];
//    @try {
//        if (self.isOpen)
//        {
//            [self sendMesage:heartBeat];
//        }
//      
//    } @catch (NSException *exception) {
//       //  发送心跳出错
//        [self reconnect];
//    }
   
}
-(void)sendMesage:(NSString*)mesage
{
    if (mesage!=nil && self.isOpen)
    {
        [ self.webSocket send:mesage];
    }
}

- (void)sendData:(NSData *)data {
    
//    NSLog(@"data.length:%ld",data.length);
    if (data!=nil&&data.length != 0 && self.isOpen)
    {
        [ self.webSocket send:data];
    }
    
}
-(void)toStopReconnectTimer
{
    if(self.reconnectTimer!=nil) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
}
-(void)stopWebSocket
{
    [self.headDic removeAllObjects];
    if ([web_timer isValid]) {
        [web_timer invalidate];
        web_timer=nil;
    }
    [self toStopReconnectTimer];
    self.connect_count=0;
    self.isOpen = NO;
    [self.webSocket close];
    self.webSocket = nil;
    self.webSocket.delegate = nil;
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
}

@end
