//
//  RechargeViewController.m
//  ZiMaCaiHang
//
//  Created by 陈柳充 on 15/4/30.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "RechargeViewController.h"
#import "ZMRealNameSettingViewController.h"
#import "HUD.h"
#import "RechangeSuccessViewController.h"
#import "MobClick.h"

#define ALERTVIEW_TAG_REALNAME_VALIDATE              1000           //需要实名认证

#define ALERTVIEW_TAG_RECHARGE_RESULT                1001           //充值结果

@interface RechargeViewController ()<LLPaySdkDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    NSMutableDictionary *orderParam;
    NSMutableArray * bankCardArray;
    
    NSString * currentInputString;
    NSMutableString *bankNumber;
    NSTimer *_timer;
    int countTimer;
    NSMutableString *CarName;
}
@end

@implementation RechargeViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"充值"];
    countTimer = 1;
    CLog(@"充值页面 viewWillAppear = %@", self.selectedBankInfo);
    
//    self.cardTextField.text = [ZMTools hideBankCardNumber:[self.selectedBankInfo objectForKey:@"cardNumber"]];
    
    
    //计算¥字符号初始的位置
//    self.rechargeTextField.text = @"1000";
//    [self updateInputWidth: self.rechargeTextField.text];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rechargeTextField resignFirstResponder];
    [MobClick endLogPageView:@"充值"];
}
- (void)viewDidLoad {
        [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem =  [ZMTools item:@"DetailBackButton" target:self select:@selector(backVC)];
    [self getUserBankList];
    [self createButton];
    self.title = @"充值";
    CLog(@"充值页面 viewDidLoad = %@", self.selectedBankInfo);
    self.rechargeTextField.delegate = self;
    self.rechargeTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.cardTextField.placeholder = @"请输入银行卡号";
    self.cardTextField.delegate = self;
    self.cardTextField.tag = 1009;
    orderParam = [NSMutableDictionary dictionary];
    
    self.bVerifyPayState = YES;
    [self.rechargeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
}

/*
 "data":{
            "userBanks":
                        [
                        {"id":18970,
                        "imgPath":"",
                        "cardNumber":"6217000010044729435",
                        "cardName":"中国建设银行",
                        "branchName":"中国建设银行股份有限公司北京安宁庄支行",
                        "city":{"id":1,"province":"  北京市 ","name":" 北京市 ","cityCode":"  110000 ","provinceCode":"  110000 "},
                        "default":true}
                        ]},
            "code":1000}
 */

- (void)getUserBankList
{
    MBProgressHUD *HUDjz = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUDjz setLabelText:@"加载ing..."];
    [[ZMServerAPIs shareZMServerAPIs] getUserBankListForWithdraw:NO Success:^(id response)
     {
         dispatch_async(dispatch_get_main_queue(), ^(){
             [HUDjz hide:YES afterDelay:1.0];
             if (!bankCardArray.count>0) {
                 
                 CLog(@"%@",[response objectForKey:@"data"]);
                 NSMutableArray *tempBankCardArray = [[response objectForKey:@"data"] objectForKey:@"userBanks"];
                 for (NSDictionary *dict in tempBankCardArray) {
                     
                     CarName = [[NSMutableString alloc] initWithString:[dict objectForKey:@"cardNumber"]];
                     CLog(@"%@",CarName);
                     bankNumber = [NSMutableString stringWithFormat:@"%@",CarName];
                     [bankNumber replaceCharactersInRange:NSMakeRange(4, 11) withString:@"***********"];
                     self.cardTextField.text = bankNumber;
                     CLog(@"%@",CarName);
                     
                 }
                 if ([ZMTools isNullObject:tempBankCardArray]) {
                     CLog(@"银行卡数据为空");
                     return ;
                 }
             }else{
                 [bankCardArray removeAllObjects];
                 NSMutableArray *tempBankCardArray = [[response objectForKey:@"data"] objectForKey:@"userBanks"];
                 if ([ZMTools isNullObject:tempBankCardArray]) {
                     CLog(@"银行卡数据为空");
                     return ;
                 }
             }
         });
         CLog(@"用户银行卡列表：success = %@", response);
         
         
     }
                                                         failure:^(id response){
                                                             CLog(@"用户银行卡列表：failed = %@", response);
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [HUDjz setLabelText:@"网络异常"];
                                                                 [HUDjz hide:YES afterDelay:1.0];
                                                             });
                                                             
                                                             
                                                             //        {"message":"没有找到符合条件的数据","code":4003}
                                                             
                                                             if([[response objectForKey:@"code"] integerValue] == 4003)
                                                             {
                                                                 CLog(@"%@", [response objectForKey:@"message"]);
                                                             }
                                                         }];
    
}

