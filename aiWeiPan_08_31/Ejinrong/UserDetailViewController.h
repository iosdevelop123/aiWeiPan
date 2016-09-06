//
//  UserDetailViewController.h
//  Ejinrong
//
//  Created by Secret Wang on 15/10/10.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  UserDetailViewControllerDelegate<NSObject>
- (void)changeHeadimage:(NSData*)imageData;
- (void)changeNickname:(NSString*)Nickname;
@end

@interface UserDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(weak,nonatomic) id<UserDetailViewControllerDelegate> delegate;

@end
