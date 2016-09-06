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

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define GLODENCOLOR [UIColor colorWithRed:232/255.0 green:192/255.0 blue:133/255.0 alpha:1.0]
#define REDCOLOR [UIColor colorWithRed:252/255.0 green:72/255.0 blue:46/255.0 alpha:1.0]
#define BLUECOLOR [UIColor colorWithRed:18/255.0 green:113/255.0 blue:220/255.0 alpha:1.0]

static NSString* const BUYMORE = @"看多";
static NSString* const BUYLESS = @"看空";
static NSString* const BUYONCE = @"追单";
static NSString* const ReversePosition = @"反向开仓";
static NSString* const TASKGUID = @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf";
static  NSString*const _IP_ADDRESS = @"139.196.207.149";
static int const _SERVER_PORT = 2012;

@interface RootViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,PopViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,GCDAsyncSocketDelegate>

@property (strong,nonatomic) UILabel *buttonLine1;//闪电图按钮线
@property (strong,nonatomic) UIButton *bullishBtn;//看多按钮
@property (strong,nonatomic) UIButton *bearishBtn;//看空按钮
@property (strong,nonatomic) UILabel *bullishBtnLabel;//看多价label
@property (strong,nonatomic) UILabel *bearishBtnLabel;//看空价label
@property (strong,nonatomic) UITableView *tableView;//在仓订单表格
@property (strong,nonatomic) NSMutableArray *tableViewDataArray;//分笔清仓表格数据数组
@property (strong,nonatomic) UIButton *nameLab;//商品名
@property (strong,nonatomic) UILabel *delegateNumberLabel;//委托手数
@property (strong,nonatomic) UILabel *newestPriceLabel;//买入价
@property (strong,nonatomic) UIScrollView *rootView;//根视图
@property (strong,nonatomic) NSArray *volumeArray;//几手
@property (strong,nonatomic) UISegmentedControl *segmentControl;//标题视图
@property (strong,nonatomic) SettingView *settingView;//设置视图
@property (strong,nonatomic) UIPickerView *picView;//滚动视图
@property (assign,nonatomic) BOOL isOut;//设置视图是否推出
@property (strong,nonatomic) UIImageView *bgImageView;//六虚线背景图片视图
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
@property (strong,nonatomic) UILabel *$;//买入界面显示“$”符号label
@property (strong,nonatomic) UILabel *shou;//买入界面"手"的label
@property (strong,nonatomic) UILabel *balanceLabel;//订单界面显示"盈亏(不计手续费)"label
@property (strong,nonatomic) UILabel *yuanLabel;//订单界面显示盈亏数
@property (strong,nonatomic) UILabel *yuantextLabel;//订单界面显示"$"label
@property (strong,nonatomic) UILabel *lineLabel;//订单界面显示“分割线”
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件
@property (strong,nonatomic) UIButton *allSellButton;//全部卖出
@property (strong,nonatomic) UIRefreshControl *refresh;//在仓订单下拉刷新控件
@property (assign,nonatomic) NSInteger lastChoose;//最后的选择
@property (strong,nonatomic) NSMutableArray *priceArray;//闪电图历史价数组
@property (copy,nonatomic) NSString *loginAccount;//当前登录账户
@property (strong,nonatomic) NSArray *bhList;//商品列表
@property (strong,nonatomic) NSMutableDictionary *bhDic;//商品字典
@property (strong,nonatomic) NSMutableDictionary *nameDic;//商品中文字典
@property (assign,nonatomic) long currentTimeStamp;//系统北京时间戳
@property (copy,nonatomic) NSString *currentDate;//系统北京时间的日期字符串
@property (assign,nonatomic) BOOL inTime;//是否在交易时间
@property (copy,nonatomic) NSString *iPhoneID;//iPhone唯一标识
@property (copy,nonatomic) NSString *iPhoneIP;//iPhone的IP地址
@property (strong,nonatomic) WebRequest *webRequest;//网络请求对象
@property (assign,nonatomic) BOOL isShowAlertView;//是否开启操作成功弹窗
//@property (assign,nonatomic) int positionVolume;//在仓手数

@property (strong,nonatomic) GCDAsyncSocket* asyncSocket;
@property (strong,nonatomic) NSMutableArray* asyncSocketArray;//socket接收数据的数组
@property (strong,nonatomic) NSMutableArray* lastArray;//历史行情最后一个数据的数据
@property (strong,nonatomic) NSMutableArray* newlastArray;//最新行情,计算盈亏
@property (strong,nonatomic) NSMutableArray * meiyuanyouArray;
@property (strong,nonatomic) NSMutableArray * hengshengArray;
@property (assign,nonatomic) int shouxufei; //手续费
@property (strong,nonatomic) UIButton* diancha;//止盈止损
@property (strong,nonatomic) NSString* dianchaString;//止盈止损大小(参数传给后台)

