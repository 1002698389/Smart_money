//
//  ZMRegisterInViewController.m
//  ZMSD
//
//  Created by zima on 14-11-4.
//  Copyright (c) 2014年 zima. All rights reserved.
//

#import "ZMRegisterInViewController.h"
#import "AllStatusManager.h"

#import "ZMVerifyCodeViewController.h"

#import "ZMNavigationController.h"
#import "ZMPresentWebViewController.h"
//实名认证
#import "ZMRealNameSettingViewController.h"

#import "ZMTools.h"
#import "HUD.h"
#import "PMCustomKeyboard.h"
#import "MobClick.h"
#import "GTCommontHeader.h"

#import "ZMServerAPIs.h"

#import "ZMLogInLogOutViewController.h"

//天蓝色
#define COLOR_FOR_AGREEMENT_BUTTON              [UIColor colorWithRed:102.0/255 green:202.0/255 blue:248.0/255 alpha:1.0]
#define COLOR_FOR_AGREEMENT_BUTTON_HIGHLIGHT    [UIColor colorWithRed:65.0/255 green:178.0/255 blue:251.0/255 alpha:1.0]


//手机号码验证发送成功
#define   ALERTVIEW_TAG_CODE_MobileNumber_OK       9998

//两次密码不同
#define   ALERTVIEW_TAG_DifferentPassword       9999

//注册，手机号码已经存在，不能重复进行注册的验证码获取
#define   ALERTVIEW_TAG_CODE_UserAlreadyExisted_Failed       1000

//找回密码，手机号码不存在数据库中
#define   ALERTVIEW_TAG_CODE_UserNotExisted_Failed           1001



//ProgressHUD的TAG类型

#define ProgressHUD_TAG_FOR_SUCCESS        2000
#define ProgressHUD_TAG_FOR_FAILED         2001
#define ProgressHUD_TAG_FOR_CODE_Invalid   2002

#define TAG_FOR_PhoneNumberTextField       3000
#define TAG_FOR_VerifyCodeTextField        3001
#define TAG_FOR_PasswordTextField          3002
#define TAG_FOR_ConfirmTextField           3002
#define TAG_FOR_InvitationTextField        3003
#define ____IOS7____      ([[[UIDevice currentDevice] systemVersion]floatValue]>=7 && [[[UIDevice currentDevice] systemVersion]floatValue]<7.8)

@interface ZMRegisterInViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIScrollViewDelegate, MBProgressHUDDelegate,UITextFieldDelegate>
{
//    //手机号码输入框
//    UITextField *phoneNumberTextField;
//    UITextField *verifyCodeTextField;
//    
//    UIButton *verificationCodeButton; //获取验证码
    UILabel *countdownLabel;   //显示倒计时
    NSTimer *countdownTimer;
    int countdownNumber ;

//
//    UITextField *passwordTextField;
//    UITextField *confirmTextField;
//    
//    UITextField *sharecodeTextField;
//
//    UIButton *checkAgreeButton;
//    
//    UIButton *nextStepButton;
//    
    UIButton *backToLoginLeftButton;
//    UIButton *backToLoginButton;
    PMCustomKeyboard *customKeyBoard;
//
}
@end

