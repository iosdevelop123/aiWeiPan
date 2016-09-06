//
//  SettingView.m
//  Ejinrong
//
//  Created by dayu on 15/9/24.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "SettingView.h"

@implementation SettingView

- (void)drawRect:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //取点
    CGContextMoveToPoint(ctx, 0, height*0.5-40);
    CGContextAddLineToPoint(ctx, width, height*0.5-40);
    //颜色
    [[UIColor colorWithRed:232/255.0 green:192/255.0 blue:133/255.0 alpha:1.0] setStroke];
    //画线
    CGContextStrokePath(ctx);
}
@end
