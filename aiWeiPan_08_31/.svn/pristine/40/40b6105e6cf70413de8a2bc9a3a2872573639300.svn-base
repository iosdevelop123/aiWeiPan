//
//  WebRequest.m
//  Ejinrong
//
//  Created by dayu on 15/11/9.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "WebRequest.h"
#import "AFNetworking.h"
NSString * const kRequestTypeSetData = @"SetData";
NSString * const kRequestTypeGetData = @"GetData";
NSString * const kRequestTypeTransformData = @"TransformData";
@implementation WebRequest
/*
 传入数据字典，请求类型字符串，请求完成回调代码段参数
 通用网络请求
 */
- (void)webRequestWithDataDic:(NSMutableDictionary *)dataDic requestType:(NSString *)typeString completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (_manager == nil) {
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    _manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"><soap12:Body><%@ xmlns=\"http://tempuri.org/\"><str_json>%@</str_json></%@></soap12:Body></soap12:Envelope>",typeString,jsonString,typeString];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"http://139.196.207.149:10011/WebService.asmx?op=%@",typeString] parameters:nil error:nil];
    [request setValue:@"139.196.207.149" forHTTPHeaderField:@"Host"];
    [request setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d",(int)soapMessage.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}
@end