//
//  SingleSocket.h
//  aiWeiPan
//
//  Created by Secret Wang on 16/9/8.
//  Copyright © 2016年 pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@protocol SingletonSocketDelegate <NSObject>

- (void)SingetonError:(NSError *)error;

- (void)didReadData:(NSString *)data;
@end

@interface SingleSocket : NSObject<GCDAsyncSocketDelegate>

+(SingleSocket *)sharedInstance;
@property (assign,nonatomic) id<SingletonSocketDelegate>delegate;
@property (strong,nonatomic)GCDAsyncSocket *socket;
-(void)socketConnectHost;
-(void)stopSocket;
@end