@end
@implementation RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];//初始化数据
    [self initControls];//初始化控件
    [self initNavigationBar];//初始化导航栏
    [self createRootScrollView];//创建根视图
    [self createSettingView];//创建设置视图
    [self getDataFromWebForPosi];//在仓数据的请求
    [self getCurrentTotalPositionVolume:0];//获取当前选中商品的总持仓手数
    [self netStatus];//检测网络状态
    [self createSocket];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createSocket) name:@"socket" object:nil];//从登录界面返回，开启socket连接
    NSInteger balance = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"][@"DouBiWeiPan"] integerValue];
    [[NSUserDefaults standardUserDefaults]setInteger:balance forKey:@"yue"];
}
#pragma mark ****** socket连接
-(void)createSocket{
    _asyncSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error=nil;
    if (![_asyncSocket connectToHost:_IP_ADDRESS onPort:_SERVER_PORT error:&error]) {
        NSLog(@"Error==:%@",error);}
}
#pragma mark ****** asyncSocket代理方法
//建立连接
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"onScoket:%p did connecte to host:%@ on port:%d",sock,host,port);
    [sock readDataWithTimeout:60 tag:10];
}
//读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *aStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",aStr);
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
    NSString* name = _bhDic[_bhList[j][@"Name"]][@"Bh"];
    //拆分字符串成数组
    NSArray*  array = [aStr componentsSeparatedByString:@","];
    NSMutableArray* arr = [NSMutableArray arrayWithArray:array];
    if (![array[2] isEqualToString:@"CHECK"]) {
        if ([array[0] isEqualToString:@"Data"]) {
            for (int i=0; i<_bhList.count; i++) {
                if ([arr[2] isEqualToString:_bhDic[_bhList[i][@"Name"]][@"Bh"]]) {//和货币中文名称一样
                    _newlastArray = arr;
                }
            }
            if ([name isEqualToString:array[2]]) {
                _asyncSocketArray = arr;
                [self updateLightningViewUI:array];//更新闪电图
            }
            if ([array[1] isEqualToString:@"CloseOrders"]){//强平
                if ([array[2] isEqualToString:_loginAccount]) {
                    [self showAlert:@"关仓"];
                    [self getDataFromWebForPosi];
                    NSInteger balance = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"][@"DouBiWeiPan"] integerValue];
                    balance = balance + [array[5] integerValue] - [array[4] integerValue];
                    [[NSUserDefaults standardUserDefaults]setInteger:balance forKey:@"yue"];
                }
            }else if ([array[1] isEqualToString:@"Change"]){//不同客户端登陆
                if ([array[2] isEqualToString:_loginAccount]) {
                    NSString* DriverID = [[NSUserDefaults standardUserDefaults] objectForKey:@"DRIVERID"];
                    if (![array[3] isEqualToString:DriverID]) {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
                        [self alertWithTitle:@"其他客户端登录..." cancelButtonTitle:@"确定" otherButtonTitle:nil];
                    }
                }
                [self getDataFromWebForPosi];
            }
        }
    }
    

    NSData *aData=[@"Hi" dataUsingEncoding:NSUTF8StringEncoding];
    //给服务器发送信息
    [sock writeData:aData withTimeout:-1 tag:10];
    //读取信息
    [sock readDataWithTimeout:60 tag:tag];
    [self updateCurrentPriceAndProfits:YES];
}
//断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%@",err.localizedDescription);
    NSString* error = [NSString stringWithFormat:@"%@",err.localizedDescription];
    if ([error isEqualToString:@"Network is unreachable"]) {
        return;
    }
    if (err == NULL) {return;}
    else{ //如果不是返回断开链接  就重新链接
        [self showAlert:@"数据连接中断"];
        [_asyncSocket connectToHost:_IP_ADDRESS onPort:_SERVER_PORT error:nil];
    }
}