@implementation ZMRegisterInViewController
- (IBAction)backToLoginViewAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"取消"]) {
        [self dismissViewControllerAnimated:YES completion:nil];

    }else if ([sender.titleLabel.text isEqualToString:@"登录"]) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController pushViewController:[[ZMLogInLogOutViewController alloc] init] animated:YES];
        }
    } else if ([sender.titleLabel.text isEqualToString:@"返回"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

//废弃
- (IBAction)registerInFinished:(UIButton *)button
{
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注册"];
    _verificationCodeButton.enabled = YES;
    countdownNumber = 60;

    [_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_verificationCodeButton setBackgroundColor:Color_of_Purple];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [countdownTimer invalidate];
    countdownNumber = 60;
    [MobClick endLogPageView:@"注册"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    [_phoneNumberTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_confirmTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_verifyCodeTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_sharecodeTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    _passwordTextField.delegate = self;
    _confirmTextField.delegate = self;
    _sharecodeTextField.delegate = self;
    [_nextStepButton setBackgroundColor:Color_of_Red];
    _backScrollView.contentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height +50);
    _backScrollView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRegisterInfoStatus:) name:UITextFieldTextDidChangeNotification object:_phoneNumberTextField];

    _checkAgreeButton.selected = YES;
    
    if (self.isForgetPassword){
        self.titleLabel.text = @"找回密码";
        [_nextStepButton setTitle:@"完成" forState:UIControlStateNormal];
        [_nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
        _checkAgreeButton.hidden = YES;
        _agreeLabel.hidden = YES;
        _usingAgreementButton.hidden = YES;
        _downLabel.hidden = YES;
        _backToLoginButton.hidden = YES;
        _sharecodeTextField.hidden = YES;
        _sharecodeView.hidden = YES;
        
    
    } else
        self.title = @"注册";
    
//    if (self.navigationController.viewControllers.count > 1) {
//        [self.goBackButton setTitle:@"返回" forState:UIControlStateNormal];
//    } else {
//        [self.goBackButton setTitle:@"取消" forState:UIControlStateNormal];
//    }
    
    
    float statusBarHeight = 0.0;
    if([[UIApplication sharedApplication] isStatusBarHidden])
        statusBarHeight = 20.0;
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [backgroundImageView setImage:[UIImage imageNamed:@""]];
//    [self.view addSubview:backgroundImageView];
    
    
//    //输入框tableView背板（可上下弹动）
//    UITableView *backgroundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+1 - statusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-2 + statusBarHeight)
//                                                                    style:UITableViewStyleGrouped];
//    [self.view addSubview:backgroundTableView];
//    [backgroundTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    backgroundTableView.allowsSelection = YES;
//    backgroundTableView.delegate = self;
//    backgroundTableView.dataSource = self;
//    [backgroundTableView setBackgroundColor:[UIColor clearColor]];
    
    //协议栏
    
//    UIView *agreementBG = [[UIView alloc] init];
//    if (!self.isForgetPassword) {
//        
//        //协议栏背板
//        
//        agreementBG.frame = CGRectMake(10, 5*61*Ratio_OF_WIDTH_FOR_IPHONE6 + SPACE10_WITH_BORDER, [UIScreen mainScreen].bounds.size.width - 20, 44);
//        
//        NSString *ReadAndAgree = @"我已经阅读并同意";
//        if (Ratio_OF_WIDTH_FOR_IPHONE6 == 1.0) {
//            ReadAndAgree = @"阅读并同意";
//        }
//        else
//        {
//            ReadAndAgree = @"我已经阅读并同意";
//        }
//        //勾选按钮
//        CGSize textSize = [ZMTools calculateTheLabelSizeWithText:ReadAndAgree font:[UIFont systemFontOfSize:14]];
//        
//        float buttonWidth = SPACE10_WITH_BORDER + 30 + SPACE10_WITH_BORDER + textSize.width;
//        
//        checkAgreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [checkAgreeButton setFrame:CGRectMake(-12, 0, buttonWidth, 44)];
//        [checkAgreeButton setImage:[UIImage imageNamed:@"tongyiduigou4.png"] forState:UIControlStateNormal];
//        [checkAgreeButton setImage:[UIImage imageNamed:@"tongyiduigou.png"] forState:UIControlStateSelected];
//        [checkAgreeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [checkAgreeButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
//        [checkAgreeButton setTitleEdgeInsets:UIEdgeInsetsMake(12, 5, 12, -10)];
//        [checkAgreeButton setTitle:ReadAndAgree forState:UIControlStateNormal];
//        [checkAgreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [checkAgreeButton setSelected:YES];
        [_checkAgreeButton addTarget:self action:@selector(checkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [agreementBG addSubview:checkAgreeButton];
//        
//        
//        
//        //协议1按钮
//        CGRect frame = CGRectMake(checkAgreeButton.frame.size.width-12, 0, 180, 44);
//        UIButton *usingAgreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [usingAgreementButton setFrame:frame];
//        [usingAgreementButton setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 10)];
//        [usingAgreementButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        //        [usingAgreementButton setTitleColor:COLOR_FOR_AGREEMENT_BUTTON forState:UIControlStateNormal];
//        //        [usingAgreementButton setTitleColor:COLOR_FOR_AGREEMENT_BUTTON_HIGHLIGHT forState:UIControlStateHighlighted];
//        [usingAgreementButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [usingAgreementButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
//        [usingAgreementButton setTitle:@"《财行家用户服务条款》" forState:UIControlStateNormal];
        [_usingAgreementButton addTarget:self action:@selector(usingAgreementShow:) forControlEvents:UIControlEventTouchUpInside];
//        [agreementBG addSubview:usingAgreementButton];
//        [_backScrollView addSubview:agreementBG];
//        
    
        //免费注册
//        _nextStepButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [nextStepButton setFrame:CGRectMake(SPACE15_WITH_BORDER, agreementBG.bottom + 6, [UIScreen mainScreen].bounds.size.width - SPACE15_WITH_BORDER * 2, 40 * Ratio_OF_WIDTH_FOR_IPHONE6)];
//    
//        [nextStepButton setTitle:@"免费注册" forState:UIControlStateNormal];
//    }
//    else
//    {
//        nextStepButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [nextStepButton setFrame:CGRectMake(SPACE15_WITH_BORDER,
//                                            5*61*Ratio_OF_WIDTH_FOR_IPHONE6 + 44,
//                                            [UIScreen mainScreen].bounds.size.width - SPACE15_WITH_BORDER * 2,
//                                            40 * Ratio_OF_WIDTH_FOR_IPHONE6)];
//        [nextStepButton setTitle:@"完 成" forState:UIControlStateNormal];
//    }
    
    
//    [nextStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [nextStepButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [nextStepButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    
    
//    nextStepButton.enabled = YES;
//    [nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
//    nextStepButton.layer.cornerRadius = 3.0;
    [_nextStepButton addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
//    //返回登陆按钮
//    if (!self.isForgetPassword)
//    {
//        backToLoginLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [backToLoginLeftButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//        _backToLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_backToLoginButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//        
//        CGSize buttonSize = [ZMTools calculateTheLabelSizeWithText:@"已有账号？" font:backToLoginLeftButton.titleLabel.font];
//        CGSize buttonSize2 = [ZMTools calculateTheLabelSizeWithText:@"登录" font:_backToLoginButton.titleLabel.font];
//        float x_offset = (WIDTH_OF_SCREEN - buttonSize.width - buttonSize2.width)/2;
//        [backToLoginLeftButton setFrame:CGRectMake(x_offset,
//                                                   _nextStepButton.bottom + 18,
//                                                   buttonSize.width,
//                                                   40 * Ratio_OF_WIDTH_FOR_IPHONE6)];
//        
//        [backToLoginLeftButton setTitle:@"已有账号？" forState:UIControlStateNormal];
//        [backToLoginLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [backToLoginLeftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        
//        [backToLoginLeftButton addTarget:self action:@selector(backToLoginViewAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_backToLoginButton setFrame:CGRectMake(backToLoginLeftButton.right,
//                                               _nextStepButton.bottom + 18,
//                                               buttonSize2.width,
//                                               40 * Ratio_OF_WIDTH_FOR_IPHONE6)];
//        [_backToLoginButton setTitle:@"登录" forState:UIControlStateNormal];
//        [_backToLoginButton setTitleColor:Color_of_Red forState:UIControlStateNormal];
//        [_backToLoginButton setTitleColor:Color_of_Red forState:UIControlStateHighlighted];
        [_backToLoginButton addTarget:self action:@selector(backToLoginViewAction:) forControlEvents:UIControlEventTouchUpInside];
//
//        [_backScrollView addSubview:backToLoginLeftButton];
//        [_backScrollView addSubview:_backToLoginButton];
//    }
    for (UIView* view in self.view.subviews){
        view.frame = GetFramByXib(view.frame);
        for (UIView* childview in view.subviews){
            childview.frame = GetFramByXib(childview.frame);
//            if (childview == _titleOneView) {
////                childview.frame.size.height = 64;
//                childview.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, 64);
//                
//            }
        }
    }
    _titleOneView.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, 64);
    _goBackButton.frame = CGRectMake(WidthH*10, 30, WidthH*46, 30);
    _titleLabel.frame = CGRectMake(WidthH*120, 30, WidthH*80, 30);
    customKeyBoard = [[PMCustomKeyboard alloc] init];
//    if (WIDTH_OF_SCREEN > 320) {
//         _usingAgreementButton.frame = CGRectMake(145, 252*HeightY, 120*WidthH, 20*HeightY);
//        _backToLoginButton.frame = CGRectMake(155, 391*HeightY, 60*WidthH, 30*HeightY);
//    }
    if (Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)//iPhone6（6 plus真机器）
    {
        _usingAgreementButton.frame = CGRectMake(145, 285*HeightY+3, 120*WidthH, 20*HeightY);
        _backToLoginButton.frame = CGRectMake(170, 419*HeightY+2, 60*WidthH, 30*HeightY);
    }
    else if (Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2) //iPhone6 Plus
    {
        _usingAgreementButton.frame = CGRectMake(145, 285*HeightY+3, 120*WidthH, 20*HeightY);
        _backToLoginButton.frame = CGRectMake(175, 419*HeightY+5, 60*WidthH, 30*HeightY);
    }

    if (WIDTH_OF_SCREEN == 320 && HEIGHT_OF_SCREEN == 480) {
        _backgroundView.frame = CGRectMake(0, 0, 320, 480);
        _backScrollView.frame = CGRectMake(0, 64*HeightY, 320*WidthH, 480);
        _phoneNumberLeftView.frame = CGRectMake(20,43*HeightY ,11 , 22*HeightY);
        _phoneNumberTextField.frame = CGRectMake(39, 43*HeightY, 266, 25*HeightY);
        _phoneNumberT.frame = CGRectMake(13, 67*HeightY, 293, 5*HeightY);
        _passwordLeftView.frame = CGRectMake(16, 89*HeightY, 18, 22*HeightY);
        _passwordTextField.frame = CGRectMake(39, 89*HeightY, 266, 25*HeightY);
        _passwordT.frame = CGRectMake(13, 113*HeightY, 294, 5*HeightY);
        _confirmLeftView.frame = CGRectMake(16, 136*HeightY, 18, 22*HeightY);
        _confirmTextField.frame = CGRectMake(39, 136*HeightY, 266, 25*HeightY);
        _confirmT.frame = CGRectMake(13, 159*HeightY, 293, 5*HeightY);
        _verifyCodeTextField.frame = CGRectMake(21, 182*HeightY, 186, 25*HeightY);
        _verifyCodeT.frame = CGRectMake(13, 205*HeightY, 194, 5*HeightY);
        _verificationCodeButton.frame = CGRectMake(223, 175*HeightY, 82, 30*HeightY);
        _sharecodeTextField.frame = CGRectMake(21, 228*HeightY, 186, 25*HeightY);
        _sharecodeView.frame = CGRectMake(13, 254*HeightY, 194, 5*HeightY);
        _checkAgreeButton.frame = CGRectMake(13, 285*HeightY, 20, 20*HeightY);
        _agreeLabel.frame = CGRectMake(43, 285*HeightY, 115, 20*HeightY);
        _usingAgreementButton.frame = CGRectMake(145, 285*HeightY, 120, 20*HeightY);
        _nextStepButton.frame = CGRectMake(66, 359*HeightY, 185, 41*HeightY);
        _downLabel.frame = CGRectMake(90, 419*HeightY, 85, 30*HeightY);
        _backToLoginButton.frame = CGRectMake(155, 419*HeightY, 60, 30*HeightY);
        
        
        
    }

    [_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_backScrollView endEditing:YES];
    [_phoneNumberTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_verifyCodeTextField resignFirstResponder];
    [_sharecodeView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  是否同意两个用户协议
 *
 *  @param button
 */
- (void)checkButtonAction:(UIButton *)button
{
    if (button.selected) {
        button.selected = NO;
    }else{
        button.selected = YES;
    }
//    button.selected = !button.selected;
//
//    NSLog(@"是否同意协议 = %@", button.selected ? @"不同意" : @"同意");
    
    if (button.selected &&![_phoneNumberTextField.text isEqualToString:@""]) {
        [_nextStepButton setBackgroundColor:Color_of_Red];
        _nextStepButton.enabled = NO;
//        [_nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
        
    }
//    CLog(@"是否同意协议 = %@", button.selected ? @"同意" : @"不同意");
//    
    if (button.selected && ![_phoneNumberTextField.text isEqualToString:@""]) {
        _nextStepButton.enabled = YES;
        [_nextStepButton setBackgroundColor:Color_of_Red];

    }
    else if(!button.selected && ![_phoneNumberTextField.text isEqualToString:@""])
    {
//        _nextStepButton.enabled = YES;
//        [_nextStepButton setBackgroundColor:Color_of_Red];
//        [_nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

/**
 *  检查是否有输入
 *
 *  @param notification
 */
- (void)checkRegisterInfoStatus:(NSNotification *)notification
{
    
    if (self.isForgetPassword)
    {
        if(![_phoneNumberTextField.text isEqualToString:@""])
        {
            _nextStepButton.enabled = YES;
            [_nextStepButton setBackgroundColor:Color_of_Red];
        }
        else{
            _nextStepButton.enabled = NO;
            [_nextStepButton setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    else
    {
        UITextField *tempTextField = (UITextField *)[notification object];
        
        CLog(@"tempTextField = %@", tempTextField.text);
        
        if (tempTextField.tag == TAG_FOR_PhoneNumberTextField) {
            
        }
        else if (tempTextField.tag == TAG_FOR_VerifyCodeTextField)
        {
        }
        else if (tempTextField.tag == TAG_FOR_PasswordTextField)
        {
        }
        else if(tempTextField.tag == TAG_FOR_ConfirmTextField)
        {
        }
        else if(tempTextField.tag == TAG_FOR_InvitationTextField)
        {
        }
        
        //判断是否都有输入，并且同意注册协议
        if(![_phoneNumberTextField.text isEqualToString:@""] &&
           ![_verifyCodeTextField.text isEqualToString:@""] &&
           ![_passwordTextField.text isEqualToString:@""] &&
           ![_confirmTextField.text isEqualToString:@""] &&
           _checkAgreeButton.selected)
        {
            _nextStepButton.enabled = YES;
            [_nextStepButton setBackgroundColor:Color_of_Red];
        }else{
        
        
        }
    }
}

/**
 *  使用协议
 *
 *  @param button
 */
-(void)usingAgreementShow:(UIButton *)button
{
    //Using present style
    ZMPresentWebViewController *webViewNext = [[ZMPresentWebViewController alloc]init];
    [webViewNext setValue:[NSNumber numberWithBool:NO] forKey:@"isWebURL"];//进去加载用户协议
    [webViewNext setValue:@"http://www.baidu.com" forKey:@"vkey"];
    [webViewNext setValue:@"用户服务条款" forKey:@"vtitle"];
    ZMNavigationController *navigationVC = [[ZMNavigationController alloc]initWithRootViewController:webViewNext];
    
    [self.navigationController presentViewController:navigationVC animated:YES completion:^{
        
    }];
}

/**
 *  隐私保护协议
 *
 *  @param button
 */
-(void)privacyAgreementShow:(UIButton *)button
{
    ZMPresentWebViewController *webViewNext = [[ZMPresentWebViewController alloc]init];
    [webViewNext setValue:@"http://www.baidu.com" forKey:@"vkey"];
    
    ZMNavigationController *navigationVC = [[ZMNavigationController alloc]initWithRootViewController:webViewNext];
    
    [self.navigationController presentViewController:navigationVC animated:YES completion:^{
        
    }];
}

/**
 *  重新获取手机验证码
 *
 *  @param button
 */
- (IBAction)requestVerificationCodeAction:(UIButton *)button
{
    if([_phoneNumberTextField.text isEqualToString:@""])
    {
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"手机号不能为空哦"];
        return;
    }
    
    if(![ZMTools isPhoneNumber:_phoneNumberTextField.text])
    {
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"手机号有误!"];
        return;
    }
    button.enabled  = NO;
    if (self.isForgetPassword) {//找回密码
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"验证码获取中"];
        button.backgroundColor = [UIColor grayColor];
        
        [[ZMServerAPIs shareZMServerAPIs] requestVerifyCodeWithUID:_phoneNumberTextField.text withMessageType:@"FORGOT" Success:^(id response) {
            button.enabled = YES;
            CLog(@"找回密码 请求验证码成功，response == %@", response);
            
            if ([[response objectForKey:@"code"] intValue] == 1000) {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitTimeWhenRegistGetRandom:) userInfo:button repeats:YES];
                    [countdownTimer fire];
                    
                    [[HUD sharedHUDText] showForTime:1.5 WithText:@"验证码发送成功，请注意查收"];
                    //计时开始
                    [button setBackgroundColor:[UIColor lightGrayColor]];
                    
                    return;
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUD sharedHUDText] showForTime:1.5 WithText:[response objectForKey:@"message"]];
                    [_verificationCodeButton setBackgroundColor:Color_of_Purple];
                });
            }
            
        } failure:^(id response) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                button.enabled = YES;
                //网络异常
                if(nil == response)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络异常，请稍候再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
                        [alter show];
                    });
                    return ;
                }
                
                if ([[response objectForKey:@"code"] integerValue] == 2002) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"用户不存在" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
                        
                        alter.tag = ALERTVIEW_TAG_CODE_UserAlreadyExisted_Failed;
                        [alter show];
                        return;
                    });
                }
                
                //发送失败
                if ([[response objectForKey:@"code"] integerValue] == 1001)
                {
                    CLog(@"response == %@", response);
                }
            });
        }];
    }
    else
    {
        button.enabled  = NO;
        //注册获取验证码
        [[ZMServerAPIs shareZMServerAPIs] requestVerifyCodeWithUID:_phoneNumberTextField.text withMessageType:@"RIGIST" Success:^(id response) {
            
            CLog(@"找回密码 请求验证码成功，response == %@", response);
            button.enabled = YES;
            
            if ([[response objectForKey:@"code"] intValue] == 1000) {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitTimeWhenRegistGetRandom:) userInfo:button repeats:YES];
                    [countdownTimer fire];
                    
                    [[HUD sharedHUDText] showForTime:1.5 WithText:@"验证码发送成功，请注意查收"];
                    //计时开始
                    [button setBackgroundColor:[UIColor lightGrayColor]];
                    
                    return;
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUD sharedHUDText] showForTime:1.5 WithText:[response objectForKey:@"message"]];
                });
            }
            
        } failure:^(id response) {
            
            button.enabled  = YES;
            CLog(@"获取验证码失败：   %@", response);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //网络异常
                if(nil == response)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络异常，请稍候再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
                        [alter show];
                    });
                    return ;
                }
                //注册－获取验证码 接收到的数据：{"message":"发送失败","code":"2000"}
                if ([[response objectForKey:@"code"] integerValue] == 2000) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您已经是注册用户，请直接登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
                        alter.tag = ALERTVIEW_TAG_CODE_UserAlreadyExisted_Failed;
                        [alter show];
                        return;
                    });
                }
                
                
                //{"message":"发送失败","data":{"},"code":1001}
                //发送失败
                if ([[response objectForKey:@"code"] integerValue] == 1001)
                {
                    CLog(@"response == %@", response);
                }
                else
                {
                }
            });
        }];
    }
}


