//
//  GesturePasswordViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "GesturePasswordViewController.h"

#import "CustomNavigation.h"
#import "CreateGestureViewController.h"
#import "EditGesturePasswordViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define Height self.view.bounds.size.height
#define Width self.view.bounds.size.width
@interface GesturePasswordViewController ()<PopViewControllerDelegate>

@end

@implementation GesturePasswordViewController
{
    BOOL isOpen;//是否开启手势密码
    BOOL isFingerPrint;//是否开启指纹密码
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //------ 视图背景色 ------
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [CustomNavigation loadUIViewController:self title:@"启动密码" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStatus) name:@"changeStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change) name:@"change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTopView:) name:@"showTopView" object:nil];
    [self createUI];
}
#pragma mark ****** 改变为已开启
-(void)change
{
    _isOpenLabel.text=@"未开启";
    _isOpenLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
}
#pragma mark ****** 改变为未开启
-(void)changeStatus
{
    _isOpenLabel.text=@"已开启";
    _isOpenLabel.textColor=[UIColor colorWithRed:18/255.0 green:110/255.0 blue:214/255.0 alpha:1.0];
}
#pragma mark ****** 更改或删除成功后弹出成功提示
- (void)showTopView:(NSNotification *)text{
    NSString *operationType = text.userInfo[@"operationType"];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, 30)];
    topView.backgroundColor = [UIColor colorWithRed:1.0 green:240/255.0 blue:185/255.0 alpha:1.0];
    UITextField *txt = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, [operationType isEqualToString:@"create"]?265:145, 30)];
    [txt setCenter:topView.center];
    txt.borderStyle = UITextBorderStyleNone;
    txt.font = [UIFont systemFontOfSize:15.0];
    txt.enabled = NO;
    txt.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chenggong_HL"]];
    txt.leftViewMode = UITextFieldViewModeAlways;
    if ([operationType isEqualToString:@"create"]) {
        txt.text = @" 设置成功，退出后一分钟内不用验证";
    }else if ([operationType isEqualToString:@"modify"]){
        txt.text = @" 启动密码更改成功";
    }else {
        txt.text = @" 启动密码删除成功";
    }
    [topView addSubview:txt];
    [self.view addSubview:topView];
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
        CGRect rect = topView.frame;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        rect.origin.y = 64;
        topView.frame = rect;
    } completion:^(BOOL finished) {
        [topView removeFromSuperview];
    }];
}

