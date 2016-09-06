//  WebRequest.h
//  Ejinrong
//  Created by dayu on 15/11/9.
//  Copyright © 2015年 pan. All rights reserved.
#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface WebRequest : NSObject
extern NSString * const kRequestTypeSetData;
extern NSString * const kRequestTypeGetData;
extern NSString * const kRequestTypeTransformData;
@property (strong,nonatomic) AFURLSessionManager *manager;
- (void)webRequestWithDataDic:(NSMutableDictionary *)dataDic requestType:(NSString *)typeString completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
@end