//
//  CreateGesturePasswordViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "CreateGesturePasswordViewController.h"
#import "CustomNavigation.h"
#import "GesturePasswordViewController.h"
#import "MainViewController.h"
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface CreateGesturePasswordViewController ()
{
    UILabel* _promptLabel;
    UIImageView *_huadongImageView;
}
@end

@implementation CreateGesturePasswordViewController
{
    BOOL isOpen;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CustomNavigation loadUIViewController:self title:@"创建启动密码" navigationBarBgColor:[UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0] backSelector:@selector(back)];
    self.view.backgroundColor=[UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0];
    [self createUI];
    [self createPromptLabel];
}
-(void)back{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    [user setObject:nil forKey:@"code"];
    [_delegate setPopViewControoler];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)createUI
{
    
    _lockView = [[KKGestureLockView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    _lockView.normalGestureNodeImage = [UIImage imageNamed:@"moren"];
    _lockView.selectedGestureNodeImage = [UIImage imageNamed:@"blue"];
    _lockView.lineColor = [[UIColor colorWithRed:31/255.0 green:183/255.0 blue:245/255.0 alpha:1.0] colorWithAlphaComponent:1.0];
    _lockView.lineWidth = 5;
    _lockView.delegate = self;
    CGFloat buttom = HEIGHT * 0.7166 + 16 - WIDTH;
    _lockView.contentInsets = UIEdgeInsetsMake(HEIGHT * 0.2833,40,buttom,40);
    [self.view addSubview:_lockView];
    _huadongImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-40, 20, 80, 80)];
    _huadongImageView.image = [UIImage imageNamed:@"huadong"];
    _huadongImageView.layer.cornerRadius=5;
    _huadongImageView.layer.masksToBounds=true;
    [_lockView addSubview:_huadongImageView];
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
    
}
-(void)createPromptLabel
{
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2-100, HEIGHT*0.2833-HEIGHT*0.088, 200, 44)];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.font = [UIFont systemFontOfSize:14.0f];
    _promptLabel.text = @"请绘制启动密码";
    _promptLabel.textColor = [UIColor grayColor];
    [_lockView addSubview:_promptLabel];
}
#pragma mark ****** 绘制手势密码结束
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)Endpasscode
{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    
    NSString* code = [[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    if (Endpasscode.length<5) {
        _promptLabel.text = @"最少连接3个点，请重新绘制";
        _promptLabel.textColor = [UIColor redColor];
    }else if (Endpasscode.length>=5){
        
        if (code==nil) {
            code = [NSString stringWithString:Endpasscode];
            NSArray *codeArray = [code componentsSeparatedByString:@","];
            for (UIImageView *imageView in _huadongImageView.subviews) {
                for (int j = 0; j<codeArray.count; j++) {
                    if (imageView.tag==[codeArray[j] integerValue]) {
                        imageView.alpha = 1.0;
                    }
                }
            }
            _promptLabel.text = @"请再次绘制启动密码";
            _promptLabel.textColor = [UIColor grayColor];
            [user setObject:code forKey:@"code"];
            
        }else{
            if ([code isEqualToString:Endpasscode]) {
                NSUserDefaults *isError = [NSUserDefaults standardUserDefaults];
                NSString *isErrorString = [NSString stringWithFormat:@"%d",5];
                [isError setObject:isErrorString forKey:@"_codeFalseNum"];
                
                if (_is==YES) {
                    MainViewController *mvc = [[MainViewController alloc] init];
                    [self presentViewController:mvc animated:YES completion:nil];
                }else{
                    GesturePasswordViewController* vc = [[GesturePasswordViewController alloc]init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            controller.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1];
                            Endpasscode=nil;
                            NSDictionary *dict = @{@"operationType":@"create"};
                            //创建通知
                            NSNotification *notification =[NSNotification notificationWithName:@"showTopView" object:nil userInfo:dict];
                            //通过通知中心发送通知
                            [[NSNotificationCenter defaultCenter] postNotification:notification];
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                    
                    [user setObject:code forKey:@"code"];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeStatus" object:nil];
                }
            }else{
                _promptLabel.textColor = [UIColor redColor];
                _promptLabel.text = @"与上次输入不一致，请重新绘制";
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end