-(void)createUI
{    
    self.view.backgroundColor=[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    //------ 上部文字 ------
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(Width*0.03, Height*0.0396+44, self.view.bounds.size.width-Width*0.03*2, Height*0.14)];
    label1.text=@"开启启动密码，他人使用您的手机时将无法打开爱操盘手机实盘交易软件，保护您的帐户安全！";
    label1.numberOfLines=0;
    label1.textAlignment=NSTextAlignmentLeft;
    label1.font=[UIFont systemFontOfSize:13.0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:label1.text];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:8];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, label1.text.length)];
    label1.attributedText = attributedString;
    label1.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:label1];
    
    for (NSInteger i=0; i<2; i++) {
        UILabel *lineLabels=[[UILabel alloc]initWithFrame:CGRectMake(0, Height*(0.1796-0.035)+44+i*Height*0.088+Height*0.026, self.view.bounds.size.width, 0.4)];
        lineLabels.backgroundColor=[UIColor grayColor];
        [self.view addSubview:lineLabels];
        
    }
    //------ 手势按钮视图 ------
    UIView *Gestureview=[[UIView alloc]initWithFrame:CGRectMake(0, Height*(0.1796-0.035)+44+Height*0.026+0.4, self.view.bounds.size.width, Height*0.088-0.8)];
    Gestureview.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:Gestureview];
    
    UIImageView *GestureImageView=[[UIImageView alloc]initWithFrame:CGRectMake(Width*0.03, Height*0.028, Width*0.05, Height*0.032)];
    GestureImageView.image=[UIImage imageNamed:@"shouzhi"];
    [Gestureview addSubview:GestureImageView];
    
    UIButton *GestureButton=[UIButton buttonWithType:UIButtonTypeCustom];
    GestureButton.frame=CGRectMake(Width*0.13, 0, self.view.bounds.size.width-Width*0.13, Height*0.088);
    [GestureButton setTitle:@"手势启动密码" forState:UIControlStateNormal];
    GestureButton.titleLabel.font=[UIFont systemFontOfSize:12.0];
    [GestureButton setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] forState:UIControlStateNormal];
    GestureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [GestureButton addTarget:self action:@selector(enterToCreateGesture) forControlEvents:UIControlEventTouchUpInside];
    [Gestureview addSubview:GestureButton];
    
    UIImageView *rightGestureImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-Width*0.06, Height*0.03, Width*0.03, Height*0.026)];
    rightGestureImageView.image=[UIImage imageNamed:@"gengduo"];
    [Gestureview addSubview:rightGestureImageView];
    
    _isOpenLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-Width*0.278, Height*0.018, Width*0.188, Height*0.053)];
    NSString* str = [[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    if (str==nil) {
        _isOpenLabel.text=@"未开启";
        _isOpenLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }else{
        _isOpenLabel.text=@"已开启";
    _isOpenLabel.textColor=[UIColor colorWithRed:18/255.0 green:110/255.0 blue:214/255.0 alpha:1.0];
    }
    _isOpenLabel.font=[UIFont systemFontOfSize:12.0];
    _isOpenLabel.textAlignment=NSTextAlignmentRight;
    [Gestureview addSubview:_isOpenLabel];
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 指纹密码
        UIView *fingerPrintGestureview=[[UIView alloc]initWithFrame:CGRectMake(0, Height*(0.1796-0.035)+44+Height*0.026+0.4+Height*0.088, self.view.bounds.size.width, Height*0.088-0.8)];
        fingerPrintGestureview.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:fingerPrintGestureview];
        
        UIImageView *fingerPrintGestureImageView=[[UIImageView alloc]initWithFrame:CGRectMake(Width*0.03, Height*0.028, Width*0.05, Height*0.032)];
        fingerPrintGestureImageView.image=[UIImage imageNamed:@"zhiwen"];
        [fingerPrintGestureview addSubview:fingerPrintGestureImageView];
        
        UILabel *fingerPrintLabel = [[UILabel alloc]initWithFrame:CGRectMake(Width*0.13, 0, self.view.bounds.size.width-Width*0.13, Height*0.088)];
        fingerPrintLabel.text = @"指纹启动密码";
        fingerPrintLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        fingerPrintLabel.font = [UIFont systemFontOfSize:12.0];
        [fingerPrintGestureview addSubview:fingerPrintLabel];
        
        
        UISwitch* fingerPrintswitch =[[ UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-Width*0.17, Height*0.018, Width*0.188, Height*0.053)];
        NSString *onstr = [[NSUserDefaults standardUserDefaults] objectForKey:@"FingerPrint"];
        if ([onstr isEqualToString:@"yesStr"]) {
            fingerPrintswitch.on = YES;
        }else{
            fingerPrintswitch.on = NO;
        }
        [fingerPrintswitch addTarget:self action:@selector(showLine:) forControlEvents:UIControlEventValueChanged];
        [fingerPrintGestureview addSubview:fingerPrintswitch];
        
        for (NSInteger i=0; i<3; i++) {
            UILabel *lineLabels=[[UILabel alloc]initWithFrame:CGRectMake(0, Height*(0.1796-0.035)+44+i*Height*0.088+Height*0.026, self.view.bounds.size.width, 0.4)];
            lineLabels.backgroundColor=[UIColor grayColor];
            [self.view addSubview:lineLabels];
            
        }
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(Height*0.015, Height*(0.1796-0.035)+44+Height*0.026+Height*0.088*2, self.view.bounds.size.width, Height*0.06)];
        label2.text=@"选择使用启动密码进入爱操盘手机实盘交易软件";
        label2.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        label2.font=[UIFont systemFontOfSize:11.0];
        [self.view addSubview:label2];
    }else{
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(Height*0.015, Height*(0.1796-0.035)+44+Height*0.026+Height*0.088, self.view.bounds.size.width, Height*0.06)];
        label2.text=@"选择使用启动密码进入爱操盘手机实盘交易软件";
        label2.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        label2.font=[UIFont systemFontOfSize:11.0];
        [self.view addSubview:label2];
    }
}
#pragma mark ****** 是否启动指纹验证
- (void)showLine:(UISwitch *)sender{
    if ([_isOpenLabel.text isEqualToString:@"已开启"]) {
        if (sender.on == YES) {
            NSUserDefaults *FingerPrint = [NSUserDefaults standardUserDefaults];
            [FingerPrint setObject:@"yesStr" forKey:@"FingerPrint"];
        }else{
            NSUserDefaults *FingerPrint = [NSUserDefaults standardUserDefaults];
            [FingerPrint setObject:@"noStr" forKey:@"FingerPrint"];
        }
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"该功能需先开启手势密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            sender.on = NO;
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
}
#pragma mark ****** 点击创建手势密码页面
-(void)enterToCreateGesture
{

    if ([_isOpenLabel.text isEqualToString:@"已开启"]) {
        EditGesturePasswordViewController *edit = [[EditGesturePasswordViewController alloc]init];
        edit.delegate = self;
        [self.navigationController pushViewController:edit animated:YES];
    }else{
        CreateGestureViewController *create = [[CreateGestureViewController alloc]init];
        create.delegate = self;
        [self.navigationController pushViewController:create animated:YES];
    }
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setPopViewControoler{
    self.navigationController.navigationBar.barTintColor = BLUECOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
