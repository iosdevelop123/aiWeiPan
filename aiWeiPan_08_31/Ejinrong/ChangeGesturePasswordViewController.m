//
//  ChangeGesturePasswordViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "ChangeGesturePasswordViewController.h"
#import "GesturePasswordViewController.h"
#import "CustomNavigation.h"
#define BLACKCOLOR [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0]
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface ChangeGesturePasswordViewController ()
{
    UILabel* _promptCheckLabel;
    UILabel* _promptchangeLabel;
    BOOL _checkSuccess;
    UIImageView * _logeImageView;
    int _falseNum;
    UIView* _backView;
    
    int _seconds;
    UILabel* _countDownLabel;
    
    NSTimer *_timer;
    
    UIView*_checkView;
    UIImageView *_huadongImageView;
}
@end

@implementation ChangeGesturePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CustomNavigation loadUIViewController:self title:@"更改启动密码" navigationBarBgColor:BLACKCOLOR backSelector:@selector(back)];
    self.view.backgroundColor = BLACKCOLOR;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"c"];
    _falseNum = 5;
    _checkSuccess = NO;
    [self createUI];
    [self creataBackView];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ****** 创建密码错误遮罩层
-(void)creataBackView
{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, -HEIGHT, WIDTH, HEIGHT-35)];
    _backView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
    [self.view addSubview:_backView];
    
    _countDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT*0.3, WIDTH, 44)];
    _countDownLabel.textColor = [UIColor redColor];
    _countDownLabel.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:_countDownLabel];
}
#pragma mark ****** 创建九宫格密码
-(void)createUI
{

    CGFloat buttom = HEIGHT * 0.7166 + 16 - WIDTH;
    
    _checkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _checkView.backgroundColor = [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1];
    
    
    _checkLockView = [[KKGestureLockView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    _checkLockView.normalGestureNodeImage = [UIImage imageNamed:@"moren"];
    _checkLockView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
    _checkLockView.lineColor = [UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:0.8];
    _checkLockView.lineWidth = _isShowLine?5:0;
    _checkLockView.delegate = self;
    _checkLockView.contentInsets = UIEdgeInsetsMake(HEIGHT * 0.2833,40,buttom,40);
    
    [self createCheckLockViewUI];
    
    _changeLockView = [[KKGestureLockView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    _changeLockView.normalGestureNodeImage = [UIImage imageNamed:@"moren"];
    _changeLockView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
    _changeLockView.lineColor = [UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:0.8];
    _changeLockView.lineWidth = 5;
    _changeLockView.delegate = self;
    _changeLockView.contentInsets = UIEdgeInsetsMake(HEIGHT * 0.2833,40,buttom,40);
    [self createChangeLockView];
    
    [self.view addSubview:_changeLockView];
    [_checkView addSubview:_checkLockView];
    [self.view addSubview:_checkView];
}

#pragma mark ****** checkLockView上的界面
-(void)createCheckLockViewUI
{
    
    _logeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-45, 10, 90, 90)];
    _logeImageView.image = [UIImage imageNamed:@"logo"];
    [_checkLockView addSubview:_logeImageView];
    _promptCheckLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_logeImageView.frame), WIDTH, 40)];
    _promptCheckLabel.textAlignment = NSTextAlignmentCenter;
    _promptCheckLabel.textColor = [UIColor whiteColor];
    _promptCheckLabel.text = @"请绘制原启动密码";
    _promptCheckLabel.font = [UIFont systemFontOfSize:14.0f];
    [_checkLockView addSubview:_promptCheckLabel];
    
    UIButton* passButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [passButton setTitle:@"验证密码登陆" forState:UIControlStateNormal];
    passButton.frame = CGRectMake(0, HEIGHT-104, WIDTH, 35);
    passButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [passButton addTarget:self action:@selector(checkLoginPassword) forControlEvents:UIControlEventTouchUpInside];
    [_checkLockView addSubview:passButton];
    
    
}
#pragma mark ****** 下个更改的密码的界面
-(void)createChangeLockView
{
    //滑动描点图片
    _huadongImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-40, 20, 80, 80)];
    _huadongImageView.image = [UIImage imageNamed:@"huadong"];
    _huadongImageView.layer.cornerRadius = 5.0;
    _huadongImageView.layer.masksToBounds = YES;
    [_changeLockView addSubview:_huadongImageView];
    //创建9个高亮点
    for (int i = 0; i<3; i++) {
        for (int j = 0; j<3; j++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_HL"]];
            imageView.frame = CGRectMake(3.3+i*25, 3+25*j, 25, 25);
            imageView.alpha = 0.0;
            imageView.tag = i+j*3;
            [_huadongImageView addSubview:imageView];
        }
    }
    _promptchangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_huadongImageView.frame), WIDTH, 40)];
    _promptchangeLabel.textAlignment = NSTextAlignmentCenter;
    _promptchangeLabel.text = @"请绘制启动密码";
    _promptchangeLabel.font = [UIFont systemFontOfSize:14.0f];
    _promptchangeLabel.textColor = [UIColor whiteColor];
    [_changeLockView addSubview:_promptchangeLabel];
}

