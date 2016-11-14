//  RootViewController.m
//  Ejinrong
//  Created by jr on 15/9/16.
//  Copyright (c) 2015年 pan. All rights reserved.
#import "RootViewController.h"
#import "SettingView.h"
#import "LoginNavigationController.h"
#import "UserCenterViewController.h"
#import "LightningView.h"
#import "RootTableViewCell.h"
#import "WebRequest.h"
#import "AFNetworking.h"
#import "GDataXMLNode.h"
#import "HistoryOrderViewController.h"
#import "holdPositionModel.h"
#import "GCDAsyncSocket.h"
#import "SingleSocket.h"
#import "PrefixHeader.pch"




static NSString* const BUYMORE = @"看多";
static NSString* const BUYLESS = @"看空";
static NSString* const TASKGUID = @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf";

@interface RootViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,PopViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,SingletonSocketDelegate>

@property (strong,nonatomic) UILabel *buttonLine1;//闪电图按钮线
@property (strong,nonatomic) UIButton *bullishBtn;//看多按钮
@property (strong,nonatomic) UIButton *bearishBtn;//看空按钮
@property (strong,nonatomic) UILabel *bullishBtnLabel;//看多价label
@property (strong,nonatomic) UILabel *bearishBtnLabel;//看空价label
@property (strong,nonatomic) UITableView *tableView;//在仓订单表格
@property (strong,nonatomic) NSMutableArray *tableViewDataArray;//分笔清仓表格数据数组
@property (strong,nonatomic) UILabel *nameLab;//商品名
@property (strong,nonatomic) UILabel *delegateNumberLabel;//委托手数
@property (strong,nonatomic) UILabel *newestPriceLabel;//买入价
@property (strong,nonatomic) UIScrollView *rootView;//根视图
@property (strong,nonatomic) NSArray *volumeArray;//几手
@property (strong,nonatomic) UISegmentedControl *segmentControl;//标题视图
@property (strong,nonatomic) SettingView *settingView;//设置视图
@property (strong,nonatomic) UIPickerView *picView;//滚动视图
@property (assign,nonatomic) BOOL isOut;//设置视图是否推出
@property (strong,nonatomic) LightningView *lightningView;//闪电图
@property (assign,nonatomic) CGFloat priceForLightningView;//闪电图买价
@property (strong,nonatomic) CADisplayLink *lightningDisplayLink;//闪电图定时器
@property (assign,nonatomic) long lightningStepper;//闪电图步长
@property (assign,nonatomic) CGFloat maxX;//闪电图最大x坐标
@property (assign,nonatomic) CGFloat maxY;//闪电图最大y坐标
@property (assign,nonatomic) CGFloat minX;//闪电图最小x坐标
@property (assign,nonatomic) CGFloat minY;//闪电图最小y坐标
@property (strong,nonatomic) NSMutableDictionary *userDic;//定义用户字典
@property (copy,nonatomic) NSString* alertStr;//alertView内容
@property (strong,nonatomic) UILabel *duoOrKongLabel;//买入界面提示买入的手数是看多还是看空label
@property (strong,nonatomic) UILabel *numberLabel;//买入界面显示买入手数label
@property (strong,nonatomic) UILabel *shouyiLabel;//买入界面显示盈亏数label
@property (strong,nonatomic) UILabel *yingkui;//买入界面显示"盈亏"label
//@property (strong,nonatomic) UILabel *$;//买入界面显示“$”符号label
@property (strong,nonatomic) UILabel *shou;//买入界面"手"的label
@property (strong,nonatomic) UILabel *balanceLabel;//订单界面显示"盈亏(不计手续费)"label
@property (strong,nonatomic) UILabel *yuanLabel;//订单界面显示盈亏数
@property (strong,nonatomic) UILabel *yuantextLabel;//订单界面显示"$"label
@property (strong,nonatomic) UILabel *lineLabel;//订单界面显示“分割线”
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件
@property (strong,nonatomic) UIRefreshControl *refresh;//在仓订单下拉刷新控件
@property (assign,nonatomic) NSInteger lastChoose;//最后的选择
@property (strong,nonatomic) NSMutableArray *priceArray;//闪电图历史价数组
@property (copy,nonatomic) NSString *loginAccount;//当前登录账户
@property (strong,nonatomic) NSArray *bhList;//商品列表
@property (strong,nonatomic) NSMutableDictionary *bhDic;//商品字典
@property (strong,nonatomic) NSMutableDictionary *nameDic;//商品中文字典
@property (assign,nonatomic) long currentTimeStamp;//系统北京时间戳
@property (copy,nonatomic) NSString *currentDate;//系统北京时间的日期字符串
//@property (assign,nonatomic) BOOL inTime;//是否在交易时间
@property (copy,nonatomic) NSString *iPhoneID;//iPhone唯一标识
@property (copy,nonatomic) NSString *iPhoneIP;//iPhone的IP地址
@property (strong,nonatomic) WebRequest *webRequest;//网络请求对象
@property (assign,nonatomic) BOOL isShowAlertView;//是否开启操作成功弹窗
//@property (assign,nonatomic) int positionVolume;//在仓手数
@property (strong,nonatomic) NSMutableArray* asyncSocketArray;//socket接收数据的数组
@property (strong,nonatomic) NSMutableArray* lastArray;//历史行情最后一个数据的数据
@property (strong,nonatomic) NSMutableArray* newlastArray;//最新行情,计算盈亏
@property (strong,nonatomic) NSString* dianchaString;//止盈止损大小(参数传给后台)
//@property (assign,nonatomic) int secondsCountDown;//倒计时秒数
@property (strong,nonatomic) NSTimer *countDownTimer;//倒计时定时器，买入后倒计时
@property (strong,nonatomic) UILabel *labelText;//倒计时lable
@property (assign,nonatomic) float Increment;

