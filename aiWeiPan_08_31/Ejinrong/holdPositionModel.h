//
//  holdPositionModel.h
//  Ejinrong
//
//  Created by Secret Wang on 15/10/22.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface holdPositionModel : NSObject

@property (copy,nonatomic) NSString* name;//商品中文名
@property (copy,nonatomic) NSString* buyLessOrMore;//看多or看空
@property (strong,nonatomic) NSNumber* OpenPrice;//开仓价
@property (strong,nonatomic) NSNumber* ClosePrice;//关仓价
@property (strong,nonatomic) NSNumber* Profit;//盈亏
@property (strong,nonatomic) NSNumber* Commission;//手续费
@property (strong,nonatomic) NSNumber *OrderNumber;//订单号
@property (strong,nonatomic) NSNumber *Volume;//手数
@property (strong,nonatomic) NSNumber* StopLoss;
@property (strong,nonatomic) NSNumber* TakeProfit;

@end