-(void)waitTimeWhenRegistGetRandom:(NSTimer *)Timer
{

        if (countdownNumber >= 1) {
            if (____IOS7____) {
                _verificationCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                _verificationCodeButton.titleLabel.text = [NSString stringWithFormat:@"%d秒", countdownNumber];
            }else{
                _verificationCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                [_verificationCodeButton setTitle:[NSString stringWithFormat:@"%d秒", countdownNumber] forState:UIControlStateNormal];
            }
            countdownNumber = countdownNumber-1;
            _verificationCodeButton.enabled = NO;
        }
        else if(countdownNumber == 0)
        {
            //恢复计数数值
            countdownNumber = 60;
            
            _verificationCodeButton.enabled = YES;
            [_verificationCodeButton setBackgroundColor:Color_of_Purple];
            [_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            //计时器失效
            [countdownTimer invalidate];
        }
}



/**
 *  确认注册／找回密码
 *
 *  @param button
 */
- (IBAction)registerAction:(UIButton *)button
{
#warning 判断密码是否相同
    if(![_passwordTextField.text isEqualToString:_confirmTextField.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"密码输入不一致, 请重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = ALERTVIEW_TAG_DifferentPassword;
        [alertView show];
        
        return;
    }
    
#warning 判断密码位数正确
    if (_passwordTextField.text.length < 6) {
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"密码不能少于6位哦"];
        return;
    }
    else if (_passwordTextField.text.length > 16)
    {
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"密码不能超过16位哦"];
        return;
    }
    
    
    if (_sharecodeTextField.text.length != 6 && _sharecodeTextField.text.length != 0){
        
        [[HUD sharedHUDText] showForTime:1.5 WithText:@"请输入正确邀请码"];
        
        return;
    }else if (_sharecodeTextField.text.length == 0)
    {
        
    }
    if (!self.isForgetPassword) {
        if (!_checkAgreeButton.selected) {
            [[HUD sharedHUDText] showForTime:1.5 WithText:@"请同意用户协议"];
            return;
        }
        
    }
    
    MBProgressHUD *ProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ProgressHUD.delegate = self;
    ProgressHUD.mode = MBProgressHUDModeIndeterminate;
    ProgressHUD.animationType = MBProgressHUDAnimationFade;
    
    if (self.isForgetPassword) {
        
        [ProgressHUD setLabelText:@"找回中..."];
        
        [[ZMServerAPIs shareZMServerAPIs] forgotPasswordPhoneNumber:_phoneNumberTextField.text Password:_passwordTextField.text Code:_verifyCodeTextField.text Success:^(id response) {
            
            CLog(@"密码修改成功 %@", response);
            dispatch_async(dispatch_get_main_queue(), ^{
                ProgressHUD.tag = ProgressHUD_TAG_FOR_SUCCESS;
                [ProgressHUD setLabelText:@"修改密码成功"];
                [ProgressHUD hide:YES afterDelay:1.5];
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(changeView) userInfo:nil repeats:NO];
                //计时器失效
                [countdownTimer invalidate];

                
            });
            
        } failure:^(id response) {
            CLog(@"修改失败 %@", response);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(nil == response)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                        [ProgressHUD setLabelText:@"修改密码失败"];
                        [ProgressHUD hide:YES afterDelay:1.5];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:@"网络异常，请稍候再试"
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好的", nil];
                        [alert show];
                    });
                }
                else if ([[response objectForKey:@"code"] integerValue] == 1000)
                {
                    ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                    [ProgressHUD setLabelText:[response objectForKey:@"message"]];
                    [ProgressHUD hide:YES afterDelay:2.0];
                }
                else
                {
                    //{"message":"验证码错误","code":"2000"}
                    ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                    [ProgressHUD setLabelText:[response objectForKey:@"message"]];
                    [ProgressHUD hide:YES afterDelay:2.0];
                }
                
                //计时器失效
                //恢复计数数值
                dispatch_async(dispatch_get_main_queue(), ^{
                    countdownNumber = 60;
                    _verificationCodeButton.enabled = YES;
                    [_verificationCodeButton setBackgroundColor:Color_of_Purple];
                    [_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [countdownTimer invalidate];
                });
            });
        }];
    }
    
    
    
    else
    {
        [ProgressHUD setLabelText:@"注册中..."];
        
//        
        [[ZMServerAPIs shareZMServerAPIs] registerPhoneNumber:_phoneNumberTextField.text Password:_passwordTextField.text Code:_verifyCodeTextField.text shareCode:_sharecodeTextField.text Success:^(id response) {
        
//        [[ZMServerAPIs shareZMServerAPIs] registerPhoneNumber:_phoneNumberTextField.text Password:_passwordTextField.text Code:_verifyCodeTextField.text Success:^(id response) {
            CLog(@"注册成功 %@", response);
            
            //获取并保存loginKey
            if ([[response objectForKey:@"code"] integerValue] == 1000) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString * loginKey = [[response objectForKey:@"data"] objectForKey:@"loginKey"];
                    [[ZMAdminUserStatusModel shareAdminUserStatusModel] saveLoginKey:loginKey];
                });
            }
            
            //保存用户名和密码
            [[ZMAdminUserStatusModel shareAdminUserStatusModel] saveUserId:_phoneNumberTextField.text password:_passwordTextField.text];
            //设置为登录状态
            [[ZMAdminUserStatusModel shareAdminUserStatusModel] setLoggedStatus:YES];
            
            //自动更新用户数据
            [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateAdminUserInfoFromServer];
            
            
            //重新刷新设置界面的列表
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SETTING_VIEW_NOTIFICATION_NAME object:nil];
            
            
            //百度统计
            //            [[BaiduMobStat defaultStat] logEvent:@"register" eventLabel:@"注册成功"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ProgressHUD.tag = ProgressHUD_TAG_FOR_SUCCESS;
                [ProgressHUD setLabelText:@"注册成功"];
                [ProgressHUD hide:YES afterDelay:1.5];
                
                //计时器失效
                [countdownTimer invalidate];
            });
            
        } failure:^(id response) {
            //{"message":"验证码已失效","code":"2000"}
            if ([[response objectForKey:@"code"] integerValue] == 2000) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ProgressHUD.tag = ProgressHUD_TAG_FOR_CODE_Invalid;
                    //[ProgressHUD setLabelText:@"验证码已实效"];
                    [ProgressHUD setLabelText:[response objectForKey:@"message"]];
                    [ProgressHUD hide:YES afterDelay:1.5];

                });
            }
            //{"message":"该手机号已经被注册","code":"3001"}
            else if ([[response objectForKey:@"code"] integerValue] == 3001)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                    //[ProgressHUD setLabelText:@"注册失败"];
                    [ProgressHUD setLabelText:[response objectForKey:@"message"]];
                    [ProgressHUD hide:YES afterDelay:1.5];

                });
            }
            else
            {
                if(nil == response)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                        [ProgressHUD setLabelText:@"注册失败"];
                        [ProgressHUD hide:YES afterDelay:1.5];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:@"网络异常，请稍候再试"
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好的", nil];
                        [alert show];


                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ProgressHUD.tag = ProgressHUD_TAG_FOR_FAILED;
                        [ProgressHUD setLabelText:@"注册失败"];
                        [ProgressHUD setLabelText:[response objectForKey:@"message"]];
                        [ProgressHUD hide:YES afterDelay:1.5];


                    });
                }
            }
            
            //计时器失效
            //恢复计数数值
            dispatch_async(dispatch_get_main_queue(), ^{
                countdownNumber = 60;
                _verificationCodeButton.enabled = YES;
                [_verificationCodeButton setBackgroundColor:Color_of_Purple];
                [_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [countdownTimer invalidate];
            });
        }];
    }
}