#pragma mark button不能点击
- (void)buttonNotTouch{
    _bullishBtn.enabled = _bearishBtn.enabled = _allSellButton.enabled = NO;
    [_bullishBtn setTitleColor:[UIColor colorWithRed:252/255.0 green:108/255.0 blue:87/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_bearishBtn setTitleColor:[UIColor colorWithRed:63/255.0 green:140/255.0 blue:226/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_allSellButton setTitleColor:[UIColor colorWithRed:185/255.0 green:153/255.0 blue:106/255.0 alpha:1.0] forState:UIControlStateNormal];
}
#pragma mark button可以点击
- (void)buttonCanTouch{
    _bullishBtn.enabled = _bearishBtn.enabled = _allSellButton.enabled = YES;
    [_bullishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bearishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allSellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
#pragma mark 检测网络状态
-(void)netStatus{
    //检测手机运行的是什么网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status==AFNetworkReachabilityStatusNotReachable){
            [_asyncSocket disconnect];
            [self alertWithTitle:@"请求超时,请检查网络连接" cancelButtonTitle:@"关闭" otherButtonTitle:nil];
        }else if(status== AFNetworkReachabilityStatusReachableViaWiFi){
             [_asyncSocket connectToHost:_IP_ADDRESS onPort:_SERVER_PORT error:nil];
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
        }else if (status==AFNetworkReachabilityStatusReachableViaWWAN){
             [_asyncSocket connectToHost:_IP_ADDRESS onPort:_SERVER_PORT error:nil];
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
    [self getHBWorkTime];//获取商品交易时间
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
//    _shouxufei = [_bhList[0][@"State"] intValue];
    _bhList = [[NSUserDefaults standardUserDefaults] objectForKey:@"BHList"];//获取商品列表
    /*
     [
         {
             "Name": "美原油",
             "Bh": "CLF6",
             "Increment": 0.01,
             "USD": 20,
             "Converts": 100,
             "Price": 0,
             "ASKPrice": 0,
             "RMB": 25
         },
         {
             "Name": "恒生指数",
             "Bh": "HKZ5",
             "Increment": 1,
             "USD": 20,
             "Converts": 1,
             "Price": 0,
             "ASKPrice": 0,
             "RMB": 25
         }
     ]
     */
    _bhDic = [NSMutableDictionary dictionary];//商品字典
    _nameDic = [NSMutableDictionary dictionary];//商品中文名字典
    /*
     {
         "恒生指数" = {
             Bh = HKZ5;
             NewestPrice = 0;
             SinglePrice = 2000;
             DecimalPoint = 1
         };
         "美原油" = {
             Bh = CLF6;
             NewestPrice = 0;
             SinglePrice = 13;
             DecimalPoint = 0.01
         };
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"root_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(settingBtnClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"root_user"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(userCenterBtnClick:)];
}
#pragma mark 创建持仓请求数据
- (void)getDataFromWebForPosi{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1234567890",@"DriverID",@"1111",@"UserID",@"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"InOrderList",@"DataType",_loginAccount,@"LoginID", nil];
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
            NSMutableArray* array = [[NSMutableArray alloc]init];
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
                if ([_nameLab.currentTitle isEqualToString:_nameDic[dic[@"Symbol"]]]) {
                    [array insertObject:model atIndex:0];
                }
            }
            [_tableView reloadData];

            if (array.count == 0) {
                _duoOrKongLabel.text = @"   ";
                _numberLabel.text = _shouyiLabel.text = @"0";
                 [self updateWidthOfVolume:_numberLabel.text];
            }else{
                long pri = 0;
                int vol = 0;
                 for (holdPositionModel* model in array) {
                     pri += [model.Profit longValue];//累加盈亏
                     vol += [model.Volume intValue];//累加总手数
                     for (NSDictionary *dic in jsonDic) {
                        //刷新手数
                        if (model.buyLessOrMore != nil) {
                            if ([_nameLab.currentTitle isEqualToString:_nameDic[dic[@"Symbol"]]]) {
//                                _duoOrKongLabel.text = [NSString stringWithFormat:@"看%@",model.buyLessOrMore];
                                UIFont *font = _duoOrKongLabel.font = [UIFont systemFontOfSize:18.0f];
                                CGSize size1 = [_duoOrKongLabel.text boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil].size;
                                _duoOrKongLabel.frame = CGRectMake(0.094*WIDTH, CGRectGetMaxY(_bullishBtn.frame)+10, size1.width, _duoOrKongLabel.frame.size.height);
                                _numberLabel.text = [NSString stringWithFormat:@"%d",vol];
                                [self updateWidthOfVolume:_numberLabel.text];
                                
                                _shouyiLabel.text = [NSString stringWithFormat:@"%ld",pri];
                                _shouyiLabel.textColor = (pri < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
                                _$.frame = CGRectMake(WIDTH-40, _duoOrKongLabel.frame.origin.y+7, 15, 10);
                                CGSize $size = [_shouyiLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:22.0] forKey:NSFontAttributeName]];
                                _shouyiLabel.frame = CGRectMake(_$.frame.origin.x-$size.width, _duoOrKongLabel.frame.origin.y-5, $size.width, $size.height);
                                _yingkui.frame = CGRectMake(_shouyiLabel.frame.origin.x-_yingkui.bounds.size.width, _shouyiLabel.frame.origin.y, _yingkui.bounds.size.width, _shouyiLabel.bounds.size.height);
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
    _rootView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_rootView];
    [self createBuyView];//创建买入页面
    [self createPositionView];//买入后持仓页面
    [self creataPositionTableView];////买入后持仓列表
}
#pragma mark 创建设置视图
- (void)createSettingView{
    //------ 设置视图 ------
    _settingView = [[SettingView alloc]initWithFrame:CGRectMake(0, -HEIGHT, WIDTH, HEIGHT)];
    [_settingView setBackgroundColor:[UIColor blackColor]];
    [self.view insertSubview:_settingView aboveSubview:_rootView];
    //------ 设置视图_滚动视图 ------
    _picView = [[UIPickerView alloc]initWithFrame:CGRectMake(WIDTH*0.25, _settingView.bounds.size.height*0.5-150, WIDTH*0.5, 200)];
    [_picView setDelegate:self];
    [_picView setDataSource:self];
    [_picView setShowsSelectionIndicator:YES];
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
    [_picView selectRow:0 inComponent:j animated:YES];
    [_settingView addSubview:_picView];
    //------ 操作成功弹窗 ------
    UIView *successView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH*0.5-90, CGRectGetMaxY(_picView.frame)+5, 180, 31)];
    [_settingView addSubview:successView];
    UILabel *successTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5.5, 120, 20)];
    successTitle.text = @"操作成功弹窗";
    successTitle.font = [UIFont systemFontOfSize:20.0];
    successTitle.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [successView addSubview:successTitle];
    UISwitch* swit =[[UISwitch alloc]initWithFrame:CGRectMake(successView.bounds.size.width-51, 0, 51, 31)];
    [swit setOn:YES];
    [swit addTarget:self action:@selector(showAlartView:) forControlEvents:UIControlEventValueChanged];
    [successView addSubview:swit];
}
#pragma mark 操作成功弹窗开关
- (void)showAlartView:(UISwitch *)sender{  _isShowAlertView = sender.on;}
#pragma mark 创建买入视图
- (void)createBuyView{
    //------ 商品名 ------
    _nameLab = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _nameLab.frame = CGRectMake(WIDTH/2.0-100, 15, 200, (HEIGHT-60)*0.045);
    [_nameLab setTitle:@"恒生指数" forState:UIControlStateNormal];
    _nameLab.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    _nameLab.tintColor = [UIColor whiteColor];
    [_nameLab addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:_nameLab];
    //------ 委托手数 ------
    NSString *str1 = @"1";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"委托 %@ 手",str1]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,2)];
    [str addAttribute:NSForegroundColorAttributeName value:GLODENCOLOR range:NSMakeRange(3,str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(4+str1.length,1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, 2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(3, str1.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(4+str1.length, 1)];
    _delegateNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameLab.frame)+5, WIDTH, (HEIGHT-60)* 0.033)];
    _delegateNumberLabel.attributedText = str;
    _delegateNumberLabel.textAlignment = NSTextAlignmentCenter;
    [self.rootView addSubview:_delegateNumberLabel];
    //------ 最新价(price) ------
    _newestPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2 - 70, CGRectGetMaxY(_delegateNumberLabel.frame)+7.5, 140, 36)];
    _newestPriceLabel.textColor = GLODENCOLOR;
    _newestPriceLabel.text = @"0.00";
    _newestPriceLabel.textAlignment = NSTextAlignmentCenter;
    _newestPriceLabel.font = [UIFont systemFontOfSize:36.0];
    [self.rootView addSubview:_newestPriceLabel];
    
    _diancha = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _diancha.frame = CGRectMake(WIDTH - 140, _newestPriceLabel.frame.origin.y, 120, 36);
    [_diancha setTitle:@"止盈:5" forState:UIControlStateNormal];
    _diancha.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_diancha setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_diancha addTarget:self action:@selector(chooseDianCha) forControlEvents:UIControlEventTouchUpInside];
    [self.rootView addSubview:_diancha];
    _dianchaString = @"5";
    //------ 闪电图按钮 ------
    UIButton* lightningBtn = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH-WIDTH*0.3)/2, CGRectGetMaxY(_newestPriceLabel.frame)+16, WIDTH* 0.3, (HEIGHT-60)* 0.04)];
    [lightningBtn setTitle:@"闪电图" forState:UIControlStateNormal];
    lightningBtn.selected = YES;
    lightningBtn.titleLabel.font=[UIFont systemFontOfSize:12.0];
    [lightningBtn setTitleColor:GLODENCOLOR forState:UIControlStateSelected];
    lightningBtn.tag = 1;
    [self.rootView addSubview:lightningBtn];
    //------ 闪电图按钮线 ------
    _buttonLine1=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lightningBtn.frame)-WIDTH*0.3, CGRectGetMaxY(lightningBtn.frame)-2, WIDTH* 0.3, 2)];
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
    //------ 全部清仓按钮 ------
    _allSellButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _allSellButton.frame = CGRectMake(17+buttonWidth, _bullishBtn.frame.origin.y, buttonWidth, 44);
    [_allSellButton setTitle:@"全部清仓" forState:UIControlStateNormal];
    [_allSellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _allSellButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    _allSellButton.layer.cornerRadius = 10.0;
    _allSellButton.layer.masksToBounds = YES;
    _allSellButton.backgroundColor = GLODENCOLOR;
    [_allSellButton addTarget:self action:@selector(allSellbuttonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.rootView addSubview:_allSellButton];
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
    _duoOrKongLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.094*WIDTH, CGRectGetMaxY(_bullishBtn.frame)+10, 70, 18)];
    _duoOrKongLabel.text = @"看多/空";
    _duoOrKongLabel.numberOfLines = 0;
    _duoOrKongLabel.textColor = [UIColor colorWithRed:0.95 green:0.78 blue:0.52 alpha:1];
//    [self.rootView addSubview:_duoOrKongLabel];
    //------ 主界面提示买入多少手label ------
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_duoOrKongLabel.frame), _duoOrKongLabel.frame.origin.y, 20, 18)];
    _numberLabel.text = @"0";
    _numberLabel.font = [UIFont systemFontOfSize:18.0f];
    _numberLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.82 alpha:1];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    [self.rootView addSubview:_numberLabel];
    //------ "手"的Label ------
    _shou = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_numberLabel.frame), _numberLabel.frame.origin.y+5, 12, 10)];
    _shou.text = @"手";
    _shou.font = [UIFont systemFontOfSize:12.0f];
    _shou.textColor = [UIColor grayColor];
    [self.rootView addSubview:_shou];
    //------ 买入界面"盈亏"的label ------
    _yingkui = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2+30, _duoOrKongLabel.frame.origin.y, 40, 15)];
    _yingkui.text = @"盈亏";
    _yingkui.textColor = [UIColor colorWithRed:0.95 green:0.78 blue:0.52 alpha:1];
    [self.rootView addSubview:_yingkui];
    //------ 盈亏数label ------
    _shouyiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_yingkui.frame), _duoOrKongLabel.frame.origin.y, 12, 17)];
    _shouyiLabel.text = @"+0";
    _shouyiLabel.numberOfLines = 0;
    _shouyiLabel.font = [UIFont systemFontOfSize:22.0f];
    [self.rootView addSubview:_shouyiLabel];
    //------ "$"的label ------
     _$ = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_shouyiLabel.frame), _shouyiLabel.frame.origin.y, 15, 10)];
    _$.font = [UIFont systemFontOfSize:12.0f];
    _$.text = @"$";
    _$.textColor = [UIColor grayColor];
    [self.rootView addSubview:_$ ];
}
#pragma mark ****** 选择点差
-(void)chooseDianCha{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1234567890",@"DriverID",@"",@"UserID",@"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"QPDSXF",@"DataType", nil];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"选择止盈止损" preferredStyle:UIAlertControllerStyleAlert];
    [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error != NULL) {
            [self alertWithTitle:error.localizedDescription cancelButtonTitle:@"确定" otherButtonTitle:nil];
        }
         NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
         NSData* data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        for (int i=0; i < dataArray.count; i++) {
            NSString *Point = [NSString stringWithFormat:@"止盈:%@,手续费:%@",dataArray[i][@"Point"],dataArray[i][@"Commission"]];
            NSString* num = [NSString stringWithFormat:@"止盈:%@",dataArray[i][@"Point"]];
            UIAlertAction *laterAction = [UIAlertAction actionWithTitle:Point style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 普通按键
                [_diancha setTitle:[NSString stringWithFormat:@"%@",num] forState:UIControlStateNormal];
                _dianchaString = dataArray[i][@"Point"];
            }];
            [alert addAction:laterAction];
        }
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:laterAction];
    }];
   [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark 创建闪电图
- (void)createLightningView{
    //请求的历史历史行情数字
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"BFEBFBFF000306C3F0:79:59:E0:0F:D2",@"DriverID",TASKGUID,@"TaskGuid",@"",@"UserID",@"MT4DataHistory",@"DataType",@"300",@"Top",_bhList[j][@"Bh"],@"Type",nil];
    [_webRequest webRequestWithDataDic:parameters requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {[self alertWithTitle:@"请求失败" cancelButtonTitle:@"关闭" otherButtonTitle:nil];}else{
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            //------ 判断是否有数据返回，如果有则加载UI ------
            if (![resultString hasPrefix:@"[{\"DtTime\""]) {
                [self alertWithTitle:@"没有历史行情数据,请稍后再试..." cancelButtonTitle:@"关闭" otherButtonTitle:nil];
                _bullishBtn.enabled = _bearishBtn.enabled = NO;
                [_bullishBtn setTitleColor:[UIColor colorWithRed:252/255.0 green:108/255.0 blue:87/255.0 alpha:1.0] forState:UIControlStateNormal];
                [_bearishBtn setTitleColor:[UIColor colorWithRed:63/255.0 green:140/255.0 blue:226/255.0 alpha:1.0] forState:UIControlStateNormal];
                _lightningView = [[LightningView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_buttonLine1.frame), WIDTH, (HEIGHT-60)*0.44)];
                _lightningView.backgroundColor = [UIColor clearColor];
                [self.rootView addSubview:_lightningView];
            }else{
                NSData *eleData = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:eleData options:NSJSONReadingMutableContainers error:nil];
                NSMutableArray *dataArray = [NSMutableArray array];
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
                if ([self isInWorkTime:j]) {
                    //刷新最新价
                    _priceForLightningView = [[dataArray objectAtIndex:3] floatValue];
                    _lightningView.priceLabel.text = [dataArray objectAtIndex:3];
                    //刷新看多买入价格
                    _newestPriceLabel.text = _bearishBtnLabel.text = [dataArray objectAtIndex:3];
                    //刷新看空买入价格
                    _bullishBtnLabel.text = [dataArray objectAtIndex:4];
                }else{
                    _newestPriceLabel.text = _bullishBtnLabel.text = _bearishBtnLabel.text = @"0.00";
                }
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
    int i=[[[NSUserDefaults standardUserDefaults]objectForKey:@"xuanzexiangmu"] intValue];
    NSString* name = _bhDic[_bhList[i][@"Name"]][@"Bh"];
    _lightningStepper++;
    if (_lightningStepper%60==0) {//1秒一次
        [self updateCurrentPriceAndProfits:NO];//刷新最新盈亏数和行情价格
        if (_lastArray[3] == _asyncSocketArray[3]) {
            [self updateLightningViewUI:_asyncSocketArray];//更新闪电图UI
        }else if(_asyncSocketArray != NULL)
            if ([name isEqualToString:_asyncSocketArray[2]]) {
                _lastArray = _asyncSocketArray;
            }
        [self ThreeTimeLabelLeftMove];//刷新闪电图下面显示的3个时间label
    }
    if (_lightningStepper%1200==0) {//20秒一次
        [self getDataFromWebForPosi];//同步在仓订单
    }
}
#pragma mark 刷新闪电图下面显示的3个时间label
- (void)ThreeTimeLabelLeftMove{
    for (int i = 30; i<=32; i++) {
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
                            profit = ([holdPosition.ClosePrice doubleValue] - [holdPosition.OpenPrice doubleValue])*[_bhDic[_bhList[i][@"Name"]][@"SinglePrice"] doubleValue]*[holdPosition.Volume intValue];
                        }else{//看空盈利: (开仓价格-关仓价格)*单价*手数
                            if ( [_bhList[i][@"Bh"] isEqualToString:_newlastArray[2]]) {
                                holdPosition.ClosePrice = (NSNumber *)_newlastArray[4];
                                if ([_newlastArray[3] floatValue] <= [holdPosition.TakeProfit floatValue] || [_newlastArray[3] floatValue] >= [holdPosition.StopLoss floatValue]) {
                                    [array addObject:holdPosition];
                                }
                            }
                            profit = ([holdPosition.OpenPrice doubleValue] - [holdPosition.ClosePrice doubleValue])*[_bhDic[_bhList[i][@"Name"]][@"SinglePrice"] doubleValue]*[holdPosition.Volume intValue];
                        }
                    }
                }
                holdPosition.Profit = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%.0f",profit] integerValue]];
                prices+=profit;
            }

        /**
         主界面盈利刷新，只显示本货币的盈利多少
         */
        double pric = 0;//当前总盈亏
        int nums = 0;
        for (int i=0; i<_bhList.count; i++) {
            if ([_nameLab.currentTitle isEqualToString:_bhList[i][@"Name"]]) {
                if ([_newlastArray[2] isEqualToString:_bhList[i][@"Bh"]]) {
                        for (holdPositionModel *holdPosition in _tableViewDataArray) {
                            double profit = 0;
                            int num = 0;
                            if ([holdPosition.name isEqualToString:_bhList[i][@"Name"]]) {
                                profit = [holdPosition.Profit doubleValue];
                                num = [holdPosition.Volume intValue];
                                pric+=profit;
                                nums += num;
                            }
                        }
                    _numberLabel.text = [NSString stringWithFormat:@"%d",nums];
                    _shouyiLabel.text = [NSString stringWithFormat:@"%.0f",pric];
                    _shouyiLabel.textColor = (pric < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
                }
            }
        }
        [_tableViewDataArray removeObjectsInArray:array];
        [_tableView reloadData];
        
        _yuanLabel.text = [NSString stringWithFormat:@"%.0f",prices];
        _yuanLabel.textColor = (prices < 0 ? [UIColor greenColor] : [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1]);
        NSString *str = _yuanLabel.text = [NSString stringWithFormat:@"%.0f",prices];
        CGSize priceSize = [str boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:30.0] forKey:NSFontAttributeName] context:nil].size;
        _yuanLabel.frame = CGRectMake(WIDTH+20, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.026, priceSize.width, 30);
        _yuantextLabel.frame = CGRectMake(CGRectGetMaxX(_yuanLabel.frame)+5, CGRectGetMaxY(_balanceLabel.frame)+HEIGHT*0.0264+4, WIDTH*0.09, HEIGHT*0.044);
        
        _$.frame = CGRectMake(WIDTH-40, _duoOrKongLabel.frame.origin.y+5, 15, 12);
        CGSize $size = [_shouyiLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:22.0] forKey:NSFontAttributeName]];
        _shouyiLabel.frame = CGRectMake(_$.frame.origin.x-$size.width, _duoOrKongLabel.frame.origin.y-5, $size.width, $size.height);
        _yingkui.frame = CGRectMake(_shouyiLabel.frame.origin.x-_yingkui.bounds.size.width, _shouyiLabel.frame.origin.y, _yingkui.bounds.size.width, _shouyiLabel.bounds.size.height);
        [_tableView reloadData];
    }else{
        _shouyiLabel.text = @"0";
    }
}
#pragma mark 获取商品交易时间
- (void)getHBWorkTime{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1234",@"UserID",@"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"HBWorkTime",@"DataType",nil];
    [_webRequest webRequestWithDataDic:dic requestType:kRequestTypeGetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error != nil) {
            NSLog(@"获取商品交易时间请求失败");
        }else{
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *workTimeArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSUserDefaults *CloseTimeDefaults = [NSUserDefaults standardUserDefaults];
            [CloseTimeDefaults setObject:workTimeArray forKey:@"HBWorkTime"];
        }
    }];
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
            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
            _inTime = [self isInWorkTime:i];
            if (_inTime == YES) {
                if (sender.tag == 100001) {
                    if ([sender.titleLabel.text isEqualToString:BUYMORE] || [sender.titleLabel.text isEqualToString:BUYONCE]){
                        [self buy:@"多"];
                    }else{
                        [self reversePosition:@"多"];
                    }
                }else if (sender.tag == 100002){
                    if ([sender.titleLabel.text isEqualToString:BUYLESS] || [sender.titleLabel.text isEqualToString:BUYONCE]){
                        [self buy:@"空"];
                    }else{
                        [self reversePosition:@"空"];
                    }
                }
            }else{
                [self alertWithTitle:@"不在交易时间" cancelButtonTitle:@"确定" otherButtonTitle:nil];
            }
    }
}
#pragma mark 根据选择项目判断是否在交易时间
- (BOOL)isInWorkTime:(int)index{
    NSArray *HBWorkTimeArray = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"HBWorkTime"];
    BOOL inTime = YES;
    [self getSystemTime];
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
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    _currentDate = [formatter stringFromDate:date];
    _currentTimeStamp = (long)[date timeIntervalSince1970];
}
#pragma mark 看多(看空)的买入/追单
- (void)buy:(NSString *)bullishOrBearish{
    int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"jiaoyishuliang"] intValue];
