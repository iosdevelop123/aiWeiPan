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
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define Height self.view.bounds.size.height
#define Width self.view.bounds.size.width
#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
@interface PasswordModifyViewController ()<UITextFieldDelegate,NSXMLParserDelegate>

@property (strong,nonatomic) UITextField *oldPwdTxt;//旧密码文本框
@property (strong,nonatomic) UITextField *newpwdTxt;//新密码文本框
@property (strong,nonatomic) UIButton *submitBtn;//提交按钮
@property (strong,nonatomic) UIButton *oldrightBtn;//旧密码右侧眼睛按钮
@property (strong,nonatomic) UIButton *newrightBtn;//新密码右侧眼睛按钮
@property (strong,nonatomic) UILabel *topLabel;//上面label
@property (strong,nonatomic) UILabel *midLabel;//中间label
@property (strong,nonatomic) UILabel *upLabel;//下面label
@end

@implementation PasswordModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"密码修改" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
    [self loadUI];
}

-(void)loadUI{
    //------ 上面label ------
    _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, Width, 1)];
    _topLabel.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:_topLabel];
    //------ 中间label ------
    _midLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, Width, 1)];
    _midLabel.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:_midLabel];
    //------ 下面label ------
    _upLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 180, Width, 1)];
    _upLabel.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:_upLabel];
    
    //------ 旧密码文本框 ------
    _oldPwdTxt = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, Width, 50)];
    _oldPwdTxt.borderStyle = UITextFieldViewModeAlways;
    _oldPwdTxt.placeholder=@"    输入新密码";
    _oldPwdTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _oldrightBtn=[[UIButton alloc]initWithFrame:CGRectMake(Width-100, 50, 50, 50)];
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
    [_oldPwdTxt addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_oldPwdTxt];
    
    //------ 新密码文本框 ------
    _newpwdTxt = [[UITextField alloc] initWithFrame:CGRectMake(0, 130, Width, 50)];
    _newpwdTxt.borderStyle = UITextFieldViewModeAlways;
    _newpwdTxt.placeholder=@"    再次输入新密码";
    _newpwdTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _newrightBtn=[[UIButton alloc]initWithFrame:CGRectMake(Width-100, 50, 50, 50)];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian_HL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_newrightBtn setImage:[[UIImage imageNamed:@"kejian"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateDisabled];
    
    [_newrightBtn addTarget:self action:@selector(showNewPwd:) forControlEvents:UIControlEventTouchUpInside];
    _newpwdTxt.rightView=_newrightBtn;
    _newpwdTxt.rightViewMode=UITextFieldViewModeAlways;
    _newpwdTxt.tag=101;
    [_newpwdTxt setDelegate:self];
    _newpwdTxt.keyboardType=UIKeyboardTypeDefault;
    _newpwdTxt.secureTextEntry=YES;
    [_newpwdTxt addTarget:self action:@selector(TextChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_newpwdTxt];
    
    //------ 提示label ------
    UILabel *reminderLabel=[[UILabel alloc]initWithFrame:CGRectMake(28, 200, Width-60, 30)];
    [reminderLabel setText:@"6-20位数字,字母组合(特殊字符除外)"];
    reminderLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    reminderLabel.textColor=[UIColor lightGrayColor];
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:reminderLabel];
    
    //------ 提交按钮 ------
    _submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitBtn.frame = CGRectMake(20, 240, Width-40, 46);
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
#pragma mark ****** 提交判断
- (void)TextChange{
    if (_oldPwdTxt.text.length > 5 && _newpwdTxt.text.length > 5) {
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
    if ([_oldPwdTxt.text isEqualToString:_newpwdTxt.text]) {
        NSMutableDictionary *userDic =[[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"]];
        [userDic setObject:[NSString stringWithFormat:@"ZS%@ZS",_newpwdTxt.text] forKey:@"PassWord"];
        WebRequest *web = [[WebRequest alloc] init];
        [web webRequestWithDataDic:userDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error!=nil) {
                NSLog(@"修改密码请求失败");
                NSLog(@"错误提示:%@",error);
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDic"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"修改成功，请重新登录" message:nil delegate:self cancelButtonTitle:@"登录" otherButtonTitles:nil];
                alert.tag = 50;
                [alert show];
                UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"修改成功，请重新登录"  message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    LoginNavigationController *vc = [[LoginNavigationController alloc] init];
                    [self presentViewController:vc animated:YES completion:nil];
                }];
                [AlertController addAction:okAction];
                [self presentViewController:AlertController animated:YES completion:nil];
            }
        }];
    }else {
        UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"两次输入必须一致"  message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *canaleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
        [AlertController addAction:canaleAction];
        [self presentViewController:AlertController animated:YES completion:nil];
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
    [_oldPwdTxt resignFirstResponder];
    [_newpwdTxt resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end