//忘记密码 找回密码后跳回到登录界面
-(void)changeView{
    [self.navigationController popToRootViewControllerAnimated:YES];

}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERTVIEW_TAG_DifferentPassword) {
        _passwordTextField.text = @"";
        _confirmTextField.text = @"";
    }
    
    //成功 进入下一步
    if (alertView.tag == ALERTVIEW_TAG_CODE_MobileNumber_OK) {
        return;
        
        //        if (buttonIndex == 0) {
        //            return;
        //        }
        //        else if(buttonIndex == 1)
        //        {
        //            ZMVerifyCodeViewController *verifyCodeVC = [[ZMVerifyCodeViewController alloc]init];
        //
        //            verifyCodeVC.isFromAppDelegate = _isFromAppDelegate;  //从App delegate过来的。
        //
        //            if(self.isForgetPassword)
        //            {
        //                verifyCodeVC.isForgetPassword = YES;
        //            }
        //            else
        //            {
        //                verifyCodeVC.isForgetPassword = NO;
        //            }
        //
        //            [verifyCodeVC setValue:[NSString stringWithFormat:@"%@", phoneNumberTextField.text] forKey:@"telephoneNumber"];
        //
        //            [self.navigationController pushViewController:verifyCodeVC animated:YES];
        //        }
    }
    
    else if (alertView.tag == ALERTVIEW_TAG_CODE_UserAlreadyExisted_Failed)
    {
        [self.navigationController popViewControllerAnimated:YES];   //号码存在返回登录界面
    }
    
    else if (alertView.tag == ALERTVIEW_TAG_CODE_UserNotExisted_Failed)
    {
    }
}
#pragma mark--滑动代理delegate

