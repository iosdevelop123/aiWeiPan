//
//  UserGuideViewController.m
//  Ejinrong
//
//  Created by dayu on 15/9/30.
//  Copyright © 2015年 pan. All rights reserved.
//
#import "UserGuideViewController.h"
#import "MainViewController.h"
#define WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
@interface UserGuideViewController ()<UIScrollViewDelegate>

@property (strong,nonatomic) UIPageControl *pageControl;//引导页码
@property (strong,nonatomic) UIScrollView *scrollView;//引导视图

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"dataList" ofType:@"plist"];
    NSArray *launchImageArray = [NSDictionary dictionaryWithContentsOfFile:plistPath][@"launchImages"];
    //------ 加载新用户引导页面 ------
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [_scrollView setContentSize:CGSizeMake(WIDTH*3, HEIGHT)];
    [_scrollView setPagingEnabled:YES];  //视图整页显示
    [_scrollView setDelegate:self];
    [_scrollView setBounces:NO]; //避免弹跳效果
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [imageview setImage:[UIImage imageNamed:[NSString stringWithFormat:launchImageArray[0],(NSInteger)HEIGHT]]];
    [_scrollView addSubview:imageview];
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
    [imageview1 setImage:[UIImage imageNamed:[NSString stringWithFormat:launchImageArray[1],(NSInteger)HEIGHT]]];
    [_scrollView addSubview:imageview1];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, HEIGHT)];
    [imageview2 setImage:[UIImage imageNamed:[NSString stringWithFormat:launchImageArray[2],(NSInteger)HEIGHT]]];
    imageview2.userInteractionEnabled = YES;    //打开imageview3的用户交互;否则下面的button无法响应
    [_scrollView addSubview:imageview2];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//在imageview3上加载一个透明的button
    [button setTitle:nil forState:UIControlStateNormal];
    [button setFrame:CGRectMake(WIDTH*0.5-95, HEIGHT-102, 190, 37)];
    [button addTarget:self action:@selector(firstPressed) forControlEvents:UIControlEventTouchUpInside];
    [imageview2 addSubview:button];
    
    [self.view addSubview:_scrollView];
    
    //------ 引导页码 ------
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, HEIGHT - 50, WIDTH, 10)];
    [_pageControl setNumberOfPages:3];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0 green:110/255.0 blue:222/255.0 alpha:1.0]];
    [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0]];
    [_pageControl addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pageControl];
}

#pragma mark 引导视图滑动结束事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_pageControl setCurrentPage:_scrollView.contentOffset.x/WIDTH];
}

#pragma mark 跳转根视图
- (void)firstPressed{
    MainViewController *mainVC = [[MainViewController alloc] init];
    [self presentViewController:mainVC animated:YES completion:nil];  //点击button跳转到根视图
}

#pragma mark 点击引导页码切换引导页
- (void)valueChange:(UIPageControl *)sender{
    [_scrollView setContentOffset:CGPointMake(sender.currentPage*WIDTH, 0) animated:YES];
}

@end