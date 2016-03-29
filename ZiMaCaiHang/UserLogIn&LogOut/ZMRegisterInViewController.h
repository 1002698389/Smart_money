//
//  ZMRegisterInViewController.h
//  ZiMaCaiHang
//
//  Created by 财行家 on 15/9/18.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ZMRegisterInViewController : BaseViewController

@property (nonatomic, assign) BOOL isForgetPassword;

@property (assign, nonatomic) BOOL isFromAppDelegate;   //只有从AppDelegate打开才为 YES

@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *titleOneView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNumberLeftView;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNumberT;
@property (weak, nonatomic) IBOutlet UIImageView *passwordLeftView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *passwordT;
@property (weak, nonatomic) IBOutlet UIImageView *confirmLeftView;
@property (weak, nonatomic) IBOutlet UIImageView *confirmT;

@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeT;

@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton; // 获取验证码
@property (weak, nonatomic) IBOutlet UITextField *sharecodeTextField;//邀请码
@property (weak, nonatomic) IBOutlet UIImageView *sharecodeView;

@property (weak, nonatomic) IBOutlet UIButton *checkAgreeButton;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;

@property (weak, nonatomic) IBOutlet UIButton *usingAgreementButton;

@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;

@property (weak, nonatomic) IBOutlet UIButton *backToLoginButton;



@end
