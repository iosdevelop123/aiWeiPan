//
//  WebController.m
//  aiWeiPan
//
//  Created by Secret Wang on 2016/11/16.
//  Copyright © 2016年 pan. All rights reserved.
//

#import "WebController.h"
#import "PrefixHeader.pch"

@interface WebController ()<UIWebViewDelegate>
{
    UILabel* bgView;
}
@end

@implementation WebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createWeb];
}
-(void)createWeb{
    UIWebView* web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    web.scalesPageToFit = YES;
    web.delegate = self;
    web.dataDetectorTypes = UIDataDetectorTypeAddress;
    [self.view addSubview:web];
    NSURL* url = [NSURL URLWithString:@"https://xidue.com/hd/hd.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [web loadRequest:request];//加载
}
//开始加载时调用的方法
- (void)webViewDidStartLoad:(UIWebView *)webView{
    bgView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5;
    bgView.center = self.view.center;
    bgView.textAlignment = NSTextAlignmentCenter;
    bgView.text = @"正在加载...";
    bgView.textColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 8;
    bgView.font = [UIFont systemFontOfSize:14.0f];
    // 添加到窗口
    [webView addSubview:bgView];
    WLog(@"开始加载");
}
//结束加载时调用的方法
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIView animateWithDuration:1.5 animations:^{
        [bgView removeFromSuperview];
    }];
    WLog(@"结束加载");
}
-(void)viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.5 animations:^{
        [bgView removeFromSuperview];
    }];
}
//加载失败时调用的方法
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    bgView.text = @"加载失败!";
    
}

@end