@end
@implementation RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCurrencyInformation];//获取货币信息
    
    [self initData];//初始化数据
    [self initControls];//初始化控件
    [self initNavigationBar];//初始化导航栏
    [self createRootScrollView];//创建根视图
    [self createSettingView];//创建设置视图
    [self getDataFromWebForPosi];//在仓数据的请求
    [self netStatus];//检测网络状态
    [self getDriverId];//获取手机唯一标示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createSocket) name:@"socket" object:nil];//从登录界面不登录直接返回，开启socket；
    SingleSocket* socker = [SingleSocket sharedInstance] ;//socket连接
    socker.delegate = self;
}
#pragma mark ****** 倒计时
- (void)startWithTime:(NSInteger)timeLine{
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                                    _labelText.text = @"";
                                    [self buttonCanTouch];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 _labelText.text=[NSString stringWithFormat:@"%ld",(long)timeOut];
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}
#pragma mark ****** 获取货币详情
-(void)getCurrencyInformation{
    //获取商品列表
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                @"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"HBList",@"DataType",@"1234",@"UserID",nil];
    WebRequest* web = [[WebRequest alloc]init];
    [web webRequestWithDataDic:dic requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error != nil) { }else{
            NSString* eleString = [self getResultStringFromOperation:(NSData *)responseObject];
            NSData *data = [eleString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *bhArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (bhArray.count == 0) {
                UIAlertView *alart = [[UIAlertView alloc] initWithTitle:@"商品列表加载失败，请重启软件" message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
                [alart show];
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:bhArray forKey:@"BHList"];
            }
        }
    }];
}
#pragma mark ****** 恒德8.0 ios手机端下载以及使用说明
-(void)openBrowser {
    //打开浏览器
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://xidue.com/hd/hd.html"]];
}
#pragma mark ****** socket单例创建
-(void)createSocket{
    [[SingleSocket sharedInstance] socketConnectHost];
}
#pragma mark ****** singleSocket代理方法
-(void)didReadData:(NSString *)data{
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
    NSString* name = _bhDic[_bhList[j][@"Name"]][@"Bh"];
    //拆分字符串成数组
    NSString* resultString;
    NSMutableArray* socketArray;
    NSArray* arr = [data componentsSeparatedByString:@"\r"];
    WLog(@"%@",arr);
    for (int i=0; i<arr.count; i++) {
        resultString = arr[i];
        NSArray* array = [resultString componentsSeparatedByString:@","];//数据数组
        if (array.count > 1) {
            socketArray = [NSMutableArray arrayWithArray:array];
        }
    }
    for (int i = 0; i < _bhList.count; i++) {
        if ([socketArray[2] isEqualToString:_bhDic[_bhList[i][@"Name"]][@"Bh"]]) {//和货币名称一样
            _newlastArray = socketArray;
        }
    }
    if ([name isEqualToString:socketArray[2]]) {
        _asyncSocketArray = socketArray;
        [self updateLightningViewUI:socketArray];//更新闪电图
    }
    if ([socketArray[1] isEqualToString:@"CloseOrders"]){//强平
        if ([socketArray[2] isEqualToString:_loginAccount]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"login"]) {
                [self buttonNotTouch];
                [self getDataFromWebForPosi];
            }
        }
    }else if ([socketArray[1] isEqualToString:@"Change"]){//不同客户端登陆
        if ([socketArray[2] isEqualToString:_loginAccount]) {
            NSString* DriverID = [[NSUserDefaults standardUserDefaults] objectForKey:@"DRIVERID"];
            if (![socketArray[3] isEqualToString:DriverID]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"login"]) {
                    [self OtherClientLogin];
                }
            }
        }
        [self getDataFromWebForPosi];
    }
    [self updateCurrentPriceAndProfits:YES];
}
-(void)SingetonError:(NSError *)error{
    NSString* errorStr = [NSString stringWithFormat:@"%@",error.localizedDescription];
    if ([errorStr isEqualToString:@"Network is unreachable"]) {
        return;
    }
    if (error == nil) {return;}
    else{ //如果不是返回断开链接  就重新链接
        [self showAlert:@"数据连接中断"];
        [[SingleSocket sharedInstance] socketConnectHost];
    }
}
#pragma mark ****** 其他客户端登录，所做的处理
-(void)OtherClientLogin{
    _loginAccount = @"";
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"其他客户端登录，本客户端退出!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark button不能点击
- (void)buttonNotTouch{
    _bullishBtn.enabled = _bearishBtn.enabled = NO;
    [_bullishBtn setTitleColor:[UIColor colorWithRed:252/255.0 green:108/255.0 blue:87/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_bearishBtn setTitleColor:[UIColor colorWithRed:63/255.0 green:140/255.0 blue:226/255.0 alpha:1.0] forState:UIControlStateNormal];
}
#pragma mark button可以点击
- (void)buttonCanTouch{
    _bullishBtn.enabled = _bearishBtn.enabled = YES;
    [_bullishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bearishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
#pragma mark 检测网络状态
-(void)netStatus{
    //检测手机运行的是什么网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable){
            [[SingleSocket sharedInstance] stopSocket];
            [self alertWithTitle:@"请求超时,请检查网络连接" cancelButtonTitle:@"关闭" otherButtonTitle:nil];
        }else if(status == AFNetworkReachabilityStatusReachableViaWiFi){
            [[SingleSocket sharedInstance] socketConnectHost];
            UIView *midView=[[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT/2, WIDTH, 30)];
            midView.backgroundColor=[UIColor colorWithRed:220.0/255 green:236.0/255 blue:202.0/255 alpha:0.3];
            UILabel *netLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, WIDTH, 30)];
            [netLabel setText:@"您现在使用的是WiFi网络"];
            netLabel.textColor=[UIColor whiteColor];
            netLabel.textAlignment=NSTextAlignmentCenter;
            [midView addSubview:netLabel];
            [self.view addSubview:midView];
             [UIView animateWithDuration:3.0 delay:1.0 options:0  animations:^{
                 CGRect rect = midView.frame;
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                 rect.origin.x=WIDTH;
                 midView.frame = rect;
             } completion:^(BOOL finished) {
                 [midView removeFromSuperview];
             }];
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            [[SingleSocket sharedInstance] socketConnectHost];
            UIView *midView=[[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT/2, WIDTH, 30)];
            midView.backgroundColor=[UIColor colorWithRed:220.0/255 green:236.0/255 blue:202.0/255 alpha:0.3];
            UILabel *netLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, WIDTH, 30)];
            [netLabel setText:@"您现在使用的是2/3/4G网络"];
            netLabel.textColor=[UIColor whiteColor];
            netLabel.textAlignment=NSTextAlignmentCenter;
            [midView addSubview:netLabel];
            [self.view addSubview:midView];
            [UIView animateWithDuration:3.0 delay:1.0 options:0  animations:^{
                CGRect rect = midView.frame;
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                rect.origin.x=WIDTH;
                midView.frame = rect;
            } completion:^(BOOL finished) {
                [midView removeFromSuperview];
            }];
        }
    }];
}
#pragma mark 初始化数据
- (void)initData{
    [self initBaseData];//初始化基本数据
    [self getSystemTime];//获取系统北京的时间
//    [self getHBWorkTime];//获取商品交易时间
    [self chooseDianCha];//获取止盈止损
}
#pragma mark 初始化基本数据
- (void)initBaseData{
    _webRequest = [[WebRequest alloc] init];
    NSString* path = [[NSBundle mainBundle]pathForResource:@"dataList" ofType:@"plist"];
    NSDictionary* data = [[NSDictionary alloc]initWithContentsOfFile:path];
    _volumeArray = data[@"buyNum"];//委托手数
    _priceArray = [NSMutableArray array];//历史价格数组
    _loginAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"][@"LoginID"];//登录用户名
    _iPhoneID = [UIDevice currentDevice].identifierForVendor.UUIDString;//手机唯一标识
    _iPhoneIP = [[NSUserDefaults standardUserDefaults] objectForKey:@"iPhoneIP"];//手机IP地址
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"jiaoyishuliang"];
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"xuanzexiangmu"];
    _bhList = [[NSUserDefaults standardUserDefaults] objectForKey:@"BHList"];//获取商品列表
    WLog(@"%@",_bhList);
    /**
     [{
             "Name": "美原油",
             "Bh": "CLF6",
             "Increment": 0.01,
             "USD": 20,
             "Converts": 100,
             "Price": 0,
             "ASKPrice": 0,
             "RMB": 25
         },{
             "Name": "恒生指数",
             "Bh": "HKZ5",
             "Increment": 1,
             "USD": 20,
             "Converts": 1,
             "Price": 0,
             "ASKPrice": 0,
             "RMB": 25
         }]
     */
    _bhDic = [NSMutableDictionary dictionary];//商品字典
    _nameDic = [NSMutableDictionary dictionary];//商品中文名字典
    /**
     { "恒生指数" = {
             Bh = HKZ5;
             NewestPrice = 0;
             SinglePrice = 2000;
             DecimalPoint = 1 };
         "美原油" = {
             Bh = CLF6;
             NewestPrice = 0;
             SinglePrice = 13;
             DecimalPoint = 0.01  };
     }
     */
    for (NSDictionary *dic in _bhList) {
        NSMutableDictionary *subDic = [NSMutableDictionary dictionary];
        NSNumber *singlePrice = [NSNumber numberWithFloat:[dic[@"Converts"] floatValue]*[dic[@"USD"] floatValue]];
        [subDic setObject:singlePrice forKey:@"SinglePrice"];
        [subDic setObject:dic[@"Bh"] forKey:@"Bh"];
        [subDic setObject:dic[@"Increment"] forKey:@"DecimalPoint"];
        [_bhDic setObject:subDic forKey:dic[@"Name"]];
        [_nameDic setObject:dic[@"Name"] forKey:dic[@"Bh"]];
    }
    //闪电图数据
    _maxX = WIDTH-51;
    _maxY = 20.0;
    _minX = 5;
    _minY = (HEIGHT-60)*0.44-20.0;
    //默认开启操作成功弹窗提示
    _isShowAlertView = YES;
}
#pragma mark 初始化控件
- (void)initControls{
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];//刷新控件
    [_activity setCenter:self.view.center];//指定进度轮中心点
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
    [self.view addSubview:_activity];
    [_activity startAnimating];
    _lightningDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(lightningStepper:)];
    [_lightningDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
#pragma mark 初始化导航栏
- (void)initNavigationBar{
    //------ 设置导航栏颜色 ------
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    //------ 导航栏标题视图 ------
    _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"买入",@"订单"]];
    _segmentControl.frame = CGRectMake(0, 0, 100 ,25);
    _segmentControl.layer.cornerRadius = 5.0;
    _segmentControl.layer.masksToBounds = YES;
    _segmentControl.layer.borderWidth = 1.0;
    _segmentControl.layer.borderColor = GLODENCOLOR.CGColor;
    _segmentControl.backgroundColor = [UIColor blackColor];
    _segmentControl.tintColor = GLODENCOLOR;
    _segmentControl.selectedSegmentIndex = 0;
    [_segmentControl addTarget:self action:@selector(changeValue) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentControl;
    //------ 初始化设置和个人中心按钮 ------
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"root_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(openBrowser)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"root_user"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(userCenterBtnClick:)];
}
#pragma mark ****** 获取driverId
-(void)getDriverId{
     if ([[NSUserDefaults standardUserDefaults] boolForKey:@"login"]) {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"DriverID",@"DataType", _loginAccount,@"DataGuid",nil];
        [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeGetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSString* data = [self getResultStringFromOperation:(NSData *)responseObject];
                if (![data isEqualToString:_iPhoneID] && ![data isEqualToString:@""]) {
                    [self OtherClientLogin];
                }
        }];
    }
}
#pragma mark 创建持仓请求数据
- (void)getDataFromWebForPosi{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                @"1234567890",@"DriverID",
                                @"1111",@"UserID",
                                @"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",
                                @"InOrderList",@"DataType",
                                _loginAccount,@"LoginID", nil];
    [_webRequest webRequestWithDataDic:dic requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) { }else{
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            int volumes = 0;
            long prices = 0;//定义总盈利数
            NSData* data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (_tableViewDataArray.count > 0) {
                [_tableViewDataArray removeAllObjects];
//                _positionVolume = 0;
            }
//            NSMutableArray* array = [[NSMutableArray alloc]init];
            for (NSDictionary* dic in jsonDic) {
                holdPositionModel* model = [[holdPositionModel alloc]init];
                model.name =(_nameDic[dic[@"Symbol"]] ==nil ? dic[@"Symbol"] : _nameDic[dic[@"Symbol"]]);
                model.buyLessOrMore = dic[@"Type"];
                model.OpenPrice = dic[@"OpenPrice"];
                model.ClosePrice = dic[@"ClosePrice"];
                model.Profit = dic[@"Profit"];
                model.Commission = dic[@"Commission"];
                model.OrderNumber = dic[@"OrderNumber"];
                model.Volume = dic[@"Volume"];
                model.StopLoss = dic[@"StopLoss"];
                model.TakeProfit = dic[@"TakeProfit"];
                prices+=[dic[@"Profit"] longValue];//累加盈亏
                volumes+=[dic[@"Volume"] intValue];//累加总手数
                [_tableViewDataArray insertObject:model atIndex:0];
//                if ([_nameLab.text isEqualToString:_nameDic[dic[@"Symbol"]]]) {
//                    [array insertObject:model atIndex:0];
//                }
            }
            [_tableView reloadData];
            
            if (_tableViewDataArray.count == 0) {
                _duoOrKongLabel.text = @"   ";
                _numberLabel.text = _shouyiLabel.text = @"0";
                 [self updateWidthOfVolume:_numberLabel.text];
            }else{
//                long pri = 0;
//                int vol = 0;
                 for (holdPositionModel* model in _tableViewDataArray) {
//                     pri += [model.Profit longValue];//累加盈亏
//                     vol += [model.Volume intValue];//累加总手数
                     for (NSDictionary *dic in jsonDic) {
                        //刷新手数
                        if (model.buyLessOrMore != nil) {
                            if ([_nameLab.text isEqualToString:_nameDic[dic[@"Symbol"]]]) {
                                UIFont *font = _duoOrKongLabel.font = [UIFont systemFontOfSize:18.0f];
                                CGSize size1 = [_duoOrKongLabel.text boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil].size;
                                _duoOrKongLabel.frame = CGRectMake(0.094*WIDTH, CGRectGetMaxY(_bullishBtn.frame)+10, size1.width, _duoOrKongLabel.frame.size.height);
//                                _numberLabel.text = [NSString stringWithFormat:@"%d",vol];
                                [self updateWidthOfVolume:_numberLabel.text];
                            }
                        }
                    }
                 }
            }
            
            //刷新盈亏数字
            _yuanLabel.textColor = (prices < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
            NSString *str = _yuanLabel.text = [NSString stringWithFormat:@"%ld",prices];
            CGSize priceSize = [str boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:30.0] forKey:NSFontAttributeName] context:nil].size;
            [_yuanLabel setFrame:CGRectMake(WIDTH+20, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.026, priceSize.width, 30)];
            _yuantextLabel.frame = CGRectMake(CGRectGetMaxX(_yuanLabel.frame)+5, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.0264+4, WIDTH*0.09, HEIGHT*0.044);
        }
    }];
}
#pragma mark 获取当前选中商品的总持仓手数
- (void)getCurrentTotalPositionVolume:(int)selectIndex{
    for (holdPositionModel*model in _tableViewDataArray) {
        if ([model.name isEqualToString:_nameDic[_bhList[selectIndex][@"Bh"]]]) {
//            _positionVolume += [model.Volume intValue];
        }
    }
}
#pragma mark 创建根视图
- (void)createRootScrollView{
    _rootView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT)];
    _rootView.contentSize = CGSizeMake(WIDTH*2, HEIGHT-64);
    _rootView.delegate = self;
    _rootView.pagingEnabled = YES;
    _rootView.bounces = NO;
    _rootView.backgroundColor = [UIColor colorWithRed:10/255.0 green:11/255.0 blue:20/255.0 alpha:1];
    [self.view addSubview:_rootView];
    [self createBuyView];//创建买入页面
    [self createPositionView];//买入后持仓页面
    [self creataPositionTableView];////买入后持仓列表
}
#pragma mark 创建设置视图
- (void)createSettingView{
    //------ 设置视图 ------
    _settingView = [[SettingView alloc]initWithFrame:CGRectMake(0, -HEIGHT, WIDTH, HEIGHT)];
    _settingView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:_settingView aboveSubview:_rootView];
    //------ 设置视图_滚动视图 ------
    _picView = [[UIPickerView alloc]initWithFrame:CGRectMake(WIDTH*0.25, _settingView.bounds.size.height*0.5-150, WIDTH*0.5, 200)];
    _picView.delegate = self;
    _picView.dataSource = self;
    _picView.showsSelectionIndicator = YES;;
    [_settingView addSubview:_picView];
    //------ 操作成功弹窗 ------
    UIView *successView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH*0.5-90, CGRectGetMaxY(_picView.frame)+5, 180, 31)];
    [_settingView addSubview:successView];
    UILabel *successTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5.5, 120, 20)];
    successTitle.text = @"操作成功弹窗";
    successTitle.font = [UIFont systemFontOfSize:18.0];
    successTitle.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [successView addSubview:successTitle];
    UISwitch* swit =[[UISwitch alloc] initWithFrame:CGRectMake(successView.bounds.size.width-51, 0, 51, 31)];
    [swit setOn:YES];
    [swit addTarget:self action:@selector(showAlartView:) forControlEvents:UIControlEventValueChanged];
    [successView addSubview:swit];
    //------  确定按钮 ------
    UIButton* yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    yesButton.frame = CGRectMake(WIDTH/2 - 80, CGRectGetMaxY(successView.frame)+50, 160, 40);
    [yesButton setTitle:@"确定" forState:UIControlStateNormal];
    [yesButton addTarget:self action:@selector(chooseDelegateNum) forControlEvents:UIControlEventTouchUpInside];
    [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    yesButton.backgroundColor = [UIColor redColor];
    yesButton.layer.masksToBounds = YES;
    yesButton.layer.cornerRadius = 8;
    [_settingView addSubview:yesButton];
}
#pragma mark 操作成功弹窗开关
- (void)showAlartView:(UISwitch *)sender{  _isShowAlertView = sender.on;}
#pragma mark 创建买入视图
- (void)createBuyView{
    //------ 商品名 ------
    int num = [[[NSUserDefaults standardUserDefaults]objectForKey:@"xuanzexiangmu"] intValue];
    _nameLab = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2.0-100, 15, 200, (HEIGHT-60)*0.045)];
    _nameLab.textAlignment = NSTextAlignmentCenter;
    _nameLab.text = _bhList[num][@"Name"];
    _nameLab.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    _nameLab.textColor = [UIColor whiteColor];
    [self.rootView addSubview:_nameLab];
    //------ 最新价(price) ------
    _newestPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2 - 80, CGRectGetMaxY(_nameLab.frame)+7.5, 160, 36)];
    _newestPriceLabel.textColor = GLODENCOLOR;
    _newestPriceLabel.text = @"0.00";
    _newestPriceLabel.textAlignment = NSTextAlignmentCenter;
    _newestPriceLabel.font = [UIFont systemFontOfSize:36.0];
    [self.rootView addSubview:_newestPriceLabel];
    
    //------ 闪电图按钮 ------
    UILabel* lightningLab = [[UILabel alloc]initWithFrame:CGRectMake((WIDTH-WIDTH*0.3)/2, CGRectGetMaxY(_newestPriceLabel.frame)+16, WIDTH* 0.3, (HEIGHT-60)* 0.04)];
    lightningLab.text = @"闪电图";
    lightningLab.textAlignment = NSTextAlignmentCenter;
    lightningLab.textColor = GLODENCOLOR;
    [self.rootView addSubview:lightningLab];
    //------ 闪电图按钮线 ------
    _buttonLine1=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lightningLab.frame)-WIDTH*0.3, CGRectGetMaxY(lightningLab.frame)-2, WIDTH* 0.3, 2)];
    _buttonLine1.backgroundColor=GLODENCOLOR;
    [self.rootView addSubview:_buttonLine1];
    //------ 闪电图视图 ------
    [self createLightningView];
    //------ 看多按钮 ------
    CGFloat buttonWidth = (WIDTH - 34)/3.0;
    _bullishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _bullishBtn.frame = CGRectMake(12, CGRectGetMaxY(_buttonLine1.frame)+27 + (HEIGHT-60)*0.44, buttonWidth, 44);
    [_bullishBtn setTitle:@"看多" forState:UIControlStateNormal];
    [_bullishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bullishBtn.titleLabel.font = [UIFont systemFontOfSize:22.0];
    _bullishBtn.layer.cornerRadius = 10.0;
    _bullishBtn.layer.masksToBounds = YES;
    _bullishBtn.backgroundColor = REDCOLOR;
    _bullishBtn.tag = 100001;
    [_bullishBtn addTarget:self action:@selector(bullishOrBearishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:_bullishBtn];
    //------ 看多价label ------
    _bullishBtnLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, CGRectGetMinY(_bullishBtn.frame)-14.5, buttonWidth, 11)];
    _bullishBtnLabel.text = @"0.00";
    _bullishBtnLabel.textColor = REDCOLOR;
    _bullishBtnLabel.textAlignment = NSTextAlignmentCenter;
    _bullishBtnLabel.font = [UIFont systemFontOfSize:11.0];
    [self.rootView addSubview:_bullishBtnLabel];
    
    //------ 委托手数 ------
    NSString *str1 = @"1";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"委托 %@ 手",str1]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,2)];
    [str addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(3,str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(4+str1.length,1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(3, str1.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(4+str1.length, 1)];
    _delegateNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(17+buttonWidth, _bullishBtn.frame.origin.y, buttonWidth, 44)];
    _delegateNumberLabel.attributedText = str;
    _delegateNumberLabel.textAlignment = NSTextAlignmentCenter;
    [self.rootView addSubview:_delegateNumberLabel];
    
    UIButton* chooseNum = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    chooseNum.frame = _delegateNumberLabel.frame;
    [chooseNum addTarget:self action:@selector(chooseDelegateNum) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:chooseNum];
    //------ 倒计时lable ------
    _labelText = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH - 140, _newestPriceLabel.frame.origin.y, 120, 36)];
    _labelText.textColor = [UIColor whiteColor];
    _labelText.font = [UIFont systemFontOfSize:28.0f];
    _labelText.textAlignment = NSTextAlignmentCenter;
    [self.rootView addSubview:_labelText];
    //------ 看空按钮 ------
    _bearishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _bearishBtn.frame = CGRectMake(22+buttonWidth*2, _bullishBtn.frame.origin.y, buttonWidth, 44);
    [_bearishBtn setTitle:@"看空" forState:UIControlStateNormal];
    [_bearishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bearishBtn.titleLabel.font = [UIFont systemFontOfSize:22.0];
    _bearishBtn.layer.cornerRadius = 10.0;
    _bearishBtn.layer.masksToBounds = YES;
    _bearishBtn.backgroundColor = BLUECOLOR;
    _bearishBtn.tag = 100002;
    [_bearishBtn addTarget:self action:@selector(bullishOrBearishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:_bearishBtn];
    //------ 看空价label ------
    _bearishBtnLabel = [[UILabel alloc]initWithFrame:CGRectMake(22+buttonWidth*2, CGRectGetMinY(_bearishBtn.frame)-14.5, buttonWidth, 11)];
    _bearishBtnLabel.text = @"0.00";
    _bearishBtnLabel.textColor = BLUECOLOR;
    _bearishBtnLabel.textAlignment = NSTextAlignmentCenter;
    _bearishBtnLabel.font = [UIFont systemFontOfSize:11.0];
    [self.rootView addSubview:_bearishBtnLabel];
    //------  主界面提示买入的手数是看多还是看空label ------
    _duoOrKongLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.094*WIDTH, CGRectGetMaxY(_bullishBtn.frame)+10, 20, 18)];
