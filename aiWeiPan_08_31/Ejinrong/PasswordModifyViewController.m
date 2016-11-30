//
//  PasswordModifyViewController.m
//  Demo_修改密码
//
//  Created by Aaron Lee on 15/10/9.
//  Copyright © 2015年 Aaron Lee. All rights reserved.
//

#import "PasswordModifyViewController.h"
#import "CustomNavigation.h"
#import "AFNetworking.h"
#import "LoginNavigationController.h"
#import "WebRequest.h"
#import "GDataXMLNode.h"
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define Width self.view.bounds.size.width
#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
@interface PasswordModifyViewController ()<UITextFieldDelegate,NSXMLParserDelegate>

@property (strong,nonatomic) UITextField *oldPwdTxt;//旧密码文本框
@property (strong,nonatomic) UITextField *newpwdTxt;//新密码文本框
@property (strong,nonatomic) UITextField* oncePedTxt;//再次输入密码
@property (strong,nonatomic) UIButton *submitBtn;//提交按钮
@property (strong,nonatomic) UIButton *oldrightBtn;//旧密码右侧眼睛按钮
@property (strong,nonatomic) UIButton *newrightBtn;//新密码右侧眼睛按钮
@property (strong,nonatomic) UIButton *oncerightBtn;//再次密码右侧眼睛按钮
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件
@end

@implementation PasswordModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"密码修改" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
    [self loadUI];
}