- (void)backVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)createButton
{
    _nextStepButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_nextStepButton setFrame:CGRectMake(35, 250, WIDTH_OF_SCREEN - 70, 43)];
    [_nextStepButton setTitle:@"确认充值" forState:UIControlStateNormal];
    [_nextStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextStepButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_nextStepButton setBackgroundColor:Color_of_Red];
    [_nextStepButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    
    //默认情况下为非响应状态：
    _nextStepButton.layer.cornerRadius = 3.0;
    [_nextStepButton addTarget:self action:@selector(confirmRechargeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextStepButton];
}

/*
 * 确认充值
 */
-(void)confirmRechargeAction:(UIButton *)button
{
    /*
     {
     cardName = "\U4e2d\U56fd\U5efa\U8bbe\U94f6\U884c";
     cardNumber = 6217003810007667994;
     default = 1;
     id = 233;
     imgPath = "";
     }
     */
    
    button.enabled = NO;
    //判断是否实名认证？ {"message":"账户昵称15528385681，身份信息未通过验证","code":"2000"}
    
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel].adminuserBaseInfo.idCard isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"请先进行身份认证"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"好的", nil];
        alert.tag = ALERTVIEW_TAG_REALNAME_VALIDATE;
        [alert show];
        return;
    }
    
    
    //银行卡
//    NSString *bankCardNumber = [self.selectedBankInfo objectForKey:@"cardNumber"];
//    NSString *bankCardNumber = [self.selectedBankInfo objectForKey:@"cardNumber"];
    
    
    /*
     * 判断银行卡是否是正确的银行卡
     */
//    BOOL isBankNumber = [ZMTools validateBankCardNumber:bankCardNumber];
//   
//    if (!isBankNumber) {
//        [[HUD sharedHUDText] showForTime:2.0 WithText:@"银行卡号有误!"];
//        return;
//    }
    

    //输入金额
    double rechargeAmount = [self.rechargeTextField.text doubleValue];
    if(rechargeAmount <= 0)
    {
        self.rechargeTextField.text = @"";
        [[HUD sharedHUDText] showForTime:2.0 WithText:@"充值金额不能小于等于0元"];
        button.enabled = YES;
        return;
    }
    
    
    //测试数据
