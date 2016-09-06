//
//  TimeChartView.h
//  lightningViewDemo
//
//  Created by dayu on 15/11/3.
//  Copyright © 2015年 dayu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeChartView : UIView

/** 波动点数组 */
@property (strong,nonatomic) NSMutableArray *pointArray;
/** 波动价数组 */
@property (strong,nonatomic) NSMutableArray *priceArray;

- (void)addPoint:(CGPoint)point;

@end
