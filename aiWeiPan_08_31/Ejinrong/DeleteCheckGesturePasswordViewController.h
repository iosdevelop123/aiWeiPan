//
//  DeleteCheckGesturePasswordViewController.h
//  Ejinrong
//
//  Created by dayu on 15/10/15.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGestureLockView.h"
#import "LoginPasswordCheckViewController.h"
#import "PopViewControllerDelegate.h"
@interface DeleteCheckGesturePasswordViewController : UIViewController<KKGestureLockViewDelegate>
@property (weak,nonatomic) id<PopViewControllerDelegate> delegate;
@property (strong,nonatomic) KKGestureLockView* lockView;
@property (assign,nonatomic) BOOL isShowLine;
@end