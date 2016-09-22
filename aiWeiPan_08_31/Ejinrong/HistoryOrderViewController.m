//
//  HistoryOrderViewController.m
//  Ejinrong
//
//  Created by Secret Wang on 15/11/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "HistoryOrderViewController.h"
#import "CustomNavigation.h"
#import "HistoryCell.h"
#import "AFNetworking.h"
#import "WebRequest.h"
#import "GDataXMLNode.h"
#import "SettingView.h"

@interface HistoryOrderViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong,nonatomic) UITableView* tableView;//历史订单列表
@property (strong,nonatomic) NSMutableArray* dataArray;//数据集合
@property (strong,nonatomic) UIActivityIndicatorView *activity;//刷新控件、
@property (assign,nonatomic) BOOL isOut;//设置视图是否推出
@property (strong,nonatomic) UIPickerView *picView;//滚动视图
@property (strong,nonatomic) NSArray *daysArray;//历史天数
@property (strong,nonatomic) SettingView *settingView;//设置视图
@property (assign,nonatomic) NSInteger oldDays;//选中前设置的天数
@property (assign,nonatomic) NSInteger days;//选中的天数
@property (strong,nonatomic) NSMutableDictionary *nameDic;//商品中文名字典
@property (strong,nonatomic) NSMutableArray *itemList;//筛选项目列表
@property (copy,nonatomic) NSString *oldItem;//选中前设置的项目
@property (copy,nonatomic) NSString *item;//选中的项目

@end

