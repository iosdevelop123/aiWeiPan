    //
//  UserCenterViewController.m
//  Ejinrong
//
//  Created by dayu on 15/10/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "UserCenterViewController.h"
#import "RootViewController.h"
#import "UserDetailViewController.h"
#import "GesturePasswordViewController.h"
#import "CustomNavigation.h"
#import "WebRequest.h"
#import "AFNetworking.h"
#import "GDataXMLNode.h"
#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
#define TASKGUID  @"b4026263-704e-4e12-a64d-f79cb42962cc"
@interface UserCenterViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UserDetailViewControllerDelegate>

@property (strong,nonatomic) NSMutableDictionary *userDic;//用户数据字典
@property (strong,nonatomic) UITableView *tableView;//
@property (strong,nonatomic) NSArray *imageArray;//tableview 图片数组
@property (strong,nonatomic) NSArray *titleArray;//tableview 标题数组
@property (strong,nonatomic) NSMutableArray *detailTextArray;//tableview 副标题数组
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件
@property (strong,nonatomic) UILabel *nickNameLabel;
@property (strong,nonatomic) UIImageView* headImageView;//头像
@property (strong,nonatomic) UILabel *nickNameLable;//昵称

@end

@implementation UserCenterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initData];
    [self createUI];
    [self netStatus];
    [self initActivity];
}
#pragma mark ****** //------ 刷新控件 ------
-(void)initActivity{
    //------ 指定进度轮中心点 ------
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //------ 指定进度轮中心点 ------
    [_activity setCenter:self.view.center];
    //------ 设置进度轮显示类型 ------
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activity];
    [_activity startAnimating];
}
#pragma mark ****** 初始化数据
-(void)initData{
    [CustomNavigation loadUIViewController:self title:@"个人中心" navigationBarBgColor:[UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]  backSelector:@selector(back)];
    NSString* path = [[NSBundle mainBundle]pathForResource:@"dataList" ofType:@"plist"];
    NSDictionary* data = [[NSDictionary alloc]initWithContentsOfFile:path];
    self.userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"];
    _imageArray = data[@"imageArray"];
    _titleArray = data[@"titleArray"];
}
 #pragma mark ******  检测手机网络状态
