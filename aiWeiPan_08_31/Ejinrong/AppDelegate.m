//
//  AppDelegate.m
//  Ejinrong
//
//  Created by jr on 15/9/16.
//  Copyright (c) 2015年 pan. All rights reserved.
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import "UserGuideViewController.h"
#import <notify.h>
#import "LoginCheckNavigationController.h"
#import "WebRequest.h"
#import "GDataXMLNode.h"
#import "AFNetworking.h"
#import "PrefixHeader.pch"
//获取IP地址
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface AppDelegate ()<UIAlertViewDelegate>
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self getiPhoneIP];
    //------ 判断是不是第一次启动应用 ------
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        //------ 如果是第一次启动的话,使用UserGuideViewController (用户引导页面) 作为根视图 ------
        self.window.rootViewController = [[UserGuideViewController alloc] init];
    } else {
        //------ 如果不是第一次启动的话 ------
        BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
        id code = [[NSUserDefaults standardUserDefaults] objectForKey:@"code"];
        if (isLogin == YES&&code!=nil) { //登录了，使用LoginCheckNavigationController作为根视图，验证手势密码
            self.window.rootViewController = [[LoginCheckNavigationController alloc] init];
        }else{ //未登录，使用mainViewController作为根视图,进入主页面
            self.window.rootViewController = [[MainViewController alloc] init];
        }
    }
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {}
#pragma mark 进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //设置永久后台运行
    UIApplication *app =  [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark 获取ip地址
-(void)getiPhoneIP{
    NSString *address = @"获取ip地址出错";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    NSUserDefaults *iPhoneIP = [NSUserDefaults standardUserDefaults];
    [iPhoneIP setObject:address forKey:@"iPhoneIP"];
}

#pragma mark 禁用第三方输入法
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier{
    return NO;
}
@end
