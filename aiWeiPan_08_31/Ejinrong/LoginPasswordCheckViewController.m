//
//  LoginPasswordCheckViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/17.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "LoginPasswordCheckViewController.h"
#import "CustomNavigation.h"
#import "CreateGesturePasswordViewController.h"
#import "ChangeGesturePasswordViewController.h"
#import "AFNetworking.h"
#import "WebRequest.h"
#import "GDataXMLNode.h"
#import "MainViewController.h"
#import "RootViewController.h"
#define TASKGUID @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
#define WIDTH CGRectGetWidth(self.view.frame)
#define HEIGHT CGRectGetHeight(self.view.frame)
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]

@interface LoginPasswordCheckViewController ()<UITextFieldDelegate,PopViewControllerDelegate,UINavigationBarDelegate>

@property (copy,nonatomic) NSString *nickName;//昵称
@property (copy,nonatomic) NSString *userName;//用户名
@property (strong,nonatomic) UITextField *passwordTextField;//密码文本框
@property (strong,nonatomic) UIButton *eyeButton;//显示密码按钮
@property (strong,nonatomic) UIButton *sureButton;//确定按钮
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件
@property (strong,nonatomic) NSMutableDictionary *dataDictionary;

@end

@implementation LoginPasswordCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //------ 返回按钮 ------
    if (_isError == NO) {
        self.navigationController.navigationBar.hidden = NO;
        [CustomNavigation loadUIViewController:self title:@"找回启动密码" navigationBarBgColor:[UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1] backSelector:@selector(back)];
    }else{
        self.navigationController.navigationBar.hidden = YES;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
        view.backgroundColor = [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 31, WIDTH, 22)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"找回启动密码";
        titleLabel.font = [UIFont systemFontOfSize:22.0];
        titleLabel.textColor = [UIColor whiteColor];
        [view addSubview:titleLabel];
        [self.view addSubview:view];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    //昵称和用户名
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"];
    NSString* name = userDic[@"LoginAccount"];
    NSRange range = NSMakeRange(2, name.length-3);
    _userName = [name stringByReplacingCharactersInRange:range withString:@"******"];
    _nickName = userDic[@"NickName"];
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, HEIGHT*0.0396+64, WIDTH, 15)];
    userLabel.font = [UIFont systemFontOfSize:13.0];
    userLabel.text = [NSString stringWithFormat:@"%@  (%@)",_nickName,_userName];
    userLabel.textColor = [UIColor grayColor];
    [self.view addSubview:userLabel];
    
    //密码框
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, HEIGHT*0.0792+64, WIDTH, 50)];
    _passwordTextField.borderStyle = UITextFieldViewModeAlways;
    _passwordTextField.placeholder=@"    请输入密码";
    _passwordTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    _eyeButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
    [_eyeButton setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_eyeButton setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [_eyeButton setImage:[[UIImage imageNamed:@"kejian_HL"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_eyeButton setImage:[[UIImage imageNamed:@"kejian"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateDisabled];
    [_eyeButton addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
    _passwordTextField.rightView=_eyeButton;
    _passwordTextField.rightViewMode=UITextFieldViewModeAlways;
    [_passwordTextField setDelegate:self];
    _passwordTextField.keyboardType=UIKeyboardTypeDefault;
    _passwordTextField.secureTextEntry=YES;
    [_passwordTextField addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_passwordTextField];
    
    //确定按钮
    _sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _sureButton.frame = CGRectMake(10, HEIGHT*0.2068+64, WIDTH-20, 43);
    [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
    _sureButton.layer.cornerRadius = 5.0;
    _sureButton.layer.masksToBounds = YES;
    [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sureButton.backgroundColor = [UIColor lightGrayColor];
    _sureButton.enabled = NO;
    [self.view addSubview:_sureButton];
    
    //------ 刷新控件 ------
    //------ 指定进度轮中心点 ------
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //------ 指定进度轮中心点 ------
    [_activity setCenter:self.view.center];
    //------ 设置进度轮显示类型 ------
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_activity];
}

-(void)showPassword:(UIButton *)sender{
    _eyeButton.selected = !_eyeButton.selected;
    _passwordTextField.secureTextEntry = !_eyeButton.selected;
}

#pragma mark ****** 提交判断
- (void)TextChange{
    if (_passwordTextField.text.length > 5 && _passwordTextField.text.length > 5) {
        _sureButton.enabled=YES;
        _sureButton.backgroundColor= BLUECOLOR;
        [_sureButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    }else{
        _sureButton.enabled=NO;
        _sureButton.backgroundColor=[UIColor lightGrayColor];
    }
}

#pragma mark ****** 登录按钮点击事件
- (void)onButtonClick:(UIButton *)sender{
    sender.enabled = NO;
    NSString* str = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"DRIVERID"];
    [_activity startAnimating];
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"];
    NSString* name = userDic[@"LoginAccount"];
    _dataDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:TASKGUID,@"TaskGuid",@"Query",@"DataType",name,@"LoginAccount",[NSString stringWithFormat:@"ZS%@ZS",_passwordTextField.text],@"Password",nil];//------ 拼接SOAP协议 ------
    WebRequest *webRequest = [[WebRequest alloc] init];
    [webRequest webRequestWithDataDic:_dataDictionary requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {
//            NSLog(@"错误提示:%@",error);
        }else{
            NSString *xmlString = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil];
            GDataXMLElement *xmlEle = [xmlDoc rootElement];
            NSArray *array = [xmlEle children];
            for (int i = 0; i < [array count]; i++) {
                GDataXMLElement *ele = [array objectAtIndex:i];
                if ([@"True" isEqualToString:[ele stringValue]]) {
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    [user setObject:nil forKey:@"code"];
                    CreateGesturePasswordViewController *ccv = [[CreateGesturePasswordViewController alloc] init];
                    ccv.is = YES;
                    ccv.delegate = self;
                    [self.navigationController pushViewController:ccv animated:YES];
                } else {
                    UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"用户名或密码错误"  message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *canaleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
                    [AlertController addAction:canaleAction];
                    [self presentViewController:AlertController animated:YES completion:nil];

                }
            }
        }
        [_activity stopAnimating];
        sender.enabled = YES;
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

- (void)setPopViewControoler{
    self.navigationController.navigationBar.barTintColor = BLUECOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back{
    [_delegate setPopViewControoler];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
