//
//  LoginViewController.m
//  LoginRegister
//
//  Created by Aaron Lee on 15-3-23.
//  Copyright (c) 2015年 Aaron Lee. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomNavigation.h"
#import "AFNetworking.h"
#import "MainViewController.h"
#import "RootViewController.h"
#import "WebRequest.h"
#import "GDataXMLNode.h"
#import "SingleSocket.h"

#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define HEIGHT self.view.bounds.size.height
#define WIDTH self.view.bounds.size.width

static NSString* const TASKGUID = @"b4026263-704e-4e12-a64d-f79cb42962cc";
@interface LoginViewController ()<UITextFieldDelegate>

@property (strong,nonatomic) UITextField *userNameTxt;//用户名文本框
@property (strong,nonatomic) UITextField *pwdTxt;//密码文本框
@property (strong,nonatomic) UIButton *loginBtn;//登录按钮
@property (strong,nonatomic) UIButton *rightBtn;//密码右侧眼睛按钮
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件

@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"登录" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
    [self loadUI];
}
- (void)back{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"socket" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)textFieldchange{
    _loginBtn.enabled = (_userNameTxt.text.length>5);
}

#pragma mark ****** 加载视图
- (void)loadUI{
    //------ 用户名文本框 ------
    _userNameTxt = [[UITextField alloc] initWithFrame:CGRectMake(20, 0.18*HEIGHT, WIDTH-40, 46)];
    _userNameTxt.layer.borderWidth = 1;
    _userNameTxt.layer.cornerRadius = 5.0;
    _userNameTxt.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _userNameTxt.layer.masksToBounds = YES;
    _userNameTxt.placeholder=@"请输入用户名";
    _userNameTxt.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_user"]];
    _userNameTxt.leftViewMode=UITextFieldViewModeAlways;
    _userNameTxt.tag=100;
    _userNameTxt.clearButtonMode = UITextFieldViewModeAlways;
    [_userNameTxt setDelegate:self];
    _userNameTxt.keyboardType=UIKeyboardTypeNumberPad;
    [_userNameTxt addTarget:self action:@selector(passwordChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_userNameTxt];
    
    //------ 密码文本框 ------
    _pwdTxt = [[UITextField alloc] initWithFrame:CGRectMake(20, 0.225*HEIGHT+50, WIDTH-40, 46)];
    _pwdTxt.layer.borderWidth = 1;
    _pwdTxt.layer.cornerRadius = 5.0;
    _pwdTxt.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _pwdTxt.layer.masksToBounds = YES;
    _pwdTxt.placeholder=@"请输入密码";
    _pwdTxt.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_pwd"]];
    _pwdTxt.leftViewMode=UITextFieldViewModeAlways;
    _pwdTxt.tag=101;
    
    [_pwdTxt setDelegate:self];
    _pwdTxt.keyboardType=UIKeyboardTypeDefault;
    _rightBtn=[[UIButton alloc]initWithFrame:CGRectMake(WIDTH-100, 50, 50, 50)];
    
    [_rightBtn setImage:[UIImage imageNamed:@"kejian"]  forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"kejian_HL"] forState:UIControlStateSelected];
    [_rightBtn setImage:[UIImage imageNamed:@"kejian_HL"] forState:UIControlStateHighlighted];
    [_rightBtn setImage:[UIImage imageNamed:@"kejian"] forState:UIControlStateDisabled];
    
    [_rightBtn addTarget:self action:@selector(showOldPwd:) forControlEvents:UIControlEventTouchUpInside];
    _pwdTxt.rightView=_rightBtn;
    _pwdTxt.rightViewMode=UITextFieldViewModeAlways;
    _pwdTxt.rightView.clearsContextBeforeDrawing=YES;
    _pwdTxt.clearButtonMode = UITextFieldViewModeAlways;
    _pwdTxt.secureTextEntry=YES;
    [_pwdTxt addTarget:self action:@selector(passwordChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_pwdTxt];
    
    //------ 登录按钮 ------
    _loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _loginBtn.frame = CGRectMake(20, 0.3*HEIGHT+100, WIDTH-40, 46);
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginBtn.tag = 200;//Todo:宏
    [_loginBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [_loginBtn.layer setMasksToBounds:YES];
    _loginBtn.backgroundColor=[UIColor lightGrayColor];
    _loginBtn.enabled=NO;
    [self.view addSubview:_loginBtn];
    [_loginBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //------ 刷新控件 ------
    //------ 指定进度轮中心点 ------
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //------ 指定进度轮中心点 ------
    [_activity setCenter:self.view.center];
    //------ 设置进度轮显示类型 ------
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_activity];
    
}

#pragma mark ****** 显示隐藏密码
-(void)showOldPwd:(UIButton *)sender{
    _rightBtn.selected = !_rightBtn.selected;
    _pwdTxt.secureTextEntry = !_rightBtn.selected;
}

#pragma mark ****** 登录判断
- (void)passwordChange{
//    if (_pwdTxt.text.length > 5) {
        _loginBtn.enabled=YES;
        _loginBtn.backgroundColor= BLUECOLOR;
        [_loginBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
//    }else{
//        _loginBtn.enabled=NO;
//        _loginBtn.backgroundColor=[UIColor lightGrayColor];
//    }
}
#pragma mark ****** 登录按钮点击事件
- (void)onButtonClick:(UIButton *)sender{
    NSString* str = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"DRIVERID"];
    [_activity startAnimating];
    NSString* PassWord = [NSString stringWithFormat:@"%@",_pwdTxt.text];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                    str,@"DriverID",
                                    @"任务标识",@"UserID",
                                    TASKGUID,@"TaskGuid",
                                    @"CheckUser",@"DataType",
                                    _userNameTxt.text,@"LoginID",
                                    PassWord,@"LoginPass",nil];
    WebRequest *webRequest = [[WebRequest alloc] init];
    [webRequest webRequestWithDataDic:dataDic requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
        if (error!=nil) {
            NSLog(@"错误提示:%@",error);
        }else{
            if ([resultString hasPrefix:@"{\"ID\":"]) {
                NSData *jsonData = [resultString dataUsingEncoding:NSUTF16StringEncoding];
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"login"];//------ 修改登录状态 ------
                [self dismissViewControllerAnimated:YES completion:^{
                    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
                    [userDic addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:str,@"DriverID",@"Account",@"DataType",@"ab8495db-3a4a-4f70-bb81-8518f60ec8bf",@"TaskGuid", nil]];
                    if ([@"" isEqualToString:userDic[@"NickName"]]) {
                        NSString *randomNum =[NSString stringWithFormat:@"%d",arc4random_uniform(1001)];//------ 产生一个随机昵称 ------
                        NSString *name = @"小e";
                        [userDic setObject:[name stringByAppendingString:randomNum] forKey:@"NickName"];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDic"];
                    NSInteger _balance = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"][@"DouBiWeiPan"] integerValue];
                    [[NSUserDefaults standardUserDefaults]setInteger:_balance forKey:@"yue"];//获取余额
                    MainViewController *mvc = [[MainViewController alloc] init];
                    mvc.viewControllers = @[[[RootViewController alloc]init]];
                    [UIApplication sharedApplication].keyWindow.rootViewController = mvc;
                }];
                [_activity stopAnimating];
            } else {
                UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"用户名或密码错误"  message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *canaleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
                [AlertController addAction:canaleAction];
                [self presentViewController:AlertController animated:YES completion:nil];
            }
        }
        [_activity stopAnimating];
    }];

    //检测手机运行的是什么网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // WiFi
     */
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status==AFNetworkReachabilityStatusNotReachable){
            UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"请求超时,请检查网络连接"   message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *canaleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
            [AlertController addAction:canaleAction];
            [self presentViewController:AlertController animated:YES completion:nil];
        }
    }];
}



