//
//  ChangeGesturePasswordViewController.h
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGestureLockView.h"
#import "LoginPasswordCheckViewController.h"

@interface ChangeGesturePasswordViewController : UIViewController<KKGestureLockViewDelegate,PopViewControllerDelegate>

@property (strong,nonatomic) KKGestureLockView* checkLockView;
@property (strong,nonatomic) KKGestureLockView* changeLockView;
@property (assign,nonatomic) BOOL isShowLine;
@property (assign,nonatomic) BOOL isDeleteCode;

@end