-(void)netStatus{
    //检测手机运行的是什么网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status==AFNetworkReachabilityStatusNotReachable){
            UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"请求超时,请检查网络连接"   message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *canaleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
            [AlertController addAction:canaleAction];
            [self presentViewController:AlertController animated:YES completion:nil];
//            [_activity stopAnimating];
        }else{
            NSInteger num = [[NSUserDefaults standardUserDefaults]integerForKey:@"yue"];
            NSString *balance = [NSString stringWithFormat:@"%ld$",(long)num];
            UITableViewCell *cell =[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.detailTextLabel.text= balance;
//            [self requestBalanceData];
        }
        [_activity stopAnimating];
    }];
}
#pragma mark ****** 网络请求个人信息
-(void)requestBalanceData{
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"userDic"];
    NSString* DriverID = [[NSUserDefaults standardUserDefaults]objectForKey:@"DRIVERID"];
    NSString *LoginAccount = [userDic objectForKey:@"LoginID"];
    NSString *LoginPass = [userDic objectForKey:@"LoginPass"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:DriverID,@"DriverID",@"1",@"UserID",TASKGUID,@"TaskGuid",@"CheckUser",@"DataType",LoginAccount,@"LoginID", LoginPass,@"LoginPass",nil];
    WebRequest *webRequest = [[WebRequest alloc] init];
    [webRequest webRequestWithDataDic:dic requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {  }else{
            GDataXMLDocument* document = [[GDataXMLDocument alloc]initWithData:responseObject options:0 error:nil];
            GDataXMLElement* element = [document rootElement];
            NSArray* array = [element children];
            for (int i = 0; i<array.count; i++) {
                GDataXMLElement* ele = [array objectAtIndex:i];
                NSData* data = [[ele stringValue]dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *balance = [NSString stringWithFormat:@"%@$",jsonDic[@"DouBiWeiPan"]];
                UITableViewCell *cell =[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.detailTextLabel.text= balance;
            }
        }
        [_activity stopAnimating];
    }];
}
-(void)createUI{
    //------ 头像 ------
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH-HEIGHT*0.12)/2, HEIGHT*0.15, HEIGHT*0.12, HEIGHT*0.12)];
    _headImageView.layer.borderWidth = 2;
    _headImageView.layer.borderColor = [UIColor colorWithRed:55/255.0 green:134/255.0 blue:226/255.0 alpha:1].CGColor;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = HEIGHT*0.06;
    //用户数据字典中取头像
    _headImageView.image = [UIImage imageNamed:@"login_user"];
    [self.view addSubview:_headImageView];
    //------ 昵称 ------
    _nickNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT*0.27, WIDTH, HEIGHT*0.06)];
    [_nickNameLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    _nickNameLabel.textAlignment=NSTextAlignmentCenter;
    _nickNameLabel.text = _userDic[@"NickName"];
    [self.view addSubview:_nickNameLabel];
    //------ 可用余额，总积分，个人信息，启动密码 ------
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEIGHT*0.36, WIDTH, HEIGHT*0.32) style:UITableViewStylePlain];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = NO;
    _tableView.rowHeight = HEIGHT*0.08;
    [self.view addSubview:_tableView];
    //------ 分割线 ------
    for (NSInteger i=0; i<4; i++) {
        UILabel *lineLabels=[[UILabel alloc]initWithFrame:CGRectMake(10, HEIGHT*0.36+i*HEIGHT*0.08, WIDTH-20, 1)];
        lineLabels.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.view addSubview:lineLabels];
    }
    //------ 注销 ------
    UIButton *zhuxiaoButton=[UIButton buttonWithType:UIButtonTypeSystem];
    zhuxiaoButton.frame=CGRectMake(20, HEIGHT*0.36+4*HEIGHT*0.09+HEIGHT*0.09, WIDTH-20*2, HEIGHT*0.08);
    [zhuxiaoButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [zhuxiaoButton addTarget:self action:@selector(zhuxiaoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    zhuxiaoButton.layer.cornerRadius=HEIGHT*0.01;
    zhuxiaoButton.titleLabel.font=[UIFont systemFontOfSize:18.0];
    [zhuxiaoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    zhuxiaoButton.backgroundColor=[UIColor colorWithRed:1 green:67/255.0 blue:32/255.0 alpha:1.0];
    [self.view addSubview:zhuxiaoButton];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mycell"];
    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row<1) {
        cell.detailTextLabel.text =@"0$";
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        UserDetailViewController *vc = [[UserDetailViewController alloc]init];
        vc.delegate = self;
        [self.navigationController pushViewController: vc animated:YES];
    }else if (indexPath.row == 2){
        [self.navigationController pushViewController:[[GesturePasswordViewController alloc]init] animated:YES];
    }
}
#pragma mark ****** 改变头像代理方法
- (void)changeHeadimage:(NSData *)imageData{
    _headImageView.image = [UIImage imageWithData:imageData];
    
}
#pragma mark ****** 改变昵称代理方法
- (void)changeNickname:(NSString *)Nickname{
    _nickNameLabel.text = Nickname;
}
#pragma mark ****** 点击注销
- (void)zhuxiaoBtnClick{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
    [self.navigationController popViewControllerAnimated:YES];
     [_delegate setPopViewControoler];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"要否退出登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [_delegate setPopViewControoler];
//        [_activity startAnimating];
//        NSString* driverId = [[NSUserDefaults standardUserDefaults] objectForKey:@"DRIVERID"];
//        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:driverId,@"DriverID",TASKGUID,@"TaskGuid",@"DriverLoginOut",@"DataType", nil];
//        WebRequest *webRequest = [[WebRequest alloc] init];
//        [webRequest webRequestWithDataDic:userDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//            if (error!=nil) {
//                NSLog(@"错误提示:%@",error);
//            }else{
//                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            [_activity stopAnimating];
//        }];
//
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ****** 点击更换头像事件
- (void)enterToUserDetail:(UIButton*)sender{
    if (sender.tag==102) {
        [self.navigationController pushViewController:[[UserDetailViewController alloc]init] animated:YES];
    }else if (sender.tag == 103){
        [self.navigationController pushViewController:[[GesturePasswordViewController alloc]init] animated:YES];
    }
}
- (void)back{
//    if (_returnRootViewBlock) {
//        _returnRootViewBlock();
//    }
    [_delegate changeNaiColor];
    [self.navigationController popViewControllerAnimated:YES];
}
@end