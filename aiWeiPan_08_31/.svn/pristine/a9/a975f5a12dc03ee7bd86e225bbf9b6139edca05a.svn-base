//
//  UserDetailViewController.m
//  Ejinrong
//
//  Created by Secret Wang on 15/10/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "UserDetailViewController.h"
#import "NicknameModifyViewController.h"
#import "PasswordModifyViewController.h"
#import "CustomNavigation.h"
#import "CertificateCheckViewController.h"
#import "AFNetworking.h"
#import "WebRequest.h"
#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
@interface UserDetailViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,NSXMLParserDelegate,CertificateCheckViewControllerDelegate>

@property (strong,nonatomic) NSMutableDictionary *userDic;//用户字典
@property (strong,nonatomic) UITableView* tableView;//列表
@property (strong,nonatomic) NSMutableArray* dataAttay;//数据数组
@property (strong,nonatomic) UIButton *headButton;//头像
@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"个人信息" navigationBarBgColor:[UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]  backSelector:@selector(back)];
    _userDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"]];
    NSString* path = [[NSBundle mainBundle]pathForResource:@"dataList" ofType:@"plist"];
    NSDictionary* data = [[NSDictionary alloc]initWithContentsOfFile:path];
    _dataAttay = data[@"Personalinformation"];
    [self createUI];
}

-(void)back{
    UILabel *label = (UILabel *)[self.view viewWithTag:98];
    [_delegate changeNickname:label.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)createUI{
    UILabel* headLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, HEIGHT* 0.18, 100, 40)];
    headLabel.text = @"个人头像";
    [self.view addSubview:headLabel];
    _headButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _headButton.frame = CGRectMake((WIDTH-HEIGHT*0.12)/2+WIDTH* 0.20, HEIGHT*0.15, HEIGHT*0.12, HEIGHT*0.12);
    _headButton.layer.borderWidth = 2;
    _headButton.layer.borderColor = [UIColor colorWithRed:55/255.0 green:134/255.0 blue:226/255.0 alpha:1].CGColor;
    _headButton.layer.cornerRadius = HEIGHT*0.06;
    _headButton.layer.masksToBounds = YES;
    [_headButton setBackgroundImage:[UIImage imageNamed:@"login_user"] forState:UIControlStateNormal];
    [_headButton setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    [self.view addSubview:_headButton];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, HEIGHT* 0.30, WIDTH, HEIGHT* 0.7) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self ;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.rowHeight = HEIGHT*0.08;
    
    for (NSInteger i=0; i<4; i++) {
        UILabel *lineLabels=[[UILabel alloc]initWithFrame:CGRectMake(10, HEIGHT*0.3+i*HEIGHT*0.08, WIDTH-20, 1)];
        lineLabels.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.view addSubview:lineLabels];
    }
}
#pragma mark ****** tableView 的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  3;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellId = @"cell";
     UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataAttay[indexPath.row];
    if (indexPath.row == 0) {
        cell.detailTextLabel.tag=98;
        cell.detailTextLabel.text = _userDic[@"NickName"];
    }else if (indexPath.row == 1) {
        cell.detailTextLabel.text = _userDic[@"LoginAccount"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NicknameModifyViewController* vc = [[NicknameModifyViewController alloc] init];
        [vc setSaveBlock:^(NSString * str) {
            UILabel* lav = (UILabel*)[self.view viewWithTag:98];
            lav.text = str;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2){
        [self.navigationController pushViewController:[[PasswordModifyViewController alloc]init] animated:YES];
    }
}
- (void)showCertificate:(NSString *)carID name:(NSString *)name{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *str1 = [name stringByReplacingCharactersInRange:NSMakeRange(0, name.length-1) withString:@"*"];
    NSString *str2 = [carID stringByReplacingCharactersInRange:NSMakeRange(6, 8) withString:@"********"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",str1,str2];
    cell.userInteractionEnabled = NO;
}
@end