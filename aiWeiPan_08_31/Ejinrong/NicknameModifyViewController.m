//
//  NicknameModifyViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "NicknameModifyViewController.h"
#import "PasswordModifyViewController.h"
#import "CustomNavigation.h"
#import "UserDetailViewController.h"
#import "AFNetworking.h"
#import "WebRequest.h"
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
#define WIDTH self.view.bounds.size.width
#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
@interface NicknameModifyViewController ()<UITextFieldDelegate,NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableDictionary *userDic;
@end

@implementation NicknameModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"昵称修改" navigationBarBgColor:BLUECOLOR backSelector:@selector(back)];
    [self createUI];
}

- (void)createUI{
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 54)];
    [_textField setPlaceholder:@"    请输入新的昵称"];
    
    _textField.layer.borderWidth = 1;
    _textField.layer.borderColor = [UIColor lightGrayColor].CGColor ;
    [self.view addSubview:_textField];
    
    UILabel * prompt = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_textField.frame), WIDTH, 30)];
    prompt.text = @"限4-16个字符，一个汉字2个字符";
    prompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:prompt];
    prompt.font = [UIFont systemFontOfSize:13.0f];
    prompt.textColor = [UIColor lightGrayColor];
    
    
    UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:@"保 存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(30, CGRectGetMaxY(prompt.frame)+20, WIDTH-60, 50);
    saveButton.layer.cornerRadius = 8;
    saveButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [saveButton setBackgroundColor:BLUECOLOR];
    [saveButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}
#pragma mark ****** 保存点击事件
- (void)saveButtonClick{
    if (_textField.text.length>=1) {
        if (_saveBlock) {
            NSString* str = _textField.text;
            _saveBlock(str);
            _userDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"]];
            [_userDic setObject:str forKey:@"NickName"];
            WebRequest *webRequest = [[WebRequest alloc] init];
            [webRequest webRequestWithDataDic:_userDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error!=nil) {
                    NSLog(@"更改昵称请求失败");
                    NSLog(@"错误提示:%@",error);
                }else{
                    [[NSUserDefaults standardUserDefaults] setObject:_userDic forKey:@"userDic"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textField resignFirstResponder];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ****** 更改密码
- (IBAction)changePassWord:(id)sender {
    [self.navigationController pushViewController:[[PasswordModifyViewController alloc]init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