//    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDic"];
//    NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Volume",@"",@"Guid",@"b4026263-704e-4e12-a64d-f79cb42962cc",@"TaskGuid",@"Sys_Volume",@"DataType",[NSNumber numberWithInt:0],@"Seconds",[NSNumber numberWithInt:0],@"Stoploss",[NSNumber numberWithInt:0],@"Takeprofit",[NSNumber numberWithBool:YES],@"SysUser",userDic[@"LoginAccount"],@"Version", nil];
//    WebRequest *web = [[WebRequest alloc] init];
//    [web webRequestWithDataDic:dic1 requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        NSString *resultStr = [self getResultStringFromOperation:(NSData *)responseObject];
//        NSData *jsonData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//        [[NSUserDefaults standardUserDefaults] setObject:jsonObject[0][@"Volume"] forKey:@"maxVolume"];
        //获取单个货币的最大持仓手数
//        int maxVolume = [jsonObject[0][@"Volume"] intValue];
//        if (i + _positionVolume >= maxVolume) {
//            [self showAlert:@"超出交易手数"];
//            [self buttonCanTouch];
//            return;
//        }
        _alertStr = [NSString stringWithFormat:@"您已成功看%@买入%@，请进入订单查看相关信息！",bullishOrBearish,_volumeArray[i]];
        [self BuyRequestData:bullishOrBearish];
