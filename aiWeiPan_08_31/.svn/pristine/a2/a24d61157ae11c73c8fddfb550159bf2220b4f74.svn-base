//
//  CertificateCheckViewController.m
//  Ejinrong
//
//  Created by Aaron Lee on 15/10/21.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "CertificateCheckViewController.h"
#import "CustomNavigation.h"
#import "AFNetworking.h"
#import "WebRequest.h"
#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define Height self.view.bounds.size.height
#define Width self.view.bounds.size.width
@interface CertificateCheckViewController ()<UITextFieldDelegate>

@property (strong,nonatomic) UITextField *nameTxt;//姓名文本框
@property (strong,nonatomic) UITextField *CertificateTxt;//身份证号文本框
@property (strong,nonatomic) UIButton *submitBtn;//提交按钮
@property (strong,nonatomic) UILabel *topLabel;//上面label
@property (strong,nonatomic) UILabel *midLabel;//中间label
@property (strong,nonatomic) UILabel *upLabel;//下面label
@property (strong,nonatomic) NSMutableDictionary *userDic;//用户字典
@end

@implementation CertificateCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"实名认证" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
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
    
    //------ 姓名文本框 ------
    _nameTxt = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, Width, 50)];
    _nameTxt.borderStyle = UITextFieldViewModeAlways;
    _nameTxt.placeholder=@"    请输入您的姓名";
    _nameTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _nameTxt.rightViewMode=UITextFieldViewModeAlways;
    _nameTxt.tag=100;
    [_nameTxt setDelegate:self];
    _nameTxt.clearButtonMode = UITextFieldViewModeAlways;
    _nameTxt.keyboardType=UIKeyboardTypeDefault;
    [_nameTxt addTarget:self action:@selector(TxtChange) forControlEvents:UIControlEventEditingChanged];//监听TextField的实时变化
    [self.view addSubview:_nameTxt];
    
    //------ 身份证号文本框 ------
    _CertificateTxt = [[UITextField alloc] initWithFrame:CGRectMake(0, 130, Width, 50)];
    _CertificateTxt.borderStyle = UITextFieldViewModeAlways;
    _CertificateTxt.placeholder=@"    请输入您的身份证号";
    _CertificateTxt.layer.borderColor = [[UIColor clearColor]CGColor];
    _CertificateTxt.rightViewMode=UITextFieldViewModeAlways;
    _CertificateTxt.tag=101;
    [_CertificateTxt setDelegate:self];
    _CertificateTxt.clearButtonMode = UITextFieldViewModeAlways;
    _CertificateTxt.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    [_CertificateTxt addTarget:self action:@selector(TxtChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_CertificateTxt];
    
    //------ 提示label ------
    UILabel *reminderLabel=[[UILabel alloc]initWithFrame:CGRectMake(28, 200, Width-60, 30)];
    [reminderLabel setText:@"一张身份证只能绑定一个账号\n请认真填写本人真实信息,以免影响提现 "];
    reminderLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    reminderLabel.textColor=[UIColor redColor];
    reminderLabel.numberOfLines = 0;
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:reminderLabel];
    
    //------ 提交按钮 ------
    _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, Width-40, 46)];
    [_submitBtn setTitle:@"提交认证" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitBtn.tag = 200;//Todo:宏
    [_submitBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [_submitBtn.layer setMasksToBounds:YES];
    _submitBtn.backgroundColor=[UIColor lightGrayColor];
    _submitBtn.enabled=NO;
    [self.view addSubview:_submitBtn];
    [_submitBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark ****** 提交判断
- (void)TxtChange{
    if (_nameTxt.text.length > 0 && _CertificateTxt.text.length == 18) {
        _submitBtn.enabled=YES;
        _submitBtn.backgroundColor= BLUECOLOR;
        [_submitBtn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    }else{
        _submitBtn.enabled=NO;
        _submitBtn.backgroundColor=[UIColor lightGrayColor];
    }
}

-(void)onButtonClick:(UIButton *)sender{
    _userDic =[[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"]];
    [_userDic setObject:_nameTxt.text forKey:@"Name"];
    [_userDic setObject:_CertificateTxt.text forKey:@"CarID"];
    WebRequest *webRequest = [[WebRequest alloc] init];
    [webRequest webRequestWithDataDic:_userDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {
            NSLog(@"证件号验证请求失败");
            NSLog(@"错误提示:%@",error);
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:_userDic forKey:@"userDic"];
            [_delegate showCertificate:_CertificateTxt.text name:_nameTxt.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField限制输入的字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"\n"]){
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (textField.tag) {
        case 100:
            if ([toBeString length] > 12) {
                return NO;
            }
            break;
        case 101:
            if ([toBeString length] > 18) {
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_nameTxt resignFirstResponder];
    [_CertificateTxt resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end