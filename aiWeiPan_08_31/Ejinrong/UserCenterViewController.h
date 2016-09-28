//
//  UserCenterViewController.h
//  Ejinrong
//
//  Created by dayu on 15/10/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopViewControllerDelegate.h"
@interface UserCenterViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak,nonatomic) id<PopViewControllerDelegate> delegate;

@property (nonatomic, strong)NSMutableDictionary *dic;

@end