//    }];
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
    NSMutableDictionary* parmars = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
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
    [_webRequest webRequestWithDataDic:parmars requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            if (![resultString hasPrefix:@"{\"ClosePrice\""]) {
                [self alertWithTitle:resultString cancelButtonTitle:@"确定" otherButtonTitle:nil];
            }else{
//                _positionVolume += [volume intValue];
                [self getDataFromWebForPosi];
                if (_isShowAlertView) {
                    [self showAlert:@"买入成功"];  }
            }
        [self buttonCanTouch];
        [_activity stopAnimating];
    }];
}
#pragma mark 反向开仓
- (void)reversePosition:(NSString *)bullishOrBearish{
    NSMutableArray *arr = [NSMutableArray array];
    NSInteger totalVolum=0;
    [_activity startAnimating];//菊花开始转
    [self buttonNotTouch];//设置button不能被电击
    int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];//现在选择的商品
    for (holdPositionModel* model in _tableViewDataArray) {
        if ([model.name isEqualToString:_nameDic[_bhList[j][@"Bh"]]]) {//如果持仓界面和现在选择的商品名称相同，则统计订单编号
            [arr addObject:[NSString stringWithFormat:@"%@", model.OrderNumber]];
            totalVolum = totalVolum+[model.Volume intValue];//统计手数
        }
    }
    NSString *orderNumbers = [arr componentsJoinedByString:@","];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_iPhoneID,@"DriverID",_iPhoneIP,@"Ip",TASKGUID,@"TaskGuid",_loginAccount,@"LoginAccount",@"CloseOrderS",@"DataType",orderNumbers,@"OrderNumberS",nil];
    [_webRequest webRequestWithDataDic:dataDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {
            [self alertWithTitle:[NSString stringWithFormat:@"%@",error] cancelButtonTitle:@"确定" otherButtonTitle:nil];
        }else{
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            if ([resultString isEqualToString:@"True"]) {//如果卖出成功
                NSMutableArray* arrayCount = [NSMutableArray array];//设置一个array添加要删除的商品
                for (int a = 0; a<_tableViewDataArray.count; a++) {
                    holdPositionModel* model = (holdPositionModel*)_tableViewDataArray[a];
                    if ([model.name isEqualToString:_nameDic[_bhList[j][@"Bh"]]]) {
                        [arrayCount addObject:_tableViewDataArray[a]];//添加要删除的元素到array
                    }
                }
                [_tableViewDataArray removeObjectsInArray:arrayCount];//删除要删除的元素数组
                [_tableView reloadData];
                NSNumber *totalVolume = [NSNumber numberWithInteger:totalVolum];//总手数
                NSString *dataType = nil;
                if ([bullishOrBearish isEqualToString:@"多"]) {
                    dataType = @"OpenBuy-New";
                }else if ([bullishOrBearish isEqualToString:@"空"]){
                    dataType = @"OpenSell-New";
                }
                _userDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_iPhoneID,@"DriverID",_iPhoneIP,@"Ip",@"任务标识",@"UserID",TASKGUID,@"TaskGuid",dataType,@"DataType",_loginAccount,@"LoginAccount",_bhList[j][@"Bh"],@"Symbol",totalVolume,@"Volume",@"0",@"StopLoss",@"0",@"TakeProfit",@"iPhone",@"Comment", nil];
                [_webRequest webRequestWithDataDic:_userDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                    if (error!=nil) {  [self alertWithTitle:[NSString stringWithFormat:@"%@",error] cancelButtonTitle:@"确定" otherButtonTitle:nil]; }else{
                        NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
                        if (![resultString hasPrefix:@"{\"Comment\""]) {//判断买入成功是否有数据返回
                            [self alertWithTitle:resultString cancelButtonTitle:@"确定" otherButtonTitle:nil];
                        }else{
                            [self getDataFromWebForPosi];
                            if (_isShowAlertView)
                                [self showAlert:@"反向开仓成功"];
                        }
                    }
                    [_activity stopAnimating];
                    [self buttonCanTouch];//button可以被点击
                }];
            }else{  [self alertWithTitle:resultString cancelButtonTitle:@"确定" otherButtonTitle:nil]; }
        }
        [self buttonCanTouch];
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
#pragma mark 全部清仓点击事件
-(void)allSellbuttonClick{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (!login) {//登录前
        [self alertWithTitle:@"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
    }else{
        if (_tableViewDataArray.count>0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否全部清仓？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:cancelAction];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//点击进行全部清仓
                [_activity startAnimating];
                NSMutableArray *arr = [NSMutableArray array];
                NSMutableArray* dingdanArray = [NSMutableArray array];
                int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];//现在选择的商品
                for (holdPositionModel* model in _tableViewDataArray) {
                    if ([model.name isEqualToString:_nameDic[_bhList[j][@"Bh"]]]) {//如果持仓界面和现在选择的商品名称相同，则统计订单编号
                        [arr addObject:[NSString stringWithFormat:@"%@", model.OrderNumber]];
                        [dingdanArray addObject:model];
                    }
                }
                if (dingdanArray.count == 0) {
                    [self showAlert:@"没有在仓订单"];
                    return ;
                }
                NSString *orderNumbers = [arr componentsJoinedByString:@","];
                NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_iPhoneID,@"DriverID",_iPhoneIP,@"Ip",TASKGUID,@"TaskGuid",_loginAccount,@"LoginAccount",@"CloseOrderS",@"DataType",orderNumbers,@"OrderNumberS",nil];
                [_webRequest webRequestWithDataDic:dataDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                    if (error!=nil) {    }else{
                        [_tableViewDataArray removeObjectsInArray:dingdanArray];
                        [_tableView reloadData];
                        NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
                        if ([resultString isEqualToString:@"True"]) {
//                            _positionVolume = 0;
                            _numberLabel.text = @"0";
                            _duoOrKongLabel.text = @"";
                            _shouyiLabel.text = @"0";
                            [self updateWidthOfVolume:_numberLabel.text];
                            [_bearishBtn setTitle:BUYLESS forState:UIControlStateNormal];
                            [_bullishBtn setTitle:BUYMORE forState:UIControlStateNormal];
                            if (_isShowAlertView) {
                                [self showAlert:@"清仓成功"];
                            }
                        }else{
                            [self alertWithTitle:@"全部清仓失败" cancelButtonTitle:@"关闭" otherButtonTitle:nil];
                        }
                    }
                    [_activity stopAnimating];
                }];
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            [self alertWithTitle:@"操作失败，请确认您已有订单" cancelButtonTitle:@"确定" otherButtonTitle:nil];
        }
    }
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
    if (cell==nil) {
        cell = [[RootTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell.buyMoreOrLess setTextColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.sellButton.tag = indexPath.row;
    [cell.sellButton addTarget:self action:@selector(sellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell config:_tableViewDataArray[indexPath.row]];
    return cell;
}
#pragma mark 单笔清仓
- (void)sellButtonClick:(UIButton *)sender{
    sender.enabled = NO;
    [sender setTitleColor:[UIColor colorWithRed:199/255.0 green:166/255.0 blue:114/255.0 alpha:1.0] forState:UIControlStateNormal];
    RootTableViewCell *cell = (RootTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_iPhoneID,@"DriverID",_iPhoneIP,@"Ip",TASKGUID,@"TaskGuid",_loginAccount,@"LoginAccount",@"CloseOrder",@"DataType",cell.OrderNumber,@"OrderNumber",cell.Volume,@"Volume",nil];
    [_webRequest webRequestWithDataDic:dataDic requestType:kRequestTypeSetData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error!=nil) {        }else{
            NSString *resultString = [self getResultStringFromOperation:(NSData *)responseObject];
            if ([resultString isEqualToString:@"True"]) {
//                _positionVolume -=[cell.Volume intValue];
                if (_isShowAlertView) {
                     [self showAlert:@"平仓成功"];
                }
                int j = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
                int num = 0;
                for (holdPositionModel* model in _tableViewDataArray) {
                    if ([model.name isEqualToString:_nameDic[_bhList[j][@"Bh"]]]) {
                        num++;//查找持仓界面有多少个被选择的商品项目
                    }
                }
                num--;
                if (num== 0) {//如果已经没有这个持仓，则主界面按钮变成看多、看空
                    [_bullishBtn setTitle:BUYMORE forState:UIControlStateNormal];
                    [_bearishBtn setTitle:BUYLESS forState:UIControlStateNormal];
                    [_duoOrKongLabel setText:@""];
                    CGRect rect = _numberLabel.frame;
                    rect.size.width = 10;
                    _numberLabel.frame = rect;
                }
                _numberLabel.text = [NSString stringWithFormat:@"%d",([_numberLabel.text intValue] - [cell.Volume intValue])];
                [self updateWidthOfVolume:_numberLabel.text];
                [_tableViewDataArray removeObjectAtIndex:sender.tag];
                [_tableView reloadData];
            } else {
                [self alertWithTitle:@"平仓失败" cancelButtonTitle:@"关闭" otherButtonTitle:nil];
            }
        }
        sender.enabled = YES;
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }];
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
- (void)settingBtnClick{
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"guanbi_"];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    if (_isOut == NO) {
        _isOut = !_isOut;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = _settingView.frame;
            rect.origin.y = _isOut ?  0 : -HEIGHT;
            _settingView.frame = rect;
        }];
    }else {
        _isOut = !_isOut;
        int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"xuanzexiangmu"] intValue];
        [_nameLab setTitle:_bhList[i][@"Name"] forState:UIControlStateNormal];
        [self getDataFromWebForPosi];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = _settingView.frame;
            rect.origin.y = _isOut ?  0 : -HEIGHT;
            _settingView.frame = rect;
        }];
        //------ 上一次商品的选择 ------
        NSInteger lasti = [[[NSUserDefaults standardUserDefaults]valueForKey:@"lastChoose"] integerValue];
        if (_lastChoose != lasti) {
            _lastChoose = lasti;
//            _positionVolume = 0;
           [_lightningView removeFromSuperview];//删除原闪电图
            _newestPriceLabel.text = @"0.00";
            if ([self isInWorkTime:i]) {
                [self createLightningView];//创建新的闪电图
                [self getCurrentTotalPositionVolume:i];
            }else{
                [self createLightningView];//创建新的闪电图
                [self showAlert:@"不在交易时间"];
            }
        }
        
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"root_setting"];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
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
        [self getDataFromHold];//根据所选择的商品的看多看空，刷新按钮
    }
}
#pragma mark 取出持仓里面的商品类型，改变买多买空的按钮 名字
- (void)getDataFromHold{
    int i =[[[NSUserDefaults standardUserDefaults]objectForKey:@"xuanzexiangmu"] intValue];
    for (holdPositionModel*model in _tableViewDataArray) {
        if ([model.name isEqualToString:_nameDic[_bhList[i][@"Bh"]]]) {
            if ([model.buyLessOrMore isEqualToString:@"多"]) {
                [_bearishBtn setTitle:ReversePosition forState:UIControlStateNormal];
                [_bullishBtn setTitle:BUYONCE forState:UIControlStateNormal];
            }else if ([model.buyLessOrMore isEqualToString:@"空"]){
                [_bearishBtn setTitle:BUYONCE forState:UIControlStateNormal];
                [_bullishBtn setTitle:ReversePosition forState:UIControlStateNormal];
            }
            break;
        }else {
            [_bearishBtn setTitle:BUYLESS forState:UIControlStateNormal];
            [_bullishBtn setTitle:BUYMORE forState:UIControlStateNormal];
        }
    }
}
#pragma mark 个人中心按钮点击事件
- (void)userCenterBtnClick:(UIBarButtonItem *)sender{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (!login) {
        [self alertWithTitle:@"请先登录" cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
    }else{
//        [_asyncSocket disconnect];
        UserCenterViewController *userVc = [[UserCenterViewController alloc]init];
//        [userVc setReturnRootViewBlock:^{
//            [self createSocket];
//            [self getDataFromWebForPosi];
//        }];
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
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{return 2;}
#pragma mark 返回每列行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0 == component ? _bhList.count : _volumeArray.count;
}
#pragma mark 把选中行的标题放入用户配置
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = (0 == component ? @"xuanzexiangmu" : @"jiaoyishuliang");
    [user setObject:[NSNumber numberWithInteger:row] forKey:keyStr];
    if (component == 0) {
        [user setInteger:row forKey:@"lastChoose"];
    }
    [user synchronize];
}
#pragma mark 自定义每行的视图
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* lab = [[UILabel alloc] init];
    lab.text = 0 == component ? _bhList[row][@"Name"] : _volumeArray[row];
    lab.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor whiteColor];
    return lab;
}
#pragma mark 滑动跳转界面
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
    if (scrollView.contentOffset.x>0&&login==0) {
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
            [_asyncSocket disconnect];
        }];
        [alertController addAction:otherAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark 创建订单
- (void)createOrdersWithResultString:(NSString *)resultString alertString:(NSString *)alertString duoOrKongLabelString:(NSString *)labelString{
    int volumes = 0;
    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    holdPositionModel *model = [[holdPositionModel alloc]init];
    model.name = _nameDic[dic[@"Symbol"]];
    model.OrderNumber = dic[@"OrderNumber"];
    model.OpenPrice = dic[@"Price"];
    model.ClosePrice = _asyncSocketArray[4];
    model.buyLessOrMore = labelString;
    model.Volume = dic[@"Volume"];
    volumes=[dic[@"Volume"] intValue];
    model.Commission = [NSNumber numberWithInt:[model.Volume intValue] * (-_shouxufei)];
    [_tableViewDataArray insertObject:model atIndex:0];
    if (_isShowAlertView) {
        [self showAlert:alertString];
    }
    if ([labelString isEqualToString:@"多"]) {
        [_bullishBtn setTitle:BUYONCE forState:UIControlStateNormal];
        _bullishBtn.titleLabel.font = [UIFont systemFontOfSize:22.0];
        [_bearishBtn setTitle:ReversePosition forState:UIControlStateNormal];
        _bearishBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    }else if ([labelString isEqualToString:@"空"]){
        [_bearishBtn setTitle:BUYONCE forState:UIControlStateNormal];
        _bearishBtn.titleLabel.font = [UIFont systemFontOfSize:22.0];
        [_bullishBtn setTitle:ReversePosition forState:UIControlStateNormal];
        _bullishBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    }
    _duoOrKongLabel.text = [NSString stringWithFormat:@"看%@",labelString];
    UIFont *font = _duoOrKongLabel.font = [UIFont systemFontOfSize:18.0f];
    CGSize size1 = [_duoOrKongLabel.text boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil].size;
    _duoOrKongLabel.frame = CGRectMake(0.094*WIDTH, CGRectGetMaxY(_bullishBtn.frame)+10, size1.width, _duoOrKongLabel.frame.size.height);
    if (![@"反向开仓成功" isEqualToString: alertString]) {
        _numberLabel.text =[NSString stringWithFormat:@"%d",[_numberLabel.text intValue]+volumes];//根据买入的手数，改变主界面的手数
    }
    [self updateWidthOfVolume:_numberLabel.text];
    [_tableView reloadData];
}
#pragma mark 刷新买入界面的手数宽度
- (void)updateWidthOfVolume:(NSString *)volumeString{
    UIFont *numberLabelfont = [UIFont systemFontOfSize:18.0f];
    CGSize numberLabelsize = [volumeString boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:numberLabelfont forKey:NSFontAttributeName] context:nil].size;
    _numberLabel.frame = CGRectMake(CGRectGetMaxX(_duoOrKongLabel.frame)+5, CGRectGetMaxY(_duoOrKongLabel.frame)-18, numberLabelsize.width, _numberLabel.frame.size.height);
    _shou.frame = CGRectMake(CGRectGetMaxX(_numberLabel.frame), _numberLabel.frame.origin.y+5, _shou.frame.size.width, _shou.frame.size.height);
}
@end