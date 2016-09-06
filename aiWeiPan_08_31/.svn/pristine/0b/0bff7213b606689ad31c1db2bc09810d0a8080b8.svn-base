//
//  LoginCheckViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/16.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "LoginCheckViewController.h"
#import "LoginPasswordCheckViewController.h"
#import "KKGestureLockView.h"
#import "MainViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#define WIDTH CGRectGetWidth(self.view.bounds)
#define HEIGHT CGRectGetHeight(self.view.bounds)
@interface LoginCheckViewController ()<KKGestureLockViewDelegate,PopViewControllerDelegate>

@property (strong,nonatomic) UIImageView *logoView;//logo视图
@property (strong,nonatomic) UILabel *promptLabel;//提示语
@property (strong,nonatomic) KKGestureLockView *checkView;//九宫格
@property (strong,nonatomic) UIButton *checkLoginPasswordButton;//验证登录密码
@property (strong,nonatomic) UIView * backView;
@property (strong,nonatomic) NSTimer* timer;
@property (strong,nonatomic) UILabel * countDownLabel;
@property (assign,nonatomic) int secends;

@end

@implementation LoginCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *onstr = [[NSUserDefaults standardUserDefaults] objectForKey:@"FingerPrint"];
    if ([onstr isEqualToString:@"yesStr"]) {//开启指纹验证
        [self authenticateUser];
    }
    self.navigationController.navigationBar.hidden = YES;
    
    _codeFalseNum = 5;
    //------ 九宫格视图 ------
    _checkView = [[KKGestureLockView alloc]initWithFrame:self.view.bounds];
    _checkView.normalGestureNodeImage = [UIImage imageNamed:@"moren"];
    _checkView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
    _checkView.lineColor = [UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:0.8];
    _checkView.lineWidth = 5;
    _checkView.delegate = self;
    _checkView.backgroundColor = [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1];
    CGFloat buttom = HEIGHT * 0.7166 + 16 - WIDTH;
    _checkView.contentInsets = UIEdgeInsetsMake(HEIGHT * 0.2833+64,40,buttom,40);
    [self.view addSubview:_checkView];
    
    //------ APP logo图片 ------
    CGSize imageSize = [UIImage imageNamed:@"logo"].size;
    _logoView = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH-imageSize.width)*0.5, 74, imageSize.width, imageSize.height)];
    _logoView.image = [UIImage imageNamed:@"logo"];
    [_checkView addSubview:_logoView];
    
    //------ 提示语 ------
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_logoView.frame), WIDTH, 40)];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.text = @"请绘制启动密码";
    _promptLabel.font = [UIFont systemFontOfSize:14.0f];
    [_checkView addSubview:_promptLabel];
    
    //------ 验证登录密码按钮 ------
    _checkLoginPasswordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _checkLoginPasswordButton.frame = CGRectMake(WIDTH*0.5-50, HEIGHT-35, 100, 35);
    [_checkLoginPasswordButton setTitle:@"验证登陆密码" forState:UIControlStateNormal];
    [_checkLoginPasswordButton setTitleColor:[UIColor colorWithRed:18/255.0 green:113/255.0 blue:219/255.0 alpha:1] forState:UIControlStateNormal];
    _checkLoginPasswordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_checkLoginPasswordButton addTarget:self action:@selector(checkLoginPassword) forControlEvents:UIControlEventTouchUpInside];
    [_checkView addSubview:_checkLoginPasswordButton];
}
- (void)authenticateUser
{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    NSString* result = @"请进行指纹验证.";
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                MainViewController *main = [[MainViewController alloc]init];
                [self presentViewController:main animated:YES completion:nil];
            }
        }];
    }
}

- (void)checkLoginPassword{
    LoginPasswordCheckViewController *lpcVc = [[LoginPasswordCheckViewController alloc] init];
    lpcVc.delegate = self;
    lpcVc.isError = NO;
    [self.navigationController pushViewController:lpcVc animated:YES];
}

- (void)setPopViewControoler{
    self.navigationController.navigationBar.hidden = YES;
}
//------ 九宫格的点击代理方法 ------
-(void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)Endpasscode{
    _codeFalseNum--;
    
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"code"];
    if ([code isEqualToString:Endpasscode]) {
        _logoView.image = [UIImage imageNamed:@"logo_green"];
        _promptLabel.text = @"验证成功";
        _promptLabel.textColor = [UIColor greenColor];
        for (UIButton *button in _checkView.selectedButtons) {
            [button setImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
        }
        [NSThread sleepForTimeInterval:0.5];
        [self presentViewController:[[MainViewController alloc] init] animated:YES completion:nil];
    }else{
        _logoView.image = [UIImage imageNamed:@"logo_red"];
        _checkView.lineColor = [UIColor redColor];
        for (UIButton *button in _checkView.selectedButtons) {
            button.imageView.image = [UIImage imageNamed:@"red"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UIButton *button in _checkView.selectedButtons) {
                button.selected = NO;
            }
            [_checkView.selectedButtons removeAllObjects];
            _checkView.trackedLocationInContentView = CGPointMake(-1, -1);
            _checkView.lineColor = [UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:0.8];
            _logoView.image = [UIImage imageNamed:@"logo"];
        });
        if (_codeFalseNum<=0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您已连续5次输错手势，启动密码已关闭，请重新登录。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LoginPasswordCheckViewController *lpcVc = [[LoginPasswordCheckViewController alloc] init];
                lpcVc.delegate = self;
                lpcVc.isError = YES;
                NSUserDefaults *isError = [NSUserDefaults standardUserDefaults];
                NSString *isErrorString = [NSString stringWithFormat:@"%d",_codeFalseNum];
                [isError setObject:isErrorString forKey:@"_codeFalseNum"];
                [self.navigationController pushViewController:lpcVc animated:YES];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        _promptLabel.text = [NSString stringWithFormat:@"密码错误，您还可以再输入%d次",_codeFalseNum];
        _promptLabel.textColor = [UIColor redColor];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end