//
//  EditGesturePasswordViewController.m
//  Ejinrong
//
//  Created by dayu on 15/11/9.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "EditGesturePasswordViewController.h"
#import "CustomNavigation.h"
#import "ChangeGesturePasswordViewController.h"
#import "DeleteCheckGesturePasswordViewController.h"
#import "GesturePasswordViewController.h"


#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface EditGesturePasswordViewController ()
@property (assign,nonatomic) BOOL isShowLine;
@end

@implementation EditGesturePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor * navBackColor = [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1];
    [CustomNavigation loadUIViewController:self title:@"启动密码" navigationBarBgColor:navBackColor backSelector:@selector(back)];
    [self creataUI];
}

- (void)creataUI{
    //------ 背景颜色 ------
    _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _backgroundView.backgroundColor = [UIColor colorWithRed:59/255.0 green:61/255.0 blue:65/255.0 alpha:1];
    [self.view addSubview:_backgroundView];
    UIImageView * iphoneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-(WIDTH*0.29/2), 84, WIDTH*0.29, WIDTH*0.29*2.04)];
    iphoneImageView.image = [UIImage imageNamed:@"iphone"];
    [self.view addSubview:iphoneImageView];
    
    //------ 解锁时手势可见 ------
    _whitchView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(iphoneImageView.frame)+20, WIDTH-20, 47)];
    _whitchView.backgroundColor = [UIColor colorWithRed:67/255.0 green:69/255.0 blue:74/255.0 alpha:1];
    _whitchView.layer.cornerRadius = 5;
    [self.view addSubview:_whitchView];
    UILabel* whitchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 17, 180, 14)];
    whitchLabel.text = @"解锁时手势图案可见";
    whitchLabel.textColor = [UIColor whiteColor];
    [_whitchView addSubview:whitchLabel];
    UISwitch* swit =[[ UISwitch alloc]initWithFrame:CGRectMake(_whitchView.bounds.size.width-62, 8, 50, 31)];
    [swit addTarget:self action:@selector(showLine:) forControlEvents:UIControlEventValueChanged];
    [_whitchView addSubview:swit];
    
    //------ 更改启动密码btn ------
    _changeBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _changeBtn.frame = CGRectMake(_whitchView.frame.origin.x, CGRectGetMaxY(_whitchView.frame)+20, _whitchView.bounds.size.width, 43);
    [_changeBtn setTitle:@"更改启动密码" forState:UIControlStateNormal];
    [_changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _changeBtn.layer.cornerRadius = 5;
    _changeBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [_changeBtn addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _changeBtn.backgroundColor = [UIColor colorWithRed:18/255.0 green:113/255.0 blue:219/255.0 alpha:1];
    [self.view addSubview:_changeBtn];
    
    
    //------ 删除密码btn ------
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _deleteBtn.frame = CGRectMake(_changeBtn.frame.origin.x, CGRectGetMaxY(_changeBtn.frame)+20, _changeBtn.frame.size.width, 43);
    [_deleteBtn setTitle:@"删除启动密码" forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _deleteBtn.backgroundColor = [UIColor colorWithRed:226/255.0 green:59/255.0 blue:63/255.0 alpha:1];
    _deleteBtn.layer.cornerRadius = 5;
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [_deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    
}
#pragma mark ****** 是否显示手势路线
- (void)showLine:(UISwitch *)sender{
    _isShowLine = sender.on;
}

- (void)back{
    [_delegate setPopViewControoler];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)changeBtnClick:(id)sender {
    ChangeGesturePasswordViewController* vc = [[ChangeGesturePasswordViewController alloc]init];
    vc.isShowLine = _isShowLine;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteBtnClick:(id)sender {
    DeleteCheckGesturePasswordViewController* vc = [[DeleteCheckGesturePasswordViewController alloc]init];
    vc.isShowLine = _isShowLine;
    [self.navigationController pushViewController:vc animated:YES];
}
@end