//上下滑动scroll 用于隐藏输入法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_phoneNumberTextField resignFirstResponder];
    [_verifyCodeTextField resignFirstResponder];
    self.view.transform = CGAffineTransformIdentity;
    [_passwordTextField resignFirstResponder];
    [_confirmTextField resignFirstResponder];
    [_sharecodeTextField resignFirstResponder];
}


#pragma mark--------------MBProgressHUD delegate----------------
/**
 * Called after the HUD was fully hidden from the screen.
 */
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    
    switch (hud.tag) {
        case ProgressHUD_TAG_FOR_SUCCESS:
            if (self.isFromAppDelegate) {
                //                [self finishedLogin:nil];
//                [self dismissViewControllerAnimated:YES completion:^{
//                    //完全退出登录注册页面
//                }];
                ZMRealNameSettingViewController *next = [[ZMRealNameSettingViewController alloc] init];
                next.isRegiste = YES;
                [self.navigationController pushViewController:next animated:YES];
                
            }
            else
            {
//                [self dismissViewControllerAnimated:YES completion:^{
//                    //完全退出登录注册页面
//                }];
                ZMRealNameSettingViewController *next = [[ZMRealNameSettingViewController alloc] init];
                next.isRegiste = YES;
                [self.navigationController pushViewController:next animated:YES];
            }
            break;
        case ProgressHUD_TAG_FOR_FAILED:
        {
            
        }
            break;
        case ProgressHUD_TAG_FOR_CODE_Invalid:
        {
            
        }
            break;
        default:
            break;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _passwordTextField) {
        [customKeyBoard setTextView:_passwordTextField];
    }else if (textField == _confirmTextField){
        [customKeyBoard setTextView:_confirmTextField];
    }

    if(textField  == _confirmTextField | textField == _sharecodeTextField)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _backScrollView.transform = CGAffineTransformMakeTranslation(0, -customKeyBoard.frame.size.height/2);
        }];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [UIView animateWithDuration:0.5 animations:^{
        _backScrollView.transform = CGAffineTransformIdentity;
    }];
    
}


@end