//    _duoOrKongLabel.text = @"看多/空";
//    _duoOrKongLabel.numberOfLines = 0;
//    _duoOrKongLabel.textColor = [UIColor colorWithRed:0.95 green:0.78 blue:0.52 alpha:1];
//    [self.rootView addSubview:_duoOrKongLabel];
    //------ 主界面提示买入多少手label ------
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_duoOrKongLabel.frame), _duoOrKongLabel.frame.origin.y, 20, 18)];
    _numberLabel.text = @"0";
    _numberLabel.font = [UIFont systemFontOfSize:18.0f];
    _numberLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.82 alpha:1];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    [self.rootView addSubview:_numberLabel];
    //------ "手"的Label ------
    _shou = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_numberLabel.frame)+5, _numberLabel.frame.origin.y+5, 12, 10)];
    _shou.text = @"手";
    _shou.font = [UIFont systemFontOfSize:12.0f];
    _shou.textColor = [UIColor grayColor];
    [self.rootView addSubview:_shou];
    //------ 买入界面"盈亏"的label ------
    _yingkui = [[UILabel alloc]initWithFrame:CGRectMake(_bearishBtn.frame.origin.x, _duoOrKongLabel.frame.origin.y, 40, 15)];
//    _yingkui.text = @"盈亏";
//    _yingkui.textColor = [UIColor colorWithRed:0.95 green:0.78 blue:0.52 alpha:1];
//    [self.rootView addSubview:_yingkui];
    //------ 盈亏数label ------
    _shouyiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_yingkui.frame), _duoOrKongLabel.frame.origin.y, 12, 17)];