#pragma mark - UITextField限制输入的字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;{
    if ([string isEqualToString:@"\n"]){
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (textField.tag) {
        case 100:
            if ([toBeString length] > 20) {
                return NO;
            }
            break;
        case 101:
            if ([toBeString length] > 20) {
                return NO;
            }
            break;
    }
    return YES;
}

#pragma mark ****** 获取第一响应者时调用
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[BLUECOLOR CGColor];
    textField.layer.borderWidth= 1.0f;
    [textField setLeftView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:(100 == textField.tag ? @"login_userHL" : @"login_pwdHL")]]];
    return YES;
}

#pragma mark ****** 失去第一响应者时调用
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    textField.layer.borderWidth= 1.0f;
    [textField setLeftView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:(100 == textField.tag ? @"login_user" : @"login_pwd")]]];
    return YES;
}

#pragma mark ****** 按return时调用
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark ****** 点击空白处隐藏键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_userNameTxt resignFirstResponder];
    [_pwdTxt resignFirstResponder];
}
#pragma mark 从operation获取解析后的XML字符串
- (NSString *)getResultStringFromOperation:(NSData *)responseObject{
    NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *array = [xmlEle children];
    NSString*resultString;
    for (int i = 0; i < [array count]; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        resultString = [ele stringValue];
    }
    return resultString;
}
@end