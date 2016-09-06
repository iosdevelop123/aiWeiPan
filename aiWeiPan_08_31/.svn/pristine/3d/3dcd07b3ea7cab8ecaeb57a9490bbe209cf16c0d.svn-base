//
//  TimeChartView.m
//  lightningViewDemo
//
//  Created by dayu on 15/11/3.
//  Copyright © 2015年 dayu. All rights reserved.
//
#import "TimeChartView.h"

@implementation TimeChartView

#pragma mark -初始化视图
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _pointArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark -根据最新点刷新点数组
- (void)addPoint:(CGPoint)point{
    NSValue *val = [NSValue valueWithCGPoint:point];
    [_pointArray addObject:val];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //点数组
    CGPoint points[_pointArray.count];
    for (int i = 0; i<_pointArray.count; i++) {
        points[i] = [_pointArray[i] CGPointValue];
    }
    CGContextAddLines(ctx, points, _pointArray.count);
    //线圆角
    CGContextSetLineCap(ctx, kCGLineCapRound);
    //设置线的颜色
    [[UIColor colorWithRed:232/255.0 green:192/255.0 blue:133/255.0 alpha:1.0] setStroke];
    //画线
    CGContextStrokePath(ctx);
    
    //取最新点
    CGPoint point = [[_pointArray lastObject] CGPointValue];
    //设置填充色
    [[UIColor redColor] setFill];
    //画实心圆
    CGContextFillEllipseInRect(ctx, CGRectMake(point.x-2.5, point.y-2.5, 5, 5));
}

@end