-(void)loadUI{
    //------ 指定进度轮中心点 ------
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //------ 指定进度轮中心点 ------
    [_activity setCenter:self.view.center];
    //------ 设置进度轮显示类型 ------
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_activity];
    
    //------ 输入新密码文本框 ------
    _oldPwdTxt = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, Width - 20, 50)];
    _oldPwdTxt.borderStyle = UITextFieldViewModeAlways;
    _oldPwdTxt.placeholder=@"输入旧密码";
    _oldPwdTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _oldrightBtn=[[UIButton alloc]initWithFrame:CGRectMake(Width - 100, 50, 50, 50)];
    [_oldrightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_oldrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [_oldrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_oldrightBtn setImage:[[UIImage imageNamed:@"kejian"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateDisabled];
    [_oldrightBtn addTarget:self action:@selector(showOldPwd:) forControlEvents:UIControlEventTouchUpInside];
    _oldPwdTxt.rightView=_oldrightBtn;
    _oldPwdTxt.rightViewMode=UITextFieldViewModeAlways;
    _oldPwdTxt.tag=100;
    [_oldPwdTxt setDelegate:self];
    _oldPwdTxt.keyboardType=UIKeyboardTypeDefault;
    _oldPwdTxt.secureTextEntry=YES;
//    [_oldPwdTxt addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_oldPwdTxt];
    
    //------ 输入新密码文本框 ------
    _newpwdTxt = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_oldPwdTxt.frame)+ 10, Width - 20, 50)];
    _newpwdTxt.borderStyle = UITextFieldViewModeAlways;
    _newpwdTxt.placeholder=@"输入新密码";
    _newpwdTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _newrightBtn=[[UIButton alloc]initWithFrame:CGRectMake(Width-100, 50, 50, 50)];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateDisabled];
    [_newrightBtn addTarget:self action:@selector(showNewPwd:) forControlEvents:UIControlEventTouchUpInside];
    _newpwdTxt.rightView=_newrightBtn;
    _newpwdTxt.rightViewMode=UITextFieldViewModeAlways;
    _newpwdTxt.tag=100;
    [_newpwdTxt setDelegate:self];
    _newpwdTxt.keyboardType=UIKeyboardTypeDefault;
    _newpwdTxt.secureTextEntry=YES;
    [_newpwdTxt addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_newpwdTxt];
    
    //------ 新密码文本框 ------
    _oncePedTxt = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_newpwdTxt.frame), Width - 20, 50)];
    _oncePedTxt.borderStyle = UITextFieldViewModeAlways;
    _oncePedTxt.placeholder=@"再次输入新密码";
    _oncePedTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _oncerightBtn=[[UIButton alloc]initWithFrame:CGRectMake(Width-100, 50, 50, 50)];
    [_oncerightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_oncerightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [_oncerightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_oncerightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateDisabled];
    
    [_oncerightBtn addTarget:self action:@selector(showOncePwd:) forControlEvents:UIControlEventTouchUpInside];
    _oncePedTxt.rightView=_oncerightBtn;
    _oncePedTxt.rightViewMode=UITextFieldViewModeAlways;
    _oncePedTxt.tag=101;
    [_oncePedTxt setDelegate:self];
    _oncePedTxt.keyboardType=UIKeyboardTypeDefault;
    _oncePedTxt.secureTextEntry=YES;
    [_oncePedTxt addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_oncePedTxt];
    
    //------ 提示label ------
    UILabel *reminderLabel=[[UILabel alloc]initWithFrame:CGRectMake(28, CGRectGetMaxY(_oncePedTxt.frame) + 20, Width-60, 30)];
    [reminderLabel setText:@"6-20位数字,字母组合(特殊字符除外)"];
    reminderLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    reminderLabel.textColor=[UIColor lightGrayColor];
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:reminderLabel];
    
    //------ 提交按钮 ------
    _submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitBtn.frame = CGRectMake(20, CGRectGetMaxY(reminderLabel.frame) + 10, Width-40, 46);
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitBtn.tag = 200;//Todo:宏
    [_submitBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [_submitBtn.layer setMasksToBounds:YES];
    _submitBtn.backgroundColor=[UIColor lightGrayColor];
    _submitBtn.enabled=NO;
    [self.view addSubview:_submitBtn];
    [_submitBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark ****** 显示或隐藏旧密码
-(void)showOldPwd:(UIButton *)sender{
    _oldrightBtn.selected = !_oldrightBtn.selected;
    _oldPwdTxt.secureTextEntry = !_oldrightBtn.selected;
}
#pragma mark ****** 显示或隐藏新密码
-(void)showNewPwd:(UIButton *)sender{
    _newrightBtn.selected = !_newrightBtn.selected;
    _newpwdTxt.secureTextEntry = !_newrightBtn.selected;
}
#pragma mark ****** 显示或隐藏再次新密码
-(void)showOncePwd:(UIButton *)sender{
    _oncerightBtn.selected = !_oncerightBtn.selected;
    _oncePedTxt.secureTextEntry = !_oncerightBtn.selected;
}
#pragma mark ****** 提交判断
- (void)TextChange{
    if (_newpwdTxt.text.length >= 3 && _oncePedTxt.text.length >= 3) {
        _submitBtn.enabled=YES;
        _submitBtn.backgroundColor= BLUECOLOR;
        [_submitBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    }else{
        _submitBtn.enabled=NO;
        _submitBtn.backgroundColor=[UIColor lightGrayColor];
    }
}
#pragma mark ****** 提交按钮点击事件
- (void)onButtonClick:(UIButton *)sender{
    if ([_newpwdTxt.text isEqualToString:_oncePedTxt.text]) {
        [_activity startAnimating];
        NSMutableDictionary *userDic =[[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"]];
        [userDic setObject:[NSString stringWithFormat:@"%@",_oncePedTxt.text] forKey:@"PassWord"];
        NSString* LoginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"][@"LoginID"];
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1234567890",@"DriverID",@"ChangePassWord",@"DataType",@"ab8495db-3a4a-4f70-bb81-8518f60ec8bf",@"TaskGuid",@"",@"UserID",LoginID,@"LoginID",_oldPwdTxt.text,@"PassWord",_newpwdTxt.text,@"NewPassWord", nil];
        WebRequest *web = [[WebRequest alloc] init];
        [web webRequestWithDataDic:parameters requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSString* resultString = [self getResultStringFromOperation:responseObject];
            if (![resultString isEqualToString:@"账号密码修改成功"]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:resultString preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDic"];
                [_activity stopAnimating];
                UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"密码修改成功"  message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [AlertController addAction:okAction];
                [self presentViewController:AlertController animated:YES completion:nil];
            }
        }];
    }else {
        [_activity  stopAnimating];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"两次输入必须一致" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
    textField.layer.borderColor=[BLUECOLOR CGColor];
    textField.layer.borderWidth= 1.0f;
    return YES;
}

#pragma mark ****** 失去第一响应者时调用
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    textField.layer.borderColor=[[UIColor clearColor] CGColor];
    textField.layer.borderWidth= 1.0f;
    return YES;
}

#pragma mark ****** 按return时调用
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark ****** 点击空白处隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