#pragma mark ****** 花九宫格的代理方法
-(void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)Endpasscode
{
    if (_checkSuccess==NO) {
        [self changeCode:Endpasscode];
    }else{
        [self createCode:Endpasscode];
    }
    
}
#pragma mark ****** 验证登陆密码
-(void)changeCode:(NSString*)sender
{
    _falseNum--;
    NSString* codeNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    if ([codeNum isEqualToString:sender]) {
        _logeImageView.image = [UIImage imageNamed:@"logo_green"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                CGRect rect = _checkView.frame;
                rect.origin.x = -WIDTH;
                _checkView.frame = rect;
            } completion:^(BOOL finished) {
                [_checkView removeFromSuperview];
            }];
        });

        _checkSuccess = YES;
        
    }else
    {
        for (UIButton *button in _checkLockView.selectedButtons) {
            button.imageView.image = [UIImage imageNamed:@"red"];
        }
        _logeImageView.image = [UIImage imageNamed:@"logo_red"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _logeImageView.image = [UIImage imageNamed:@"logo"];
            for (UIButton *button in _checkLockView.selectedButtons) {
                button.selected = NO;
            }
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
        _promptCheckLabel.text = [NSString stringWithFormat:@"愿密码输入错误，还有%d次机会",_falseNum];
        _promptCheckLabel.textColor = [UIColor redColor];
    }
}
-(void)createCode:(NSString*)sender
{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString* code  = [user objectForKey:@"c"];
    if (sender.length<5) {
        _promptchangeLabel.text = @"最少连接3个点，请重新绘制";
        _promptchangeLabel.textColor = [UIColor redColor];
    }else if (sender.length>=5){
        
        if (code==nil) {
            code = [NSString stringWithString:sender];
            NSArray *codeArray = [code componentsSeparatedByString:@","];
            for (UIImageView *imageView in _huadongImageView.subviews) {
                for (int j = 0; j<codeArray.count; j++) {
                    if (imageView.tag==[codeArray[j] integerValue]) {
                        imageView.alpha = 1.0;
                    }
                }
            }
            _promptchangeLabel.text = @"请再次绘制启动密码";
            _promptchangeLabel.textColor = [UIColor grayColor];
            [user setObject:code forKey:@"c"];
            [user synchronize];
            
        }else{
            if ([[user objectForKey:@"c"]  isEqualToString:sender]) {
                for (UIViewController* controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[GesturePasswordViewController class]]) {
                        controller.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1];
                        NSDictionary *dict = @{@"operationType":@"modify"};
                        //创建通知
                        NSNotification *notification =[NSNotification notificationWithName:@"showTopView" object:nil userInfo:dict];
                        //通过通知中心发送通知
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
                [user setObject:code forKey:@"code"];
            }else
            {
                _promptchangeLabel.textColor = [UIColor redColor];
                _promptchangeLabel.text = @"与上次输入不一致，请重新绘制";
            }
        }
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
        _promptCheckLabel.textColor = [UIColor whiteColor];
        _promptCheckLabel.text = @"请绘制启动密码";
    }
    _countDownLabel.text = [NSString stringWithFormat:@"倒计时：%d秒后请重新绘制",_seconds];
}

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