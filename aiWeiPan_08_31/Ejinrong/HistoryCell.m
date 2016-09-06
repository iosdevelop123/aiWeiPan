//
//  HistoryCell.m
//  Ejinrong
//
//  Created by Secret Wang on 15/11/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import "HistoryCell.h"
#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT self.frame.size.height

@implementation HistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor blackColor];
        //商品名
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 0, 15)];
        _nameLabel.numberOfLines = 0;
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.textColor = [UIColor colorWithRed:0 green:110/255.0 blue:222/255.0 alpha:1];
        [self.contentView addSubview:_nameLabel];
        
        //看多or看空
        _CommentLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameLabel.frame.origin.x, CGRectGetMaxY(_nameLabel.frame)+5, 30, 17)];
        _CommentLabel.textColor = [UIColor whiteColor];
        _CommentLabel.layer.cornerRadius = 2;
        _CommentLabel.layer.masksToBounds = YES;
        _CommentLabel.textAlignment = NSTextAlignmentCenter;
        _CommentLabel.font = [UIFont systemFontOfSize:12.0f];
        _CommentLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_CommentLabel];
        
        //手数
        _VolumeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+5, 13, 40, 15)];
        _VolumeLabel.textColor = [UIColor colorWithRed:0.94 green:0.25 blue:0.01 alpha:1];
        _VolumeLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:_VolumeLabel];
        
        //手续费
        _CommissionLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_CommentLabel.frame)+10, _CommentLabel.frame.origin.y+4, 100, 10)];
        _CommissionLabel.textColor = [UIColor colorWithRed:0.77 green:0.64 blue:0.42 alpha:1];
        _CommissionLabel.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:_CommissionLabel];
        
        //开仓日期
        _OpenDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/2.0-40, 8, 80, 22)];
        _OpenDateLabel.textColor = [UIColor grayColor];
        _OpenDateLabel.font = [UIFont systemFontOfSize:13.5f];
        [self.contentView addSubview:_OpenDateLabel];
        
        //开仓时间
        _OpenTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_OpenDateLabel.frame)-1, CGRectGetMaxY(_OpenDateLabel.frame), 35, 20)];
        _OpenTimeLabel.textColor = [UIColor grayColor];
        _OpenTimeLabel.textAlignment = NSTextAlignmentCenter;
        _OpenTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_OpenTimeLabel];
        
        //"-"号箭头
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_OpenTimeLabel.frame), CGRectGetMaxY(_OpenDateLabel.frame), 6, 20)];
        label.text = @"-";
        label.textColor = [UIColor grayColor];
        [self.contentView addSubview:label];
        
        //关仓时间
        _CloseTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), _OpenTimeLabel.frame.origin.y, 35, 20)];
        _CloseTimeLabel.textColor = [UIColor grayColor];
        _CloseTimeLabel.textAlignment = NSTextAlignmentCenter;
        _CloseTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_CloseTimeLabel];
        
        //单笔盈亏
        _ProfitLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH-150, 5, 120, 32)];
        _ProfitLabel.textAlignment = NSTextAlignmentRight;
        _ProfitLabel.font = [UIFont systemFontOfSize:25.0f];
        [self.contentView addSubview:_ProfitLabel];
        
        //“$”
        UILabel* yuan = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_ProfitLabel.frame), 13, 20, 20)];
        yuan.text = @"$";
        yuan.textColor = [UIColor grayColor];
        yuan.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:yuan];
        
        //开仓价
        _OpenPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH-110, CGRectGetMaxY(_ProfitLabel.frame), 50, 10)];
        _OpenPriceLabel.textAlignment = NSTextAlignmentRight;
        _OpenPriceLabel.font = [UIFont systemFontOfSize:11.0f];
        _OpenPriceLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_OpenPriceLabel];
        
        //箭头
        _arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_OpenPriceLabel.frame), _OpenPriceLabel.frame.origin.y+3, 9, 4)];
        _arrowImageView.image = [UIImage imageNamed:@"jianhao"];
        [self.contentView addSubview:_arrowImageView];
        
        //关仓价
        _ClosePriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_arrowImageView.frame), _OpenPriceLabel.frame.origin.y, 50, 10)];
        _ClosePriceLabel.textColor = [UIColor grayColor];
        _ClosePriceLabel.textAlignment = NSTextAlignmentLeft;
        _ClosePriceLabel.font = [UIFont systemFontOfSize:11.0f];
        [self.contentView addSubview:_ClosePriceLabel];
    }
    return self;
}

- (void)config:(HistoryOrderModel *)model{
    //刷新商品名
    _nameLabel.text = model.Symbol;
    _nameLabel.numberOfLines = 0;
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    CGSize size = [_nameLabel.text boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil].size;
    _nameLabel.frame = CGRectMake(15, 12, size.width, 15);
    
    //刷新手数
    _VolumeLabel.text = [NSString stringWithFormat:@"%@手",model.Volume];
    _VolumeLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+5, _VolumeLabel.frame.origin.y, _VolumeLabel.frame.size.width, _VolumeLabel.frame.size.height);
    
    //刷新看多or看空
    if ([@"Buy" isEqualToString:model.TypeName]) {
        _CommentLabel.text = @"看多";
        _CommentLabel.backgroundColor = [UIColor colorWithRed:153/255.0 green:14/255.0 blue:0.0 alpha:1];
    }else if([@"Sell" isEqualToString:model.TypeName]){
        _CommentLabel.text = @"看空";
        _CommentLabel.backgroundColor =  [UIColor colorWithRed:0.0 green:101/255.0 blue:6/255.0 alpha:1];;
    }
    
    //刷新手续费
    _CommissionLabel.text = [NSString stringWithFormat:@"手续费%@",model.Commission];
    
    //刷新开仓日期
    _OpenDateLabel.text = [model.OpenTime substringToIndex:10];
    
    //刷新开关仓时间
    NSRange range = NSMakeRange(11, 5);
    _OpenTimeLabel.text = [model.OpenTime substringWithRange:range];
    _CloseTimeLabel.text = [model.CloseTime substringWithRange:range];
    
    //刷新盈亏
    _ProfitLabel.text = [NSString stringWithFormat:@"%@",model.Profit];
    if ([model.Profit intValue] >= 0) {
        _ProfitLabel.textColor = [UIColor colorWithRed:0.91 green:0.24 blue:0 alpha:1];
    }else
        _ProfitLabel.textColor = [UIColor greenColor];
    
    //刷新开关仓价格
    _ClosePriceLabel.text = [NSString stringWithFormat:@"%@",model.ClosePrice];
    _OpenPriceLabel.text = [NSString stringWithFormat:@"%@",model.OpenPrice];
}

@end