//
//  RootTableViewCell.m
//  Ejinrong
//
//  Created by Secret Wang on 15/10/22.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "RootTableViewCell.h"
@implementation RootTableViewCell

#define GRAYCOLOR [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0]
#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT self.frame.size.height

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor blackColor];
        //商品名称
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 0, 15)];
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.textColor = [UIColor colorWithRed:0 green:110/255.0 blue:222/255.0 alpha:1];
        [self.contentView addSubview:_nameLabel];
        
        //手数
        _volumeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+2, 11, 45, 20)];
        _volumeLabel.textColor = [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1];
        _volumeLabel.font = [UIFont systemFontOfSize:15.0f];
        [self.contentView addSubview:_volumeLabel];
        
        //看多or看空
        _buyMoreOrLess = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_nameLabel.frame)+6.5, 36, 16)];
        _buyMoreOrLess.layer.cornerRadius = 2;
        _buyMoreOrLess.layer.masksToBounds = YES;
        _buyMoreOrLess.textAlignment = NSTextAlignmentCenter;
        _buyMoreOrLess.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_buyMoreOrLess];
        //手续费
        _commissionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_buyMoreOrLess.frame)+10, CGRectGetMaxY(_nameLabel.frame)+8, 0, 11)];
        _commissionLabel.textColor = [UIColor colorWithRed:0.92 green:0.76 blue:0.51 alpha:1];
        _commissionLabel.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:_commissionLabel];
        
        //盈亏
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:21.0];
        [self.contentView addSubview:_priceLabel];
        _yuanLabel = [[UILabel alloc] init];
        _yuanLabel.text = @"$";
        _yuanLabel.font = [UIFont systemFontOfSize:10.0f];
        _yuanLabel.textColor = GRAYCOLOR;
        [self.contentView addSubview:_yuanLabel];
        
        //关仓价
        _priceChangeLabel2 = [[UILabel alloc] init];
        _priceChangeLabel2.font = [UIFont systemFontOfSize:10.0f];
        _priceChangeLabel2.textColor = GRAYCOLOR;
        [self.contentView addSubview:_priceChangeLabel2];
        
        //箭头
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"jianhao"];
        [self.contentView addSubview:_arrowImageView];
        //开仓价
        _priceChangeLabel = [[UILabel alloc] init];
        _priceChangeLabel.font = [UIFont systemFontOfSize:10.0f];
        _priceChangeLabel.textColor = GRAYCOLOR;
        [self.contentView addSubview:_priceChangeLabel];
        
        //平仓按钮
        _sellButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _sellButton.frame = CGRectMake(WIDTH-75, 15, 55, 30) ;
        [_sellButton setTitle:@"平仓" forState:UIControlStateNormal];
        [_sellButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        _sellButton.backgroundColor = [UIColor colorWithRed:0.92 green:0.76 blue:0.51 alpha:1];
        _sellButton.layer.cornerRadius = 5;
        _sellButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _sellButton.layer.masksToBounds = YES;
//        [self.contentView addSubview:_sellButton];
    }
    return self;
}

#pragma mark 刷新cell中的label
- (void)config:(holdPositionModel *)model{
    _OrderNumber = model.OrderNumber;
    _Volume = model.Volume;
    
    //刷新商品名称label
    _nameLabel.text = model.name;
    _nameLabel.frame = CGRectMake(15, 12, [self getLabelSizeWithString:model.name fontSize:15].width, 15);
    
    //刷新手数label
    _volumeLabel.text = [NSString stringWithFormat:@"%@ 手",model.Volume];
    _volumeLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+10, 12, _volumeLabel.frame.size.width, 15);
    
    //刷新看多or看空label
    if ([model.buyLessOrMore isEqualToString:@"Sell"]) {
        _buyMoreOrLess.text = @"看空";
        _buyMoreOrLess.backgroundColor = [UIColor colorWithRed:0.0 green:101/255.0 blue:6/255.0 alpha:1];
    }else if([model.buyLessOrMore isEqualToString:@"Buy"]){
        _buyMoreOrLess.text = @"看多";
        _buyMoreOrLess.backgroundColor = [UIColor colorWithRed:153/255.0 green:14/255.0 blue:0.0 alpha:1];
    }
    
    //刷新盈亏label
    _priceLabel.text = [NSString stringWithFormat:@"%@",model.Profit];
    _priceLabel.frame = CGRectMake(WIDTH-[self getLabelSizeWithString:_priceLabel.text fontSize:21.0].width-96, 12, [self getLabelSizeWithString:_priceLabel.text fontSize:21.0].width, 21);
    if ([model.Profit intValue]<0) {
        _priceLabel.textColor = [UIColor greenColor];
    }else {
        _priceLabel.textColor = [UIColor colorWithRed:250/255.0 green:67/255.0 blue:0 alpha:1];
    }
    _yuanLabel.frame = CGRectMake(CGRectGetMaxX(_priceLabel.frame)+2.5, 20.5, 10, 10);
    
    //刷新手续费label
    _commissionLabel.text = [NSString stringWithFormat:@"手续费 %@",model.Commission];
    _commissionLabel.frame = CGRectMake(CGRectGetMaxX(_buyMoreOrLess.frame)+10, CGRectGetMaxY(_volumeLabel.frame)+7, [self getLabelSizeWithString:_commissionLabel.text fontSize:11].width, 11);
    
    //刷新关仓价label
    _priceChangeLabel2.text = [NSString stringWithFormat:@"%@",model.ClosePrice];
    _priceChangeLabel2.frame = CGRectMake(WIDTH-[self getLabelSizeWithString:_priceChangeLabel2.text fontSize:10.0].width-82, CGRectGetMaxY(_yuanLabel.frame)+6, [self getLabelSizeWithString:_priceChangeLabel2.text fontSize:10.0].width, 10);
    
    //刷新箭头label
    _arrowImageView.frame =CGRectMake(CGRectGetMinX(_priceChangeLabel2.frame)-10, CGRectGetMinY(_priceChangeLabel2.frame)+3, 9, 4);
    
    //刷新开仓价label
    _priceChangeLabel.text = [NSString stringWithFormat:@"%@",model.OpenPrice];
    _priceChangeLabel.frame = CGRectMake(WIDTH - [self getLabelSizeWithString:_priceChangeLabel.text fontSize:10.0].width - _priceChangeLabel2.frame.size.width-93, CGRectGetMinY(_priceChangeLabel2.frame), [self getLabelSizeWithString:_priceChangeLabel.text fontSize:10.0].width, 10);
}

#pragma mark 根据Label的内容和字体大小获取lalel的大小
- (CGSize)getLabelSizeWithString:(NSString *)labelString fontSize:(CGFloat)fontSize{
    return [labelString boundingRectWithSize:CGSizeMake(1000, fontSize) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName] context:nil].size;
}

@end