//    _shouyiLabel.text = @"+0";
//    _shouyiLabel.numberOfLines = 0;
//    _shouyiLabel.font = [UIFont systemFontOfSize:22.0f];
//    [self.rootView addSubview:_shouyiLabel];
    //------ "$"的label ------
//     _$ = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_shouyiLabel.frame), _shouyiLabel.frame.origin.y + 5, 15, 10)];
//    _$.font = [UIFont systemFontOfSize:12.0f];
//    _$.text = @"$";
//    _$.textColor = [UIColor grayColor];
//    [self.rootView addSubview:_$ ];
}
#pragma mark ****** 止盈止损数据请求
-(void)chooseDianCha{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1234567890",@"DriverID",@"",@"UserID",@"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"QPDSXF",@"DataType", nil];
    [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error != nil) {   [self alertWithTitle:error.localizedDescription cancelButtonTitle:@"确定" otherButtonTitle:nil];  }
        NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
        NSData* data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        _dianchaString = [NSString stringWithFormat:@"%@",dataArray[0][@"Point"]];
    }];
}

#pragma mark 创建闪电图,请求历史行情
- (void)createLightningView{
    //请求的历史历史行情数字
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:_iPhoneID,@"DriverID",TASKGUID,@"TaskGuid",@"",@"UserID",@"MT4DataHistory",@"DataType",@"300",@"Top",_bhList[j][@"Bh"],@"Type",nil];
    [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {[self alertWithTitle:@"请求失败" cancelButtonTitle:@"关闭" otherButtonTitle:nil];} else {
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            //------ 判断是否有数据返回，如果有则加载UI ------
            if ([resultString isEqualToString:@"[]"]) {
                [self alertWithTitle:@"没有历史行情数据,请稍后再试..." cancelButtonTitle:@"关闭" otherButtonTitle:nil];
                _lightningView = [[LightningView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_buttonLine1.frame), WIDTH, (HEIGHT-60)*0.44)];
                _lightningView.backgroundColor = [UIColor clearColor];
                [self.rootView addSubview:_lightningView];
            }else{
                NSData *eleData = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:eleData options:NSJSONReadingMutableContainers error:nil];
                NSMutableArray *dataArray = [[NSMutableArray alloc]init];
                if (dataArr.count == 0) {
                    [self showAlert:@"没有行情数据"];
                    _lightningView = [[LightningView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_buttonLine1.frame), WIDTH, (HEIGHT-60)*0.44)];
                    _lightningView.backgroundColor = [UIColor clearColor];
                    [self.rootView addSubview:_lightningView];
                     return ;
                }else{
                    for (int i=0; i<dataArr.count; i++) {
                        float price = [dataArr[i][@"Price"] floatValue];
                        [dataArray insertObject:[NSNumber numberWithFloat:price] atIndex:0];
                    }
                }
                _bullishBtn.enabled = _bearishBtn.enabled = YES;
                [_bullishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_bearishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self LoadLightningViewUI:dataArray];//加载UI
                //获取初始价格数组
                if (dataArray.count>(int)(WIDTH-56)) {
                    dataArray = [NSMutableArray arrayWithArray:[dataArray subarrayWithRange:NSMakeRange(0, (int)(WIDTH-56))]];
                }
                _priceArray = dataArray;
                _lastArray = [NSMutableArray arrayWithObjects:@"Data",@"0",@"0",[dataArray firstObject],@"0", nil];
                _newestPriceLabel.text = [NSString stringWithFormat:@"%@",[dataArray firstObject]];
            }
            [_activity stopAnimating];
        }
        WLog(@"%lu",(unsigned long)_tableViewDataArray.count);
        if (_tableViewDataArray.count > 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"login"]) {
            [self buttonNotTouch];
        }
    }];
}
#pragma mark 加载闪电图UI
- (void)LoadLightningViewUI:(NSMutableArray *)dataArray{
    CGFloat maxPriceForLightningView = 0,minPriceForLightningView = 0;
    //最新价格
    maxPriceForLightningView = minPriceForLightningView = [[dataArray objectAtIndex:0] floatValue];
    //求出历史最大值
    for (int i = 0; i<dataArray.count; i++) {
        if ([dataArray[i] floatValue] > maxPriceForLightningView) {
            maxPriceForLightningView = [dataArray[i] floatValue];
        }
        if ([dataArray[i] floatValue] < minPriceForLightningView) {
            minPriceForLightningView = [dataArray[i] floatValue];
        }
    }
    //初始页面上的点数组
    CGFloat startX = 5.0;
    //防止请求过来的行情数大于(int)(WIDTH-51)
    CGFloat maxCountOfPoint = dataArray.count;
    if (maxCountOfPoint>(WIDTH-56)) {
        maxCountOfPoint = WIDTH-56;
    }
    //根据历史行情价格算出每秒移动多少x距离(水平距离)
    CGFloat qx = (WIDTH-56)/maxCountOfPoint;
    NSMutableArray *initArr = [NSMutableArray array];
    for (int i = 0; i < (int)maxCountOfPoint ; i++) {
        CGFloat x = (startX+=qx);
        CGFloat y = 20+((HEIGHT-60)*0.44-40.0)*(maxPriceForLightningView - [[dataArray objectAtIndex:(int)maxCountOfPoint-1-i] floatValue])/(maxPriceForLightningView-minPriceForLightningView);
        [initArr addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    //最新价格对应的Y坐标
    CGFloat newPriceY = [[initArr lastObject] CGPointValue].y;
    [initArr addObject:[NSValue valueWithCGPoint:CGPointMake(_maxX+16, newPriceY)]];
    //初始化闪电图
    _lightningView = [[LightningView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_buttonLine1.frame), WIDTH, (HEIGHT-60)*0.44)];
    _lightningView.maxPriceForLightningView = maxPriceForLightningView;
    _lightningView.minPriceForLightningView = minPriceForLightningView;
    _lightningView.pointArray = initArr;
    _lightningView.backgroundColor = [UIColor clearColor];
    [self.rootView addSubview:_lightningView];
}
#pragma mark 更新闪电图UI
- (void)updateLightningViewUI:(NSArray*)dataArray{
                int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
//                if ([self isInWorkTime:j]) {
                    //刷新最新价
                    _priceForLightningView = [[dataArray objectAtIndex:3] floatValue];
                    _lightningView.priceLabel.text = [dataArray objectAtIndex:3];
                    //刷新看多买入价格
                    _newestPriceLabel.text = _bearishBtnLabel.text = [NSString stringWithFormat:@"%.1f",[dataArray[3] floatValue] * 1.0];
                    //刷新看空买入价格
                    _bullishBtnLabel.text = [NSString stringWithFormat:@"%.1f",[[dataArray objectAtIndex:3] floatValue] + _Increment];
//                }else{
//                    _newestPriceLabel.text = _bullishBtnLabel.text = _bearishBtnLabel.text = @"0.00";
//                }
                //刷新点数组
                [_priceArray insertObject:[NSNumber numberWithFloat:_priceForLightningView] atIndex:0];
                //初始化显示的最大最小价格
                CGFloat maxPriceForLightningView = _priceForLightningView,minPriceForLightningView = _priceForLightningView;
                //求出历史最大最大最小价格
                for (int i = 0; i<_priceArray.count; i++) {
                    if ([_priceArray[i] floatValue] > maxPriceForLightningView) {
                        maxPriceForLightningView = [_priceArray[i] floatValue];
                    }
                    if ([_priceArray[i] floatValue] < minPriceForLightningView) {
                        minPriceForLightningView = [_priceArray[i] floatValue];
                    }
                }
                //初始页面上的点数组
                CGFloat startX = 5.0;
                //防止请求过来的行情数大于(int)(WIDTH-51)
                CGFloat maxCountOfPoint = _priceArray.count;
                if (maxCountOfPoint>(WIDTH-56)) {
                    maxCountOfPoint = WIDTH-56;
                }
                //根据历史行情价格算出每秒移动多少x距离(水平距离)
                CGFloat qx = (WIDTH-56)/maxCountOfPoint;
                //定义新的点数组
                NSMutableArray *pointArray = [NSMutableArray array];
                //最大最小相等的情况
                if (maxPriceForLightningView == minPriceForLightningView) {
                    for (int i = 0; i < (int)maxCountOfPoint ; i++) {
                        CGFloat x = (startX+=qx);
                        CGFloat y = 20+((HEIGHT-60)*0.44-40.0)*0.5;
                        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    }
                    //最新价格对应的Y坐标
                    CGFloat newPriceY = [[pointArray lastObject] CGPointValue].y;
                    [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(_maxX+16, newPriceY)]];
                    //不显示的价格
                    for (NSInteger i=10; i<=15; i++) {
                        UILabel *label = (UILabel *)[self.view viewWithTag:i];
                        label.text = @"";
                    }
                    //刷新买价label
                    CGFloat y = 20+((HEIGHT-60)*0.44-40.0)*0.5;
                    _lightningView.priceLabel.frame = CGRectMake(_maxX+11, y-6.5, 37, 13);
                }else{//正常情况
                    for (int i = 0; i < (int)maxCountOfPoint ; i++) {
                        CGFloat x = (startX+=qx);
                        CGFloat y = 20+((HEIGHT-60)*0.44-40.0)*(maxPriceForLightningView - [[_priceArray objectAtIndex:(int)maxCountOfPoint-1-i] floatValue])/(maxPriceForLightningView-minPriceForLightningView);
                        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    }
                    //最新价格对应的Y坐标
                    CGFloat newPriceY = [[pointArray lastObject] CGPointValue].y;
                    [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(_maxX+16, newPriceY)]];
                    //刷新显示的价格
                    CGFloat p = (maxPriceForLightningView - minPriceForLightningView)/5.0;
                    for (NSInteger i=10; i<=15; i++) {
                        UILabel *label = (UILabel *)[self.view viewWithTag:i];
                        label.text = [self getShowPriceForLightningWithPrice:minPriceForLightningView+p*(i-10) increment:_bhDic[_bhList[j][@"Name"]][@"DecimalPoint"]];
                    }
                    //刷新买价label
                    CGFloat y = 20+((HEIGHT-60)*0.44-40.0)*(maxPriceForLightningView - _priceForLightningView)/(maxPriceForLightningView-minPriceForLightningView);
                    _lightningView.priceLabel.frame = CGRectMake(_maxX+11, y-6.5, 37, 13);
                }
                //刷新闪电图所有点的位置
                [_lightningView refreshPoint:pointArray];
                //删除最老的价格
                [_priceArray removeLastObject];
                [_activity stopAnimating];

}
#pragma mark 实时刷新
- (void)lightningStepper:(CADisplayLink *)sender{
    _lightningStepper++;
    if (_lightningStepper%60==0) {//1秒一次
        [self getSystemTime];
        int i = [[[NSUserDefaults standardUserDefaults]objectForKey:@"xuanzexiangmu"] intValue];
        NSString* name = _bhDic[_bhList[i][@"Name"]][@"Bh"];
        [self updateCurrentPriceAndProfits:NO];//刷新最新盈亏数和行情价格
        
        if (_lastArray[3] == _asyncSocketArray[3]) {
            if ([name isEqualToString:_asyncSocketArray[2]]) {
                [self updateLightningViewUI:_asyncSocketArray];//更新闪电图UI
            }
        }else if(_asyncSocketArray != nil){
            if ([name isEqualToString:_asyncSocketArray[2]]) {
                _lastArray = _asyncSocketArray;
            }
        }
        [self ThreeTimeLabelLeftMove];//刷新闪电图下面显示的3个时间label
    }
}
#pragma mark 刷新闪电图下面显示的3个时间label
- (void)ThreeTimeLabelLeftMove{
    for (int i = 30; i <= 32; i++) {
        UILabel* label = (UILabel*)[self.view viewWithTag:i];
        CGRect rect = label.frame;
        rect.origin.x -= 1;
        if (rect.origin.x<10-(WIDTH-71)/2.0) {
            rect.origin.x = WIDTH-71;
            [self nowTime:label];
        }
        label.frame = rect;
    }
}
#pragma mark 刷新最新盈亏数和行情价格
- (void)updateCurrentPriceAndProfits:(BOOL)isSocket{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (login) {
            double prices = 0;//当前总盈亏
        NSMutableArray* array = [[NSMutableArray alloc]init];
            for (holdPositionModel *holdPosition in _tableViewDataArray) {
//                [self buttonNotTouch];
                double profit = 0;
                for (NSInteger i = 0; i<_bhList.count; i++) {
                    if ([holdPosition.name isEqualToString:_bhList[i][@"Name"]]) {
                        if ([holdPosition.buyLessOrMore isEqualToString:@"Buy"]) {//看多盈利: (关仓价格-开仓价格)*单价*手数
                            if ( [_bhList[i][@"Bh"] isEqualToString:_newlastArray[2]]) {
                                holdPosition.ClosePrice = (NSNumber *)_newlastArray[3];
                                if ([_newlastArray[3] floatValue] >= [holdPosition.TakeProfit floatValue] || [_newlastArray[3] floatValue] <= [holdPosition.StopLoss floatValue]) {
                                    [array addObject:holdPosition];
                                }
                            }
                            profit = ([holdPosition.ClosePrice doubleValue] - [holdPosition.OpenPrice doubleValue]) * [_bhDic[_bhList[i][@"Name"]][@"SinglePrice"] doubleValue]*[holdPosition.Volume intValue];
                            _lightningView.price = profit;
                        }else{//看空盈利: (开仓价格-关仓价格)*单价*手数
                            if ( [_bhList[i][@"Bh"] isEqualToString:_newlastArray[2]]) {
                                float num =[_bhList[i][@"Increment"] floatValue];
                                float Increment = [_newlastArray[3] floatValue] + num;
                                holdPosition.ClosePrice = [NSNumber numberWithFloat:Increment];
                                if (Increment <= [holdPosition.TakeProfit floatValue] || Increment >= [holdPosition.StopLoss floatValue]) {
                                    [array addObject:holdPosition];
                                }
                            }
                            profit = ([holdPosition.OpenPrice doubleValue] - [holdPosition.ClosePrice doubleValue]) * [_bhDic[_bhList[i][@"Name"]][@"SinglePrice"] doubleValue] * [holdPosition.Volume intValue];
                            _lightningView.price = profit;
                        }
                    }
                }
                int closePrice = [holdPosition.ClosePrice intValue];
                if (closePrice == 0) {
                    holdPosition.Profit = [NSNumber numberWithInt:0];
                }else{
                    prices+=profit;
                     holdPosition.Profit = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%.0f",profit] integerValue]];
                }
                
                
            }

        /**
         主界面盈利刷新，只显示本货币的盈利多少
         */
        double pric = 0;//当前总盈亏
        int nums = 0;
        for (int i=0; i<_bhList.count; i++) {
            if ([_nameLab.text isEqualToString:_bhList[i][@"Name"]]) {
                if ([_newlastArray[2] isEqualToString:_bhList[i][@"Bh"]]) {
                        for (holdPositionModel *holdPosition in _tableViewDataArray) {
                            double profit = 0;
                            int num = 0;
                            if ([holdPosition.name isEqualToString:_bhList[i][@"Name"]]) {
                                profit = [holdPosition.Profit doubleValue];
                                num = [holdPosition.Volume intValue];
                                pric += profit;
                                nums += num;
                            }
                        }
                    _numberLabel.text = [NSString stringWithFormat:@"%d",nums];
//                    _shouyiLabel.text = [NSString stringWithFormat:@"%.0f",pric];
//                    _shouyiLabel.textColor = (pric < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
                }
            }
        }
        if (array.count >0) {
            if (_isShowAlertView) {
                [self showAlert:@"平仓成功!"];
            }
            [_tableViewDataArray removeObjectsInArray:array];
            [_tableView reloadData];
             [self updateWidthOfVolume:_numberLabel.text];
            [self buttonNotTouch];
            [self startWithTime:10];
            [self getDataFromWebForPosi];
        }
       
        _yuanLabel.text = [NSString stringWithFormat:@"%.0f",prices];
        _yuanLabel.textColor = (prices < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
        NSString *str = _yuanLabel.text = [NSString stringWithFormat:@"%.0f",prices];
        CGSize priceSize = [str boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:30.0] forKey:NSFontAttributeName] context:nil].size;
        _yuanLabel.frame = CGRectMake(WIDTH+20, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.026, priceSize.width, 30);
        _yuantextLabel.frame = CGRectMake(CGRectGetMaxX(_yuanLabel.frame)+5, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.0264+4, WIDTH*0.09, HEIGHT*0.044);
        
//        _$.frame = CGRectMake(WIDTH-40, _duoOrKongLabel.frame.origin.y+5, 15, 12);
//        CGSize $size = [_shouyiLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:22.0] forKey:NSFontAttributeName]];
//        _shouyiLabel.frame = CGRectMake(_$.frame.origin.x-$size.width, _duoOrKongLabel.frame.origin.y-5, $size.width, $size.height);
//        _yingkui.frame = CGRectMake(_shouyiLabel.frame.origin.x-_yingkui.bounds.size.width, _shouyiLabel.frame.origin.y, _yingkui.bounds.size.width, _shouyiLabel.bounds.size.height);
        [_tableView reloadData];
    }else{
//        _shouyiLabel.text = @"0";
        _numberLabel.text = @"0";
    }
}
#pragma mark 现在的时间,转换成时、分、秒
- (void)nowTime:(UILabel*)lab{
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    long hour = [dateComponent hour];
    long minute = [dateComponent minute];
    long seconds = [dateComponent second];
    NSString * secondStr;
    NSString * minuteStr;
    if (seconds<10) {
        secondStr = [NSString stringWithFormat:@"0%ld",seconds];
    }else
        secondStr = [NSString stringWithFormat:@"%ld",seconds];
    if (minute<10) {
        minuteStr = [NSString stringWithFormat:@"0%ld",minute];
    }else
        minuteStr = [NSString stringWithFormat:@"%ld",minute];
    if (hour>=0&&hour<=6) {
        lab.text = [NSString stringWithFormat:@"%ld:%@:%@",24+hour-7,minuteStr,secondStr];
    }else
       lab.text = [NSString stringWithFormat:@"%ld:%@:%@",hour-7,minuteStr,secondStr];
}
#pragma mark 1.5s消失提示框
- (void)timerFireMethod1:(NSTimer*)theTimer{
    UIAlertController *promptAlert = (UIAlertController*)[theTimer userInfo];
    [promptAlert dismissViewControllerAnimated:YES completion:nil];
    promptAlert =nil;
}
- (void)showAlert:(NSString *)message{
    UIAlertController *promptAlert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(timerFireMethod1:)
                                   userInfo:promptAlert
                                    repeats:YES];
    [self presentViewController:promptAlert animated:YES completion:nil];
}
#pragma mark 看多(看空)按钮点击事件
- (void)bullishOrBearishBtnClick:(UIButton *)sender{
   BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (!login) {//登录前
        [self alertWithTitle:@"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
    }else{//登录后
//            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
//            _inTime = [self isInWorkTime:i];
//            if (_inTime == YES) {
                if (sender.tag == 100001) {
//                    if ([sender.titleLabel.text isEqualToString:BUYMORE] || [sender.titleLabel.text isEqualToString:BUYONCE]){
                        [self buy:@"多"];
//                    }else{
////                        [self reversePosition:@"多"];
//                    }
                }else if (sender.tag == 100002){
//                    if ([sender.titleLabel.text isEqualToString:BUYLESS] || [sender.titleLabel.text isEqualToString:BUYONCE]){
                        [self buy:@"空"];
//                    }else{
//                        [self reversePosition:@"空"];
//                    }
                }
//            }else{
//                [self alertWithTitle:@"不在交易时间" cancelButtonTitle:@"确定" otherButtonTitle:nil];
//            }
    }
}
#pragma mark 根据选择项目判断是否在交易时间
- (BOOL)isInWorkTime:(int)index{
    NSArray *HBWorkTimeArray = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"HBWorkTime"];
    BOOL inTime = YES;
//    [self getSystemTime];
    for (NSDictionary *dic in HBWorkTimeArray) {
        if ([dic[@"HB"] isEqualToString:_bhList[index][@"Bh"]]) {
            long startTimeStamp = [self timeStampConvertFromTimeString:[NSString stringWithFormat:@"%@ %@",[_currentDate componentsSeparatedByString:@" "][0],dic[@"Start_Time"]]];
            long endTimeStamp = [self timeStampConvertFromTimeString:[NSString stringWithFormat:@"%@ %@",[_currentDate componentsSeparatedByString:@" "][0],dic[@"End_Time"]]];
            if (_currentTimeStamp >= startTimeStamp && _currentTimeStamp <= endTimeStamp) {
                inTime = YES;
                break;
            }else{
                inTime = NO;
            }
        }
    }
    return inTime;
}
#pragma mark 获取系统北京的时间
- (void)getSystemTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    _currentDate = [formatter stringFromDate:date];
    if ([_currentDate isEqualToString:@"16:00:00"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"xuanzexiangmu"];
        [_lightningView removeFromSuperview];
//        [_nameLab setTitle:_bhList[2][@"Name"] forState:UIControlStateNormal];
        _nameLab.text = _bhList[2][@"Name"];
        [self createLightningView];
    }
    _currentTimeStamp = (long)[date timeIntervalSince1970];
    int hour = [[_currentDate substringToIndex:2] intValue];
    if (hour >= 9 && hour < 16) {
        _Increment = [_bhList[0][@"Increment"] floatValue];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"xuanzexiangmu"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"xuanzexiangmu"];
        _Increment =[_bhList[2][@"Increment"] floatValue];
    }
    
}
#pragma mark 看多(看空)的买入/追单
- (void)buy:(NSString *)bullishOrBearish{
    int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"jiaoyishuliang"] intValue];
        _alertStr = [NSString stringWithFormat:@"您已成功看%@买入%@，请进入订单查看相关信息！",bullishOrBearish,_volumeArray[i]];
    if (_tableViewDataArray.count == 0) {
        [self BuyRequestData:bullishOrBearish];
    }else{
        [self showAlert:@"已有订单!"];
    }
}
#pragma mark 看多(看空)的请求数据
- (void)BuyRequestData:(NSString *)bullishOrBearish{
    [_activity startAnimating];
    [self buttonNotTouch];//设置button不能被点击
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    int i = [[user objectForKey:@"jiaoyishuliang"] intValue];
    NSString *volume = [NSString stringWithFormat:@"%d",i+1];
    int j = [[user objectForKey:@"xuanzexiangmu"] intValue];
    NSString *dataType = nil;
    if ([bullishOrBearish isEqualToString:@"多"]) {
        dataType = @"Buy";
    }else if ([bullishOrBearish isEqualToString:@"空"]){
        dataType = @"Sell";
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                @"1234567890",@"DriverID",
                @"1234",@"UserID",
                TASKGUID,@"TaskGuid",
                @"InOrder",@"DataType",
                _loginAccount,@"Login",
                _bhList[j][@"Bh"],@"Symbol",
                volume,@"Volume",
               _dianchaString,@"StopLoss",
                _dianchaString,@"TakeProfit",
                @"1",@"ProductType",
                @"iPhone",@"Comment",
                dataType,@"Type",nil];
    [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
        NSData* data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dic[@"OrderNumber"] isEqualToString:@""]) {
             [self alertWithTitle:dic[@"Comment"] cancelButtonTitle:@"确定" otherButtonTitle:nil];
             [self buttonCanTouch];
        }else{
//                _positionVolume += [volume intValue];
            [self getDataFromWebForPosi];
            if (_isShowAlertView) {
                [self showAlert:@"买入成功"];
            }
        }
        [_activity stopAnimating];
    }];
}
#pragma mark 买入后订单页面
- (void)createPositionView{
    //盈亏
    _balanceLabel=[[UILabel alloc] initWithFrame:CGRectMake(WIDTH+20, 37.5, 120, 15)];
    _balanceLabel.text=@"盈亏(不计手续费)";
    _balanceLabel.textColor = GLODENCOLOR;
    _balanceLabel.font=[UIFont fontWithName:@"Helvetica" size:15.0];
    [self.rootView addSubview:_balanceLabel];
    //当前收益
    _yuanLabel=[[UILabel alloc]initWithFrame:CGRectMake(WIDTH+20, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.026, 30, 30)];
    _yuanLabel.text = @"0";
    _yuanLabel.textColor=REDCOLOR;
    _yuanLabel.font = [UIFont systemFontOfSize:30.0];
    [self.rootView addSubview:_yuanLabel];
    _yuantextLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_yuanLabel.frame)+2, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.0264+5, WIDTH*0.09, HEIGHT*0.044)];
    _yuantextLabel.text=@"$";
    _yuantextLabel.textColor=[UIColor grayColor];
    _yuantextLabel.font=[UIFont systemFontOfSize:18.0];
    [self.rootView addSubview:_yuantextLabel];
    //初始化历史订单按钮
    UIButton* historyOrNowOrderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    historyOrNowOrderButton.backgroundColor = GLODENCOLOR;
    historyOrNowOrderButton.layer.cornerRadius = 5;
    historyOrNowOrderButton.frame = CGRectMake(2*WIDTH -100 , HEIGHT* 0.11, 82, 30) ;
    [historyOrNowOrderButton setTitle:@"历史订单" forState:UIControlStateNormal];
    [historyOrNowOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [historyOrNowOrderButton addTarget:self action:@selector(changeHistoryOrNow) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:historyOrNowOrderButton];
    _lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(WIDTH, CGRectGetMaxY(_yuanLabel.frame)+HEIGHT*0.0246, WIDTH, 1)];
    _lineLabel.tintColor=[UIColor whiteColor];
    _lineLabel.backgroundColor=[UIColor grayColor];
    [self.rootView addSubview:_lineLabel];
}
#pragma mark 在仓，历史订单切换
- (void)changeHistoryOrNow{
    HistoryOrderViewController* view1 = [[HistoryOrderViewController alloc]init];
    [self.navigationController pushViewController:view1 animated:YES];
}
#pragma mark 创建持仓列表
- (void)creataPositionTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(WIDTH, CGRectGetMaxY(_lineLabel.frame)+2, WIDTH, HEIGHT-CGRectGetMaxY(_lineLabel.frame)-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = YES;
    _tableView.separatorColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.rootView addSubview:_tableView];
    _tableViewDataArray = [[NSMutableArray alloc]init];
    //下拉刷新
    _refresh = [[UIRefreshControl alloc]init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"下拉加载"];
    [title addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(0, 4)];
    _refresh.attributedTitle = title;//下拉刷新时的标题
    _refresh.tintColor = GLODENCOLOR;
    [_tableView addSubview:_refresh];//把_refresh与tableView关联
    //指定_refresh的下拉事件处理方法
    [_refresh addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
}
#pragma mark refresh的下拉事件处理方法
- (void)onRefresh{
    [self getDataFromWebForPosi];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"拼命加载中..."];
    [title addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(0, 8)];
    _refresh.attributedTitle = title;
    _refresh.tintColor = GLODENCOLOR;
    //一段时间之后执行某个方法，用此模拟请求数据所用的时间
    //参数一：一段时间之后要执行的方法
    //参数三：多长时间之后执行，以秒为单位
    [self performSelector:@selector(endRefresh) withObject:nil afterDelay:2];
}
- (void)endRefresh{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"✅加载完成"];
    [title addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(0, 5)];
    _refresh.attributedTitle = title;
    _refresh.tintColor = GLODENCOLOR;
    //停菊花
    [_refresh endRefreshing];
    [self performSelector:@selector(end) withObject:nil afterDelay:0.5];
}
- (void)end{
    [NSThread sleepForTimeInterval:1.0f];
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc] initWithString:@"下拉加载"];
    [title1 addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(0, 4)];
    _refresh.attributedTitle = title1;
    _refresh.tintColor = GLODENCOLOR;
}
#pragma mark tableView的代理方法
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellId = @"cell";
    RootTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[RootTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell.buyMoreOrLess setTextColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell config:_tableViewDataArray[indexPath.row]];
    return cell;
}
#pragma mark tableView的代理返回cell高度和个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return _tableViewDataArray.count; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ return 60;}
#pragma mark 标题视图点击事件
- (void)changeValue{
    if (_segmentControl.selectedSegmentIndex == 0) {
        [_rootView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
        if (!login) {
            [_segmentControl setSelectedSegmentIndex:0];
            [self alertWithTitle: @"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
        }else{
            [_rootView setContentOffset:CGPointMake(WIDTH, 0) animated:YES];
        }
    }
}
#pragma mark 设置点击事件
- (void)chooseDelegateNum{
    _isOut = !_isOut;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = _settingView.frame;
        rect.origin.y = _isOut ?  0 : -HEIGHT;
        _settingView.frame = rect;
    }];
    int num = [[[NSUserDefaults standardUserDefaults] objectForKey:@"jiaoyishuliang"] intValue];
    NSString *aaa = [NSString stringWithFormat:@"%d",num+1];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"委托 %@ 手",aaa]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,2)];
    [str addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(3,aaa.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(4+aaa.length,1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(3, aaa.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(4+aaa.length, 1)];
    _delegateNumberLabel.attributedText = str;
}

#pragma mark 个人中心按钮点击事件
- (void)userCenterBtnClick:(UIBarButtonItem *)sender{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (!login) {
        [self alertWithTitle:@"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
    }else{
        UserCenterViewController *userVc = [[UserCenterViewController alloc]init];
        userVc.delegate = self;
        [self.navigationController pushViewController: userVc animated:YES];
    }
}
#pragma mark 返回代理
- (void)setPopViewControoler{
    [_bullishBtn setTitle:BUYMORE forState:UIControlStateNormal];
    [_bearishBtn setTitle:BUYLESS forState:UIControlStateNormal];
    [_segmentControl setSelectedSegmentIndex:0];
    [_rootView setContentOffset:CGPointMake(0, 0)];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}
- (void)changeNaiColor{
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}
#pragma mark 滑动结束事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_rootView.contentOffset.x == 0) {
        [_segmentControl setSelectedSegmentIndex:0];
    }else{
        [_segmentControl setSelectedSegmentIndex:1];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:22.0],NSFontAttributeName, nil]];
    }
}
#pragma mark UIPickerView的代理方法
#pragma mark 返回列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{return 1;}
#pragma mark 返回每列行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0 == component ?  _volumeArray.count : _bhList.count;
}
#pragma mark 把选中行的标题放入用户配置
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = ( 0 == component ?  @"jiaoyishuliang" : @"xuanzexiangmu");
    [user setObject:[NSNumber numberWithInteger:row] forKey:keyStr];
    if (component == 1) {
        [user setInteger:row forKey:@"lastChoose"];
    }
    [user synchronize];
}
#pragma mark 自定义每行的视图
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* lab = [[UILabel alloc] init];
    lab.text = 0 == component ?  _volumeArray[row] : _bhList[row][@"Name"];
    lab.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor whiteColor];
    return lab;
}
#pragma mark 滑动跳转界面
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (scrollView.contentOffset.x > 0 && login == 0) {
        [self alertWithTitle:@"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
    }
}
#pragma mark 时间字符串转时间戳
- (long)timeStampConvertFromTimeString:(NSString *)timeString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    [formatter setLocale:locale];
    NSDate *date = [formatter dateFromString:timeString];
    return (long)[date timeIntervalSince1970];
}
#pragma mark 根据商品买价和增益(Increment)返回闪电图显示的6个买价之一的价格
- (NSString *)getShowPriceForLightningWithPrice:(CGFloat)price increment:(NSNumber *)increment{
    NSString *returnString;
    if ([increment floatValue] >= 1) {
        returnString = [NSString stringWithFormat:@"%.0f",price];
    }else{
        NSUInteger decomalLength = [[[NSString stringWithFormat:@"%@",increment] componentsSeparatedByString:@"."][1] length];
        switch (decomalLength) {
            case 1:
                returnString = [NSString stringWithFormat:@"%g",[[NSString stringWithFormat:@"%.2f",price] floatValue]];
                break;
            case 2:
                returnString = [NSString stringWithFormat:@"%g",[[NSString stringWithFormat:@"%.3f",price] floatValue]];
                break;
            default:
                returnString = [NSString stringWithFormat:@"%g",[[NSString stringWithFormat:@"%.4f",price] floatValue]];
                break;
        }
    }
    return returnString;
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
#pragma mark 弹窗提示
- (void)alertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherTitle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    if (otherTitle!=nil) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"push" object:nil];
            [[SingleSocket sharedInstance] stopSocket];
        }];
        [alertController addAction:otherAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark 刷新买入界面的手数宽度
- (void)updateWidthOfVolume:(NSString *)volumeString{
    UIFont *numberLabelfont = [UIFont systemFontOfSize:18.0f];
    CGSize numberLabelsize = [volumeString boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:numberLabelfont forKey:NSFontAttributeName] context:nil].size;
    _numberLabel.frame = CGRectMake(CGRectGetMaxX(_duoOrKongLabel.frame)+5, CGRectGetMaxY(_duoOrKongLabel.frame)-18, numberLabelsize.width, _numberLabel.frame.size.height);
    _shou.frame = CGRectMake(CGRectGetMaxX(_numberLabel.frame), _numberLabel.frame.origin.y+5, _shou.frame.size.width, _shou.frame.size.height);
}

@end
