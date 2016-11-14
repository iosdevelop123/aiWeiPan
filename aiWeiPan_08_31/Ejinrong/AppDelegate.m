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

static NSString* const kBuyerAppUpdateUrl = @"https://itunes.apple.com/cn/app/heng-de8.0/id1157853548?mt=8";

@interface AppDelegate ()<UIAlertViewDelegate>
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self getiPhoneIP];
    [self VersionUpdate];
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
#pragma mark ****** 新版本更新提示
-(void)VersionUpdate{
    //定义的App地址
    NSString *appurl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",@"1157853548"];
    //AppID即是如图红色箭头获取的AppID
    //PS:有的时候可能会请求不到数据，但是AppID对了，有可能是App是上架区域范围的原因，建议使用在com末尾加上“／cn”
    //例：NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",AppID];
    
    
    //网络请求App的信息（我们取Version就够了）
    NSURL *url = [NSURL URLWithString:appurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            
            //data是有关于App所有的信息
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue] > 0) {
                
                [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
                
                //请求的有数据，进行版本比较
                [self performSelectorOnMainThread:@selector(receiveData:) withObject:receiveStatusDic waitUntilDone:NO];
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
            }
        }else{
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        
    }];
    
    [task resume];
}
-(void)receiveData:(id)sender
{
    //获取APP自身版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *versionArray = [sender[@"version"] componentsSeparatedByString:@"."];
    
    
    if ((versionArray.count == 3) && (localArray.count == versionArray.count)) {
        
        if ([localArray[0] intValue] <  [versionArray[0] intValue]) {
            [self updateVersion];
        }else if ([localArray[0] intValue]  ==  [versionArray[0] intValue]){
            if ([localArray[1] intValue] <  [versionArray[1] intValue]) {
                [self updateVersion];
            }else if ([localArray[1] intValue] ==  [versionArray[1] intValue]){
                if ([localArray[2] intValue] <  [versionArray[2] intValue]) {
                    [self updateVersion];
                }
            }
        }
    }
}
-(void)updateVersion{
    NSString *msg = [NSString stringWithFormat:@"又出新版本啦，快点更新吧!"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"升级提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"现在升级"style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
        NSURL *url = [NSURL URLWithString:kBuyerAppUpdateUrl];
        [[UIApplication sharedApplication]openURL:url];
//        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"1157853548"];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
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
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    WLog(@"%@",deviceToken);
}



@end
