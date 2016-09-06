//
//  LightningView.m
//  lightningViewDemo
//
//  Created by dayu on 15/11/3.
//  Copyright © 2015年 dayu. All rights reserved.
//
#import "LightningView.h"

#define GLODENCOLOR [UIColor colorWithRed:232/255.0 green:192/255.0 blue:133/255.0 alpha:1.0]
#define _view_size [UIScreen mainScreen].bounds.size

@implementation LightningView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}
-(void)createUI{
    self.backgroundColor = [UIColor clearColor];
    //------ 六虚线背景图片视图 ------
    _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _view_size.width, (_view_size.height-60)*0.44)];
    _bgImageView.backgroundColor = [UIColor clearColor];
    CGFloat width = _bgImageView.bounds.size.width;
    CGFloat height = _bgImageView.bounds.size.height;
    CGFloat equalHeight = (height-40.0)/5.0;
    UIGraphicsBeginImageContext(_bgImageView.frame.size);   //开始画线
    [_bgImageView.image drawInRect:CGRectMake(0, 0, _bgImageView.frame.size.width, _bgImageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    CGFloat lengths[] = {1,1};//实现点线
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor lightGrayColor].CGColor);
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    for (int i = 0; i<6; i++) {
        CGContextMoveToPoint(line, 5.0, 20.0+i*equalHeight);
        CGContextAddLineToPoint(line, width-5 , 20.0+i*equalHeight);
    }
    CGContextStrokePath(line);
    _bgImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self addSubview:_bgImageView];
    
    NSMutableArray* timeArray = [[NSMutableArray alloc]init];
    for (int i=0; i<3; i++) {
        NSTimeInterval dat = [[NSDate date]timeIntervalSince1970];
        NSString* str = [NSString stringWithFormat:@"%.0f",dat];
        //时间戳
        NSTimeInterval time=[str doubleValue]- 25200 - i * (_view_size.width-71)/2;
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
        [timeArray addObject:currentDateStr];
    }
    for (int i=0; i<3; i++) {
        UILabel* timelabel =[[UILabel alloc]initWithFrame:CGRectMake(10+(_view_size.width-71)/2.0 * i, self.frame.size.height-10, 50, 10)];
        timelabel.text = timeArray[2-i];
        timelabel.tag = 30+i;
        timelabel.font = [UIFont systemFontOfSize:11.0f];
        timelabel.textColor = GLODENCOLOR;
        [self addSubview:timelabel];
    }
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor blackColor];
    _priceLabel.backgroundColor = GLODENCOLOR;
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.layer.cornerRadius = 2;
    _priceLabel.layer.masksToBounds = YES;
    _priceLabel.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:_priceLabel];
    //等高距离
    CGFloat equalHight = (self.frame.size.height - 40)/5.0;
    //等差价格
    CGFloat num = (_maxPriceForLightningView - _minPriceForLightningView)/5.0;
    //闪电图线和价格
    for (int i= 0; i<6; i++) {
        UILabel * priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-37, 8+equalHight*i, 35, 10)];
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:10.0];
        priceLabel.text = [NSString stringWithFormat:@"%.2f",_maxPriceForLightningView-num*i];
        priceLabel.tag = 10+(5-i);
        [self addSubview:priceLabel];
    }
}

- (void)refreshPoint:(NSMutableArray *)pointArray{
    _pointArray = pointArray;
    for (int i = 0; i<_pointArray.count-1; i++) {
        NSValue* va = _pointArray[i];
        CGPoint  pt = [va CGPointValue];
        pt.x -= 1;//每半秒走5个点，为了看效果(正常一个点)
        NSValue* newVa = [NSValue valueWithCGPoint:pt ];
        [_pointArray replaceObjectAtIndex:i withObject:newVa];
    }
    
    for (int i = (int)_pointArray.count-1; i>=0; i--) {
        NSValue* va = _pointArray[i];
        CGPoint pt = [va CGPointValue];
        if (pt.x<5) {
            [_pointArray removeObject:va];
        }
    }
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
    CGPoint point = [[_pointArray objectAtIndex:_pointArray.count-2] CGPointValue];
    //设置填充色
    [[UIColor redColor] setFill];
    //画实心圆
    CGContextFillEllipseInRect(ctx, CGRectMake(point.x-2.5, point.y-2.5, 5, 5));
}

@end
