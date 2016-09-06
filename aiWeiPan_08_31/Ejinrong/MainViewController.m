//
//  MainViewController.m
//  Ejinrong
//
//  Created by dayu on 15/9/23.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "MainViewController.h"
#import "RootViewController.h"
#import "LoginNavigationController.h"

@interface MainViewController ()
@end
@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewControllers:@[[[RootViewController alloc] init]]];
    //------ 通知页面跳转 ------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createPush) name:@"push" object:nil];
}

#pragma mark ****** 白色状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark ****** 跳转登陆界面
-(void)createPush{
    LoginNavigationController* vc = [[LoginNavigationController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
@end