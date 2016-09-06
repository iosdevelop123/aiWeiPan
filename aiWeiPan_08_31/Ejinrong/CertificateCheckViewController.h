//
//  CertificateCheckViewController.h
//  Ejinrong
//
//  Created by Aaron Lee on 15/10/21.
//  Copyright © 2015年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CertificateCheckViewControllerDelegate<NSObject>
- (void)showCertificate:(NSString *)carID name:(NSString *)name;
@end
@interface CertificateCheckViewController : UIViewController
@property (weak,nonatomic) id<CertificateCheckViewControllerDelegate> delegate;
@end