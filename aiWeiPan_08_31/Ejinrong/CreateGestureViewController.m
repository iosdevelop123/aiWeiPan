//
//  CreateGestureViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "CreateGestureViewController.h"
#import "CustomNavigation.h"
#import "CreateGesturePasswordViewController.h"

#define Height self.view.bounds.size.height
#define Width self.view.bounds.size.width

@interface CreateGestureViewController ()
@end

@implementation CreateGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"启动密码" navigationBarBgColor:[UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0] backSelector:@selector(back)];
    self.view.backgroundColor=[UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1.0];
    [self createUI];
}
-(void)createUI
{
    UIImageView *iphoneImageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, 64+30, 100, 200)];
    iphoneImageView.image=[UIImage imageNamed:@"iphone"];
    [self.view addSubview:iphoneImageView];
    
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(10, 294, self.view.bounds.size.width, 40)];
    label1.text=@"手势启动密码，安全快捷！";
    label1.textColor=[UIColor whiteColor];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.font=[UIFont systemFontOfSize:13.0];
    [self.view addSubview:label1];
    
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(10, 294+40, self.view.bounds.size.width-10*2, 60)];
    label2.text=@"创建手势启动密码后，他人在使用您手机时也无法打开手机实盘交易软件";
    label2.numberOfLines=0;
    label2.textColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:0.5];
    label2.textAlignment=NSTextAlignmentLeft;
    label2.font=[UIFont systemFontOfSize:12.0];
    [self.view addSubview:label2];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:label2.text];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:7];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, label2.text.length)];
    label2.attributedText = attributedString;
    
    UIButton *createGestureButton=[UIButton buttonWithType:UIButtonTypeSystem];
    createGestureButton.frame=CGRectMake(10, 294+100+10, self.view.bounds.size.width-10*2, Height*0.08);
    [createGestureButton setTitle:@"立即创建" forState:UIControlStateNormal];
    [createGestureButton addTarget:self action:@selector(createGestureClick) forControlEvents:UIControlEventTouchUpInside];
    createGestureButton.layer.cornerRadius=6;
    createGestureButton.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [createGestureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createGestureButton.backgroundColor=[UIColor colorWithRed:18/255.0 green:110/255.0 blue:214/255.0 alpha:1.0];
    [self.view addSubview:createGestureButton];
}
#pragma mark ****** 创建手势密码
-(void)createGestureClick
{
    CreateGesturePasswordViewController* ccv = [[CreateGesturePasswordViewController alloc]init];
    ccv.is = NO;
    [self.navigationController pushViewController:ccv animated:YES];
}
-(void)back{
    [_delegate setPopViewControoler];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end