//    rechargeAmount = 0.01;
//    bankCardNumber = @"6212264402019909294";
    
    
    [[ZMServerAPIs shareZMServerAPIs] rechargeWithAmount:rechargeAmount andBankCardNumber:CarName Success:^(id response) {
        CLog(@"获取订单信息： 成功  response  == %@", response);
        CLog(@"%@",CarName);
        NSDictionary *orderDic = [[[response objectForKey:@"data"] objectForKey:@"rechargeData"] mutableCopy];
        
        /*
         * 执行订单
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self payWithSignedOrder:orderDic];
        });
    
        /*
         {
         code = 1000;
         data =     {
         
         rechargeData =         
         {
         "acct_name" = "\U6885\U5143\U52cb";
         "busi_partner" = 101001;
         "card_no" = 6222629530002718832;
         "dt_order" = 20150515160003;
         "id_no" = 429001198512150811;
         "id_type" = 0;
         "money_order" = "1.0";
         "name_goods" = "\U7d2b\U9a6c\U8d22\U884c\U624b\U673a\U5145\U503c";
         "no_order" = 20150515160003000000000000000811;
         "notify_url" = "http://182.92.6.163:8080/lianlian/notify";
         "oid_partner" = 201503241000256503;
         "risk_item" = "{\"user_info_full_name\":\"\U6885\U5143\U52cb\",\"user_info_identify_type\":3,\"user_info_dt_register\":\"20150128191050\",\"frms_ware_category\":\"2009\",\"user_info_id_type\":0,\"user_info_identify_state\":1,\"user_info_bind_phone\":\"13982159245\",\"user_info_id_no\":\"429001198512150811\",\"user_info_mercht_userno\":\"811\"}";
         sign = "sffCOq5hfZLgLfLSxyWqzta1LVo700TD1O5/di8jrHc/sHLTWiMXuuRuenF/ta2KfNhpxv6B9eO4hhYjroiEnBn8fahKnM3esy3RDMtad7IDWEozXa/h2i/+wAgtCoV6J5UdeeTC8eJe9gVATT5QzJb3rhnpsolCjMdhTTaLAr0=";
         "sign_type" = RSA;
         "user_id" = 811;
         };
         
         };
         message = "recharge.order.success";
         }
         */
        button.enabled = YES;
        
        
    } failure:^(id response) {
        CLog(@"confirmRecharge 失败  response  == %@", response);
        
        //        {"message":"充值失败","code":2002}
//        {"message":"不能更换银行卡快捷支付","code":2000}
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[response objectForKey:@"code"] integerValue] == 2000)
            {
                [[HUD sharedHUDText] showForTime:2.0 WithText:[response objectForKey:@"message"]];
                button.enabled = YES;
            }
            else
            {
                [[HUD sharedHUDText] showForTime:2.0 WithText:@"充值失败"];
                button.enabled = YES;
            }
        });
        
        return;
    }];
}


/*
 * 执行订单
 */
- (void)payWithSignedOrder:(NSDictionary*)signedOrder
{
    CLog(@"signedOrder === %@", signedOrder);
    
    self.sdk = [[LLPaySdk alloc] init];
    self.sdk.sdkDelegate = self;
    
    // 切换认证支付与快捷支付，假如并不需要切换，可以不调用这个方法
    [LLPaySdk setVerifyPayState:self.bVerifyPayState];
    
    [self.sdk presentPaySdkInViewController:self withTraderInfo:signedOrder];
}



#pragma -mark ------------ 支付结果 LLPaySdkDelegate ---------------
// 订单支付结果返回，主要是异常和成功的不同状态
- (void)paymentEnd:(LLPayResult)resultCode withResultDic:(NSDictionary *)dic
{
    NSString *msg = @"支付异常";
    switch (resultCode) {
        case kLLPayResultSuccess:
        {
            msg = @"支付成功,第三方处理中,请耐心等候!";
            
            NSString* result_pay = dic[@"result_pay"];
            if ([result_pay isEqualToString:@"SUCCESS"])
            {
                //
            }
            else if ([result_pay isEqualToString:@"PROCESSING"])
            {
                msg = @"支付单处理中";
            }
            else if ([result_pay isEqualToString:@"FAILURE"])
            {
                msg = @"支付单失败";
            }
            else if ([result_pay isEqualToString:@"REFUND"])
            {
                msg = @"支付单已退款";
            }
        }
            break;
        case kLLPayResultFail:
        {
            msg = @"支付失败";
        }
            break;
        case kLLPayResultCancel:
        {
            msg = @"支付取消";
        }
            break;
        case kLLPayResultInitError:
        {
            msg = @"sdk初始化异常";
        }
            break;
        case kLLPayResultInitParamError:
        {
            msg = dic[@"ret_msg"];
        }
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
        alert.tag = ALERTVIEW_TAG_RECHARGE_RESULT;
        [alert show];
    });

    
    
    
}


