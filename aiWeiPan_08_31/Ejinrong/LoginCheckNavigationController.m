//
//  LoginCheckNavigationController.m
//  Ejinrong
//
//  Created by dayu on 15/10/17.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "LoginCheckNavigationController.h"
#import "LoginCheckViewController.h"
#import "LoginPasswordCheckViewController.h"
@interface LoginCheckNavigationController ()
@end

@implementation LoginCheckNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *isError = [NSUserDefaults standardUserDefaults];
     NSString *isErrorString = [isError objectForKey:@"_codeFalseNum"];
    NSInteger is = [isErrorString intValue];
    if (is >0) {
           [self setViewControllers:@[[[LoginCheckViewController alloc] init]]];
    }else{
        LoginPasswordCheckViewController *login = [[LoginPasswordCheckViewController alloc] init];
        login.isError = YES;
        [self setViewControllers:@[login]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end