//
//  DeleteCheckGesturePasswordViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "DeleteCheckGesturePasswordViewController.h"
#import "CustomNavigation.h"
#import "GesturePasswordViewController.h"

#define BLACKCOLOR [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0]
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface DeleteCheckGesturePasswordViewController ()<PopViewControllerDelegate>
{
    UILabel* _promptLabel;
    UIImageView* _promptImgV;
    int _falseNum;
    UIView* _backView;
    int _seconds;
    UILabel* _countDownLabel;
    NSTimer *_timer;
}
@end

@implementation DeleteCheckGesturePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"删除启动密码" navigationBarBgColor:BLACKCOLOR backSelector:@selector(back:)];
    _falseNum = 5;
    

    self.view.backgroundColor = BLACKCOLOR;
    [self createUI];
    [self creataBackView];
}

#pragma mark ****** 创建密码错误遮罩层
-(void)creataBackView
{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, -HEIGHT, WIDTH, HEIGHT-35)];
    _backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
    [self.view addSubview:_backView];
    
    _countDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT* 0.3, WIDTH, 44)];
    _countDownLabel.textColor = [UIColor redColor];
    _countDownLabel.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:_countDownLabel];
}

- (void)back:(UIBarButtonItem *)sender{
    [_delegate setPopViewControoler];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createUI
{
    CGFloat buttom = HEIGHT * 0.7166 + 16 - WIDTH;
    _lockView = [[KKGestureLockView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    _lockView.normalGestureNodeImage = [UIImage imageNamed:@"moren"];
    _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
    _lockView.lineColor = [[UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:1.0] colorWithAlphaComponent:1.0];
    _lockView.lineWidth = _isShowLine?5:0;
    _lockView.delegate = self;
    _lockView.contentInsets = UIEdgeInsetsMake(HEIGHT * 0.2833,40,buttom,40);
    _lockView.backgroundColor = BLACKCOLOR;
    
    _promptImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    [_promptImgV setFrame:CGRectMake(WIDTH/2-45, 10, 90, 90)];
    [_lockView addSubview:_promptImgV];
    _promptLabel=  [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_promptImgV.frame), WIDTH, 40)];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.font = [UIFont systemFontOfSize:14.0f];
    _promptLabel.text = @"请绘制启动密码";
    _promptLabel.textColor = [UIColor grayColor];
    
    UIButton* passButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [passButton setTitle:@"验证密码登陆" forState:UIControlStateNormal];
    passButton.frame = CGRectMake(0, HEIGHT-104, WIDTH, 35);
    passButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [passButton addTarget:self action:@selector(checkLoginPassword) forControlEvents:UIControlEventTouchUpInside];
    [_lockView addSubview:passButton];
    [_lockView addSubview:_promptLabel];
    [self.view addSubview:_lockView];
}
#pragma mark ****** 绘制手势密码结束
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)Endpasscode{
   [self deleteCode:Endpasscode];
}
#pragma mark ****** 删除手势密码
-(void)deleteCode:(NSString*)sender
{
    _falseNum--;
    NSString* codeNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    if ([codeNum isEqualToString:sender]) {
        _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"green"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _promptImgV.image = [UIImage imageNamed:@"logo_green"];
         _promptLabel.text = @"验证成功";
        _promptLabel.textColor = [UIColor greenColor];
         
        });
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"code"];  
        GesturePasswordViewController* vc = [[GesturePasswordViewController alloc]init];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[vc class]]) {
                    controller.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1];
                     [NSThread sleepForTimeInterval:0.8];
                    NSDictionary *dict = @{@"operationType":@"delete"};
                    //创建通知
                    NSNotification *notification =[NSNotification notificationWithName:@"showTopView" object:nil userInfo:dict];
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                    [self.navigationController popToViewController:controller animated:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"change" object:nil];
                }
            }
        }else{
         _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"red"];
         _promptImgV.image = [UIImage imageNamed:@"logo_red"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _promptImgV.image = [UIImage imageNamed:@"logo"];
            _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
        });
        if (_falseNum<=0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您已连续5次输错手势，启动密码已关闭，请重新登录。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LoginPasswordCheckViewController *lpcVc = [[LoginPasswordCheckViewController alloc] init];
                lpcVc.delegate = self;
                NSUserDefaults *isError = [NSUserDefaults standardUserDefaults];
                NSString *isErrorString = [NSString stringWithFormat:@"%d",_falseNum];
                [isError setObject:isErrorString forKey:@"_codeFalseNum"];
                lpcVc.isError = YES;
                [self.navigationController pushViewController:lpcVc animated:YES];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        _promptLabel.text = [NSString stringWithFormat:@"愿密码输入错误，还有%d次机会",_falseNum];
        _promptLabel.textColor = [UIColor redColor];
    }
}
#pragma mark ****** 倒计时
-(void)timerFireMethod:(NSTimer *)theTimer
{
    _seconds--;
    if (_seconds==0) {
        [_timer invalidate];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect r = _backView.frame;
            r.origin.y = -HEIGHT;
            _backView.frame = r;
        }];
        _falseNum = 5;
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.text = @"请绘制启动密码";
    }
    _countDownLabel.text = [NSString stringWithFormat:@"倒计时：%d秒后请重新绘制",_seconds];
}
#pragma mark ****** 跳转密码验证页面
- (void)checkLoginPassword{
    LoginPasswordCheckViewController *lpcVc = [[LoginPasswordCheckViewController alloc] init];
    lpcVc.delegate = self;
    [self.navigationController pushViewController:lpcVc animated:YES];
}

- (void)setPopViewControoler{
    self.navigationController.navigationBar.barTintColor = BLACKCOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end