#pragma - mark ------------ UIAlertView Delegate ---------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //进行实名认证
    if (alertView.tag == ALERTVIEW_TAG_REALNAME_VALIDATE) {
        if(buttonIndex == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ZMRealNameSettingViewController * next = [[ZMRealNameSettingViewController alloc] init];
                next.isAlreadyAuthen = NO;
                next.realNameAuthenticationBlock = ^(BOOL isAuthentication){
                    if (isAuthentication) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            CLog(@"充值的时候：实名认证成功了");
                            
//                            [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserBaseInfo];
                            
                        });
                    }
                };
                
                [self.navigationController pushViewController:next animated:YES];
            });
        }
        
        else
        {
            return;
        }
    }
    
    
    
    /*
     * 支付成功
     */
    else if (alertView.tag == ALERTVIEW_TAG_RECHARGE_RESULT) {
        
        if([alertView.message isEqualToString:@"支付成功,第三方处理中,请耐心等候!"])
        {
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.25*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                RechangeSuccessViewController *rechangeSVC = [[RechangeSuccessViewController alloc]init];
                rechangeSVC.title = @"充值成功";
                rechangeSVC.rechangeMoney = self.rechargeTextField.text;
                [self.navigationController pushViewController:rechangeSVC animated:YES];
            });
            
            _timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(updateCount:) userInfo:nil repeats:YES];
            
            //    [[NSRunLoop  currentRunLoop] addTimer:myTimerforMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
            [_timer fire];
            //            [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserBaseInfo];
            //            [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserAssert];
            //            [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserAccount];
            //            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }

}
- (void)updateCount:(NSTimer *)timer
{
//    countTimer= countTimer+1;
    countTimer++;
    if(countTimer==5)
    {
        [timer invalidate];
    }
    else
    {
        CLog(@"这个是定时器");
        [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserBaseInfo];
        [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserAssert];
        [[ZMAdminUserStatusModel shareAdminUserStatusModel] updateUserAccount];
    }
}


#pragma mark --- 点击空白处键盘收回
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_rechargeTextField resignFirstResponder];
    
}
#pragma mark --- 限制充值金额输入框的长度
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.rechargeTextField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
}

#pragma mark UITextField delegate ------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
{
    CLog(@"ShouldBegin ===  %@", textField.text);
    
    if (textField.tag == 1009) {
        return NO;
    }

    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    CLog(@"DidBegin ===  %@", textField.text);
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    CLog(@"ShouldEnd ===  %@", textField.text);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CLog(@"DidEnd ===  %@", textField.text);
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *tempString = [NSMutableString stringWithString: textField.text];
    
    //    CLog(@"zxhzhxhzhxhzhxhzhxh    %@, %@, %d", textField.text, string, range.location);
    
    if([string isEqualToString:@""] && range.location != 0)
    {
        [tempString deleteCharactersInRange:NSMakeRange(range.location, 1)];
    }
    else if ([string isEqualToString:@""] && range.location == 0)
    {
        if ([textField.text length] > 0)
        {
            [tempString deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    else
    {
        [tempString insertString:string atIndex:range.location];
    }
    
    CLog(@"输入的金额是多少？    %@", tempString);
    
    currentInputString = tempString;

//    [self updateInputWidth:currentInputString];
    
    return YES;
}


-(void)updateInputWidth:(NSString *)moneyStr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize tempSize = [ZMTools calculateTheLabelSizeWithText:moneyStr font:self.rechargeTextField.font];
        self.moneyRightAlign.constant = tempSize.width;
        
        
        
//    CGRect tempFrame = self.rechargeTextField.frame;
    
//    self.rechargeTextField.frame = CGRectMake(WIDTH_OF_SCREEN - 8 - tempSize.width,
//                                           tempFrame.origin.y,
//                                           tempSize.width,
//                                           tempFrame.size.height);
    
        
        
//    CGRect tempFlagFrame = self.moneyRMBFlag.frame;
//    self.moneyRMBFlag.frame = CGRectMake(300,
//                                         tempFlagFrame.origin.y,
//                                         tempFlagFrame.size.width,
//                                         tempFlagFrame.size.height);
    
//    CLog(@"211  x = %f, x = %f",
//         WIDTH_OF_SCREEN - 8 - tempSize.width - tempFlagFrame.size.width,
//         self.moneyRMBFlag.frame.origin.x);
    
//    CLog(@"222   =%f, %f", tempSize.width,  tempFlagFrame.size.width);
    
//    [self.moneyRMBFlag layoutSubviews];
        
        });
}

@end
