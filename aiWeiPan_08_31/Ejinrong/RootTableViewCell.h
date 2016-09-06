//
//  RootTableViewCell.h
//  Ejinrong
//
//  Created by Secret Wang on 15/10/22.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "holdPositionModel.h"
@class UILabelWithAutoWidth;
@interface RootTableViewCell : UITableViewCell

@property (strong,nonatomic) UILabel* nameLabel;//商品名称
@property (strong,nonatomic) UILabel* volumeLabel;//手数
@property (strong,nonatomic) UILabel* buyMoreOrLess;//看多or看空
@property (strong,nonatomic) UILabel* commissionLabel;//手续费
@property (strong,nonatomic) UILabel* priceLabel;//盈亏标签
@property (strong,nonatomic) UILabel* yuanLabel;//单位
@property (strong,nonatomic) UILabel* priceChangeLabel;//关仓价
@property (strong,nonatomic) UILabel* priceChangeLabel2;//开仓价
@property (strong,nonatomic) UIButton* sellButton;//平仓按钮
@property (strong,nonatomic) UIImageView* arrowImageView;//向右箭头图标
@property (strong,nonatomic) NSNumber *OrderNumber;//订单号
@property (strong,nonatomic) NSNumber *Volume;//手数
;

- (void)config:(holdPositionModel *)model;

@end
