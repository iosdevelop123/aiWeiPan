//
//  SingleSocket.m
//  aiWeiPan
//
//  Created by Secret Wang on 16/9/8.
//  Copyright © 2016年 pan. All rights reserved.
//

#import "SingleSocket.h"

static  NSString*const _IP_ADDRESS = @"139.196.207.149";
static int const _SERVER_PORT = 2012;

@implementation SingleSocket
+(SingleSocket *)sharedInstance{
    static SingleSocket *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}
-(void)socketConnectHost{
    NSError *error = nil;
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_socket connectToHost:_IP_ADDRESS onPort:_SERVER_PORT error:&error];
    if (error != nil) {
        if ([_delegate respondsToSelector:@selector(SingetonError:)]) {
            [_delegate SingetonError:error];
        }
    }
}
-(void)stopSocket{
    [_socket disconnect];
}
#pragma mark ****** asyncSocket代理方法
//建立连接
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"onScoket:%p did connecte to host:%@ on port:%d",sock,host,port);
    [sock readDataWithTimeout:60 tag:10];
}
//读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *aStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([_delegate respondsToSelector:@selector(didReadData:)]) {
        [_delegate didReadData:aStr];
    }
    NSData *aData=[@"Hi" dataUsingEncoding:NSUTF8StringEncoding];
    //给服务器发送信息
    [sock writeData:aData withTimeout:-1 tag:10];
    //读取信息
    [sock readDataWithTimeout:60 tag:tag];
}
//断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if ([_delegate respondsToSelector:@selector(SingetonError:)]) {
        [_delegate SingetonError:err];
    }
}
@end