#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height
#define BLUECOLOR [UIColor colorWithRed:20/255.0 green:113/255.0 blue:221/255.0 alpha:1]
//#define TASKGUID  @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf"
@implementation HistoryOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CustomNavigation loadUIViewController:self title:@"历史订单" navigationBarBgColor:[UIColor blackColor] backSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"chazhao"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(BtnClick:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    _dataArray = [[NSMutableArray alloc] init];
    _item  = @"全部商品";
    [self initData];
    [self createTableView];
    [self loadData];
    [self createSettingView];
}
- (void)initData{
    NSString* path = [[NSBundle mainBundle]pathForResource:@"dataList" ofType:@"plist"];
    NSDictionary* data = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray *bhList = [[NSUserDefaults standardUserDefaults] objectForKey:@"BHList"];//获取商品列表
    _nameDic = [NSMutableDictionary dictionary];//商品中文名字典
    _itemList = [NSMutableArray array];//筛选项目列表
    for (NSDictionary *dic in bhList) {
        [_nameDic setObject:dic[@"Name"] forKey:dic[@"Bh"]];
        [_itemList addObject:dic[@"Name"]];
    }
    [_itemList insertObject:@"全部商品" atIndex:0];
    [_itemList insertObject:@"其他商品" atIndex:(_itemList.count)];
    _daysArray = data[@"Days"];
    _isOut = NO;
}
- (void)createSettingView{
    //------ 设置视图 ------
    _settingView = [[SettingView alloc]initWithFrame:CGRectMake(0, -HEIGHT, WIDTH, HEIGHT)];
    [_settingView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_settingView];
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(WIDTH*0.25, _settingView.bounds.size.height*0.5-150, WIDTH*0.5, 30)];
    label.text=@"选择近期订单";
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    [_settingView addSubview:label];
    //------ 设置视图_滚动视图 ------
    _picView = [[UIPickerView alloc]initWithFrame:CGRectMake(WIDTH*0.25, _settingView.bounds.size.height*0.5-150, WIDTH*0.5, 200)];
    [_picView setDelegate:self];
    [_picView setDataSource:self];
    [_settingView addSubview:_picView];
}
#pragma mark 设置点击事件
- (void)BtnClick:(UIBarButtonItem *)sender{
    if (_isOut == NO) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"guanbi_"];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = _settingView.frame;
            rect.origin.y = 0;
            _settingView.frame = rect;
        }];
        _isOut = YES;
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = _settingView.frame;
            rect.origin.y = -HEIGHT;
            _settingView.frame = rect;
        }];
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"chazhao"];
        _isOut = NO;
        if (_oldDays!=_days || _oldItem != _item) {
            [self loadData];
        }
    }
}
#pragma mark ****** 时间戳转时间
-(NSString*)TimeIntervalChangeToTimes:(NSString*)str{
    NSTimeInterval time = [str doubleValue];
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
    NSString *curentDateStr = [dateFormatter stringFromDate:detailDate];
    return curentDateStr;
}
#pragma mark ****** 数据的请求
- (void)loadData{
    [_activity startAnimating];
    NSDictionary* login = [[NSUserDefaults standardUserDefaults]objectForKey:@"userDic"];
    NSString* log = [login objectForKey:@"LoginID"];
    long nowDate = (long)[[NSDate date]timeIntervalSince1970] + 60 * 60 * 24;
    NSString* nowStr = [NSString stringWithFormat:@"%ld",nowDate];
    NSString* now = [self TimeIntervalChangeToTimes:nowStr];
    long lastDate = nowDate - 24 * 60 * 60 * (_days + 2);
    NSString* lastStr = [NSString stringWithFormat:@"%ld",lastDate];
    NSString* last = [self TimeIntervalChangeToTimes:lastStr];
    NSString* DriverID = [[NSUserDefaults standardUserDefaults]objectForKey:@"DRIVERID"];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                DriverID,@"DriverID",
                                @"1111",@"UserID",
                                @"ab8495db-3a4a-4f70-bb81-8518f60ec8bf",@"TaskGuid",
                                @"CloseOrderPages",@"DataType",
                                log,@"LoginID",
                                @"1",@"ProductType",
                                @"100",@"PageCount",
                                @"1",@"PageIndex",
                                @"500",@"PageSize",
                                last,@"StratTime",
                                now,@"EndTime",
                                @"",@"Symbol",nil];
    WebRequest *webRequest = [[WebRequest alloc] init];
    [webRequest webRequestWithDataDic:dic requestType:kRequestTypeTransformData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        GDataXMLDocument* document = [[GDataXMLDocument alloc]initWithData:responseObject options:0 error:nil];
        GDataXMLElement* element = [document rootElement];
        NSArray* array = [element children];
        NSArray *jsonArray = [NSArray array];
        for (int i = 0; i<array.count; i++) {
            GDataXMLElement* ele = [array objectAtIndex:i];
            NSData* data = [[ele stringValue]dataUsingEncoding:NSUTF8StringEncoding];
            jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
        if (error != nil) {
            NSLog(@"错误提示:%@",error);
        }else{
            if (jsonArray.count>0) {
                NSMutableArray *dataArr = [NSMutableArray array];
                for (NSDictionary* dic in jsonArray) {
                    HistoryOrderModel* model = [[HistoryOrderModel alloc]init];
                    model.Symbol = (_nameDic[dic[@"Symbol"]] == nil ? dic[@"Symbol"] : _nameDic[dic[@"Symbol"]]);
                    model.OpenTime = dic[@"OpenTime"];
                    model.CloseTime = dic[@"CloseTime"];
                    model.OpenPrice = dic[@"OpenPrice"];
                    model.ClosePrice = dic[@"ClosePrice"];
                    model.Profit = dic[@"Profit"];
                    model.Volume = dic[@"Volume"];
                    model.Comment = dic[@"Comment"];
                    model.Commission = dic[@"Commission"];
                    model.TypeName = dic[@"Type"];
                    [dataArr addObject:model];
                }
                [_dataArray removeAllObjects];
                if ([_item isEqualToString:@"全部商品"]) {
                    _dataArray = dataArr;
                }else if ([_item isEqualToString:@"其他商品"]){
                    for (NSDictionary *dic in jsonArray) {
                        if (_nameDic[dic[@"Symbol"]] == nil) {
                            HistoryOrderModel* model = [[HistoryOrderModel alloc]init];
                            model.Symbol = dic[@"Symbol"];
                            model.OpenTime = dic[@"OpenTime"];
                            model.CloseTime = dic[@"CloseTime"];
                            model.OpenPrice = dic[@"OpenPrice"];
                            model.ClosePrice = dic[@"ClosePrice"];
                            model.Profit = dic[@"Profit"];
                            model.Volume = dic[@"Volume"];
                            model.Comment = dic[@"Comment"];
                            model.Commission = dic[@"Commission"];
                            model.TypeName = dic[@"Type"];
                            [_dataArray addObject:model];
                        }
                    }
                }else{
                    for (HistoryOrderModel *model in dataArr) {
                        if ([_item isEqualToString:model.Symbol]) {
                            [_dataArray addObject:model];
                        }
                    }
                }
                [_tableView reloadData];
                _oldDays = _days;
                _oldItem = _item;
            }
        }
        [_activity stopAnimating];
    }];
}

#pragma mark ****** 返回
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ****** 创建tableView
- (void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.view addSubview:_tableView];
    //------ 刷新控件 ------
    //------ 指定进度轮中心点 ------
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //------ 指定进度轮中心点 ------
    [_activity setCenter:self.view.center];
    //------ 设置进度轮显示类型 ------
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_activity];
}
#pragma mark ****** tableView的代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellId = @"cell";
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell config:_dataArray[indexPath.row]];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark UIPickerView的代理方法
#pragma mark 返回列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{return 2;}
#pragma mark 返回每列行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0 == component ? [_daysArray count] : [_itemList count];
}
#pragma mark 把选中行的标题放入用户配置
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (0==component) {
        _days = row;
    }else{
        _item = _itemList[row];
    }
   
}
#pragma mark 自定义每行的视图
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* lab = [[UILabel alloc] init];
    lab.text = 0 == component ? _daysArray[row] : _itemList[row];
    [lab setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    return lab;
}
@end