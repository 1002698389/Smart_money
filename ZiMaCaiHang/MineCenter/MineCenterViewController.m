//
//  MineCenterViewController.m
//  ZiMaCaiHang
//
//  Created by zhangxh on 15-4-17.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "MineCenterViewController.h"

#import "MineCenterHeaderCell6Plus.h"

#import "MineCenterCell.h"

#import "ZMSafeSettingsViewController.h"

#import "BankCardTableViewController.h"

#import "AssetManagementViewController.h"

#import "MessageViewController.h"

#import "HXChangJianQuestion.h"

#import "RizibaoTableViewController.h"

#import "HXImageEdtingViewController.h"
#import "ModifyUserInfoViewController.h"
#import "AModifyUserInfoViewController.h"

//提现
#import "GetCashViewIp4ViewController.h"
#import "GetCashViewController.h"
//充值
#import "BankCardTableViewControllerForRecharge.h"
#import "RechargeViewController.h"

//#import "UIImageView+WebCacheAddition.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "InvestRecoderViewController.h"
#import "CashHistoryViewController.h"
#import "BackCashViewController.h"
#import "HUD.h"
#import "AppDelegate.h"
#import "AddBankCardViewController.h"
#import "ZMRealNameSettingViewController.h"
//#import "HeadBackViewCell.h"

#import "InvitefriendsViewController.h"
#import "GTCommontHeader.h"
#import "Reachability.h"
#import "sendRedPackController.h"
#import "MineRewardViewController.h"
#import "HHAlertView.h"

//static NSString *reuseCellIndentifier5 = @"MineCenterHeaderCell5";
//static NSString *reuseCellIndentifier6 = @"MineCenterHeaderCell6";
//static NSString *reuseCellIndentifier6Plus = @"MineCenterHeaderCell6Plus";

@interface MineCenterViewController ()<UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, getCLipImage,HHAlertViewDelegate, UITableViewDataSource,UITableViewDelegate,cellDelegate>
{
    NSString *reuseCellIndentifier;
    NSArray * cellInfoArray;
    
    //拍照所得图片
    //    UIImage * ;
    AppDelegate *_appdelegate;
    //消息数量
    UILabel *messageCountLabel;
    NSLayoutConstraint *messageCountWidth;
    MBProgressHUD *_hud;
    BOOL changeViewBtnSelect;
    NSString *headBackIdenty;
    UIButton *_upDownBtn;
    //    UIImageView *_headBackView;
    NSIndexPath *_indexPath;
    UIButton *redButton;
    NSString *allStr;
    NSString *mineCell;
    NSString *totalWaitingProfit;
    NSString *availablePoints;
    NSNumber *frozenPoints;
    NSNumber *waittingPrincipal;
    NSString *redNum;
    
}
@property(nonatomic , retain) UIImage * userHeaderImage;
@end
@implementation MineCenterViewController
{
    BackCashViewController *backCash;
    InvestRecoderViewController *recoderINVC;
    CashHistoryViewController *cashHVC;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showAlertWithLoginView];
    [self createMainView];
    [self.mainTableView reloadData];
    
    //获取消息总数
    //    [self getMessageCount];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"show" object:nil];
}

- (void)enRefinshe
{
    //    [self.mainTableView reloadData];
    [self updateCurrentAmount];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    _mainTableView.frame = CGRectMake(0, 160, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN-160-49);
    
    _leiJiLabel.frame = CGRectMake(WIDTH_OF_SCREEN/320*40, HEIGHT_OF_SCREEN/568*9, WIDTH_OF_SCREEN/320*240, HEIGHT_OF_SCREEN/568*21);
    _leiJiLabel.font =  [UIFont systemFontOfSize:GTFixHeightFlaot(16)];
    
    _titleTotalAmount.frame = CGRectMake(WIDTH_OF_SCREEN/320*40, HEIGHT_OF_SCREEN/568*68, WIDTH_OF_SCREEN/320*240, HEIGHT_OF_SCREEN/568*17);
    _titleTotalAmount.font = [UIFont systemFontOfSize:GTFixHeightFlaot(14)];
    
    _totalAlreadyProfitLabel.frame = CGRectMake(WIDTH_OF_SCREEN/320*40, HEIGHT_OF_SCREEN/568*37, WIDTH_OF_SCREEN/320*240, HEIGHT_OF_SCREEN/568*21);
    _totalAlreadyProfitLabel.font= [UIFont systemFontOfSize:GTFixHeightFlaot(18)];
    
    _totalAmount.frame = CGRectMake(WIDTH_OF_SCREEN/320*40, HEIGHT_OF_SCREEN/568*91, WIDTH_OF_SCREEN/320*240, HEIGHT_OF_SCREEN/568*21);
    _totalAmount.font = [UIFont systemFontOfSize:GTFixHeightFlaot(18)];
    
    _showBtn.frame = CGRectMake(WIDTH_OF_SCREEN/320*110, HEIGHT_OF_SCREEN/568*80, WIDTH_OF_SCREEN/320*100, HEIGHT_OF_SCREEN/568*17);
    
    _mainView.frame = CGRectMake(0, 64, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN/568*160);
    
    
    if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)
    {
        _showBtn.frame = CGRectMake(WIDTH_OF_SCREEN/320*110, HEIGHT_OF_SCREEN/568*73, WIDTH_OF_SCREEN/320*100, HEIGHT_OF_SCREEN/568*17);
        
        _mainTableView.frame = CGRectMake(0, 190, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
        _mainScroView.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
        _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN+130);
        _mainScroView.contentOffset = CGPointMake(0, 0);
    }
    else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2)
    {
        
        _showBtn.frame = CGRectMake(WIDTH_OF_SCREEN/320*110, HEIGHT_OF_SCREEN/568*82, WIDTH_OF_SCREEN/320*100, HEIGHT_OF_SCREEN/568*17);
        
        _mainTableView.frame = CGRectMake(0, 208, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
        _mainScroView.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
        _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN+130);
        _mainScroView.contentOffset = CGPointMake(0, 0);
    }
    else //iPhone 4S
    {
        if (HEIGHT_OF_SCREEN == 480) {
            
            _leiJiLabel.frame = CGRectMake(112, 9, 121, 21);
            _titleTotalAmount.frame = CGRectMake(115, 62, 100, 17);
            _totalAlreadyProfitLabel.frame = CGRectMake(40, 33, 240, 21);
            _totalAmount.frame = CGRectMake(75, 80, 170, 21);
            
            _showBtn.frame = CGRectMake(110, 64, 100, 17);
            
            _mainView.frame = CGRectMake(0, 64, 320, 130);
            
            
            _mainTableView.frame = CGRectMake(0, 160, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
            _mainScroView.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN +200);
            _mainScroView.contentOffset = CGPointMake(0, 0);
        }else if (HEIGHT_OF_SCREEN == 568)
        {
            _showBtn.frame = CGRectMake(WIDTH_OF_SCREEN/320*110, HEIGHT_OF_SCREEN/568*75, WIDTH_OF_SCREEN/320*100, HEIGHT_OF_SCREEN/568*17);
            
            _mainTableView.frame = CGRectMake(0, 170, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN-64);
            _mainScroView.frame = CGRectMake(0, 0, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN);
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN+120);
            _mainScroView.contentOffset = CGPointMake(0, 0);
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentAmount)
                                                 name:UPDATE_USER_ASSERT_SUCCESS_NOTIFICATION_NAME
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    _mainTableView.scrollEnabled = NO;
    //    [_mainScroView addSubview:_mainTableView];
    //    [_mainScroView addSubview:_mainView];
    [self.view addSubview:_mainScroView];
    
    //    _mainScroView.contentOffset = CGPointMake(0, 0);
    [_mainScroView bringSubviewToFront:_mainTableView];
    _appdelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(____IOS7____)
    {
        self.hightLayout.constant = 0.0f;
    }
    else
    {
        self.hightLayout.constant = 49.0f;
    }
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(enRefinshe) name:@"enRefinshe" object:nil];
    backCash= [[BackCashViewController alloc]init];
    recoderINVC= [[InvestRecoderViewController alloc]init];
    cashHVC = [[CashHistoryViewController alloc]init];
    self.isGettingFtpInfo = FALSE;
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //    self.title = @"个人中心";
    
    cellInfoArray = @[
                      @{@"title":@"我的奖励",@"icon_normal":@"userCenter_listIcon"},
                      @{@"title":@"财行宝",@"icon_normal":@"userCenter_listIcon"},
                      @{@"title":@"已投资产",@"icon_normal":@"userCenter_listIcon"},
                      @{@"title":@"资金记录",@"icon_normal":@"userCenter_listIcon"},
                      @{@"title":@"回款计划",@"icon_normal":@"userCenter_listIcon"},
                      @{@"title":@"邀请好友",@"icon_normal":@"userCenter_listIcon"}
                      
                      //                     @{@"title":@"消息中心",@"icon_normal":@"userCenter_listIcon"}
                      
                      //                     @{@"title":@"邀请好友",@"icon_normal":@"userCenter_listIcon"}
                      ];
    [self createMainView];
    //    [self.mainTableView reloadData];
    
    if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)
    {
        reuseCellIndentifier = @"MineCenterHeaderCell6";
        
        UINib *nib = [UINib nibWithNibName:@"MineCenterHeaderCell6" bundle:nil];
        [self.mainTableView registerNib:nib forCellReuseIdentifier:reuseCellIndentifier];
    }
    else if (Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2)
    {
        reuseCellIndentifier = @"MineCenterHeaderCell6Plus";
        
        UINib *nib = [UINib nibWithNibName:@"MineCenterHeaderCell6Plus" bundle:nil];
        [self.mainTableView registerNib:nib forCellReuseIdentifier:reuseCellIndentifier];
    }
    else
    {
        reuseCellIndentifier = @"MineCenterHeaderCell5";
        
        UINib *nib = [UINib nibWithNibName:@"MineCenterHeaderCell5" bundle:nil];
        [self.mainTableView registerNib:nib forCellReuseIdentifier:reuseCellIndentifier];
    }
    
    //    headBackIdenty = @"HeadBackViewCell";
    //    [self.mainTableView registerNib:[UINib nibWithNibName:@"HeadBackViewCell" bundle:nil] forCellReuseIdentifier:headBackIdenty];
    
    mineCell = @"MineRewardTableViewCell";
    [self.mainTableView registerNib:[UINib nibWithNibName:@"MineRewardTableViewCell" bundle:nil] forCellReuseIdentifier:mineCell];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOnOtherDeviceNotificationName:) name:LOGIN_ON_OTHER_DEVICE_NOTIFICATION_NAME object:nil];
    
}

-(void)createMainView{
    [self.mainTableView reloadData];
    [_showBtn addTarget:self action:@selector(changeViewWithH:) forControlEvents:UIControlEventTouchUpInside];
    if (_showBtn.selected) {
        [self changeViewWithH: _showBtn];
    }
    _titleTotalAmount.hidden = YES;
    _totalAmount.hidden = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mainTableView reloadData];
        
        //        NSString *actionName = [NSString stringWithFormat:@"9/userAssert"];
        //        NSURL *url = [NSURL URLWithString:SERVER_REQUEST_INTERFACE(actionName)];
        
        [[ZMServerAPIs shareZMServerAPIs] getUserAssertSuccess:^(id response) {
           
            redNum = [NSString stringWithFormat:@"%@",[response objectForKey:@"canUseHongbaoNum"]];
            
            if ([[response objectForKey:@"code"] integerValue] == 1000)
            {
                NSDictionary *assertDic = [response objectForKey:@"data"];
                
                CLog(@"assertDic === %@", assertDic);
                
                _totalAmount.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userPointVO"] objectForKey:@"amount"] doubleValue]];
                
                _totalAlreadyProfitLabel.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userProfitVo"] objectForKey:@"totalAlreadyProfit"] doubleValue]];
            }
        } failure:^(id response) {
            if ([[response objectForKey:@"code"] integerValue] != 1000) {
            }
        }];
        
    });
    
    
    [[ZMServerAPIs shareZMServerAPIs] getUserAssertSuccess:^(id response) {

        if (![response objectForKey:@"canUseHongbaoNum"]) {
            redNum = @"0";
        }else{
            redNum = [NSString stringWithFormat:@"%@",[response objectForKey:@"canUseHongbaoNum"]];
        }
        if ([[response objectForKey:@"code"] integerValue] == 1000)
        {
            NSDictionary *assertDic = [response objectForKey:@"data"];
            
            CLog(@"assertDic === %@", assertDic);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _totalAmount.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userPointVO"] objectForKey:@"amount"] doubleValue]];
                _totalAlreadyProfitLabel.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userProfitVo"] objectForKey:@"totalAlreadyProfit"] doubleValue]];
                
                totalWaitingProfit = [[assertDic objectForKey:@"userProfitVo"] objectForKey:@"totalWaitingProfit"];
                availablePoints = [[assertDic objectForKey:@"userPointVO"] objectForKey:@"availablePoints"];
                frozenPoints = [[assertDic objectForKey:@"userPointVO"] objectForKey:@"frozenPoints"];
                waittingPrincipal = [[assertDic objectForKey:@"userPointVO"] objectForKey:@"waittingPrincipal"];
                
                
                [self.mainTableView reloadData];
            });
            
        }
    } failure:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] != 1000) {
            
        }
    }];
    
    
    //累计收益
    //    NSString * totalAlreadyProfit = [NSString stringWithFormat:@"%@", [[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAssert.userProfitVo objectForKey:@"totalAlreadyProfit"]];
    //    totalAlreadyProfit = [ZMTools moneyStandardFormatByString:totalAlreadyProfit];
    //    _totalAlreadyProfitLabel.text = [NSString stringWithFormat:@"%@", totalAlreadyProfit];
    //    //总额
    //    NSString * amountStr = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.amount];
    //    _totalAmount.text = [NSString stringWithFormat:@"%@", amountStr];
    
}

- (void)updateCurrentAmount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView reloadData];
    });
}
/*
 * 被另一台设备上登陆
 */
- (void)loginOnOtherDeviceNotificationName:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 1;
    }
    if(section == 1){
        return 1;
    }
    return cellInfoArray.count-1;
//            return cellInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     if(indexPath.section==0 &&indexPath.row == 0)
     {
     _indexPath = indexPath;
     HeadBackViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headBackIdenty forIndexPath:indexPath];
     cell.tag = 100;
     if(_upDownBtn==nil)
     {
     _upDownBtn = [[UIButton alloc]init];
     _upDownBtn = cell.showBtn;
     _headBackView = cell.headBackView;
     [_upDownBtn addTarget:self action:@selector(changeViewWithH:) forControlEvents:UIControlEventTouchUpInside];
     }
     if (_upDownBtn.selected) {
     [self changeViewWithH:_upDownBtn];
     }
     else
     {
     if(_upDownBtn.selected)
     {
     
     //               [self changeViewWithH:_upDownBtn];
     
     cell.titleTotalAmount.hidden = NO;
     cell.totalAmount.hidden = NO;
     
     cell.headBackView.image = [UIImage imageNamed:@"我的账户-背景高"];
     
     }
     else
     {
     cell.titleTotalAmount.hidden = YES;
     cell.totalAmount.hidden = YES;
     
     cell.headBackView.image = [UIImage imageNamed:@"我的账户-背景矮"];
     }
     
     }
     //累计收益
     NSString * totalAlreadyProfit = [NSString stringWithFormat:@"%@", [[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAssert.userProfitVo objectForKey:@"totalAlreadyProfit"]];
     totalAlreadyProfit = [ZMTools moneyStandardFormatByString:totalAlreadyProfit];
     cell.totalAlreadyProfitLabel.text = [NSString stringWithFormat:@"%@", totalAlreadyProfit];
     //总额
     NSString * amountStr = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.amount];
     cell.totalAmount.text = [NSString stringWithFormat:@"%@", amountStr];
     CLog(@"%@",amountStr);
     
     
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     return cell;
     }
     
     else */
    if(indexPath.section==0 && indexPath.row == 0)
    {
        MineCenterHeaderCell6Plus *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIndentifier forIndexPath:indexPath];
        CLog(@"==========    %f",cell.headBcakView.frame.size.height);
        [cell.rechargeBtn addTarget:self action:@selector(showRechargeView:) forControlEvents:UIControlEventTouchUpInside];
        [cell.getCashBtn addTarget:self action:@selector(showGetCashView:) forControlEvents:UIControlEventTouchUpInside];
        //待收本金
        //           NSString *collectedMoney = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.waittingPrincipal];
        //
        //           cell.collectedMoney.text = [NSString stringWithFormat:@"¥%@", collectedMoney];
        ////           CLog(@"%@",amountStr);
        //           //冻结余额
        //
        //           NSString *frezzMoney = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.frozenPoints];
        //           cell.freezeMoney.text = [NSString stringWithFormat:@"¥%@", frezzMoney];
        ////           CLog(@"%@",amountStr);
        //        //总额
        //        NSString * amountStr = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.amount];
        //        cell.amountLabel.text = [NSString stringWithFormat:@"¥%@", amountStr];
        //        CLog(@"%@",amountStr);
        //        //可用余额
        //         NSString * availablePointsStr = [ZMTools moneyStandardFormatByData:[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAccountInfo.availablePoints];
        //        cell.availablePointsLabel.text = [NSString stringWithFormat:@"¥%@", availablePointsStr];
        //
        //        已投资产
        //        CLog(@"%@",availablePointsStr);
        //        double lastmoney = [[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAssert.userInvestVO[@"amount"] doubleValue];
        //
        //         cell.lastCash.text = [NSString stringWithFormat:@"¥%.2f",lastmoney];
        //
        //        //待收收益
        //        NSString * totalWaitingProfit = [NSString stringWithFormat:@"%@", [[ZMAdminUserStatusModel shareAdminUserStatusModel].adminUserAssert.userProfitVo objectForKey:@"totalWaitingProfit"]];
        //
        //        totalWaitingProfit = [ZMTools moneyStandardFormatByString:totalWaitingProfit];
        //
        //
        //        cell.totalWaitingProfitLabel.text = [NSString stringWithFormat:@"¥%@", totalWaitingProfit];
        
        cell.collectedMoney.text = [NSString stringWithFormat:@"%.2f",[waittingPrincipal doubleValue]];
        cell.availablePointsLabel.text = [NSString stringWithFormat:@"%.2f",[availablePoints doubleValue]];
        cell.freezeMoney.text = [NSString stringWithFormat:@"%.2f",[frozenPoints doubleValue]];
        cell.totalWaitingProfitLabel.text = [NSString stringWithFormat:@"%.2f",[totalWaitingProfit doubleValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    else
    {
        static NSString *identy = @"coustomCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
        {
            if(cell==nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, (cell.frame.size.height-1)*_appdelegate.autoSizeScaleY,(cell.frame.size.width)*_appdelegate.autoSizeScaleX, 0.5)];
                view.backgroundColor = UIColorFromRGB(0xDDDCE5);
                [cell.contentView addSubview:view];
            }
            
        }
        
        
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            
            for (UIView *view in cell.contentView.subviews) {
                if (view.tag ==  1000) {
                    [view removeFromSuperview];
                }
            }
            
            if (HEIGHT_OF_SCREEN == 480) {
                redButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 5, 33, 36)];
            }else
            {
                CLog(@"%lf",HEIGHT_OF_SCREEN);
                redButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_OF_SCREEN/320*130, 3, WIDTH_OF_SCREEN/320*34, HEIGHT_OF_SCREEN/568*38)];
            }
            [redButton setImage:[UIImage imageNamed:@"红包_03"] forState:UIControlStateNormal];
            [redButton addTarget:self action:@selector(redBtnClick) forControlEvents:UIControlEventTouchUpInside];
            
            redButton.tag = 1000;
            
            [cell.contentView addSubview:redButton];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_OF_SCREEN/320*22, HEIGHT_OF_SCREEN/568*-2, WIDTH_OF_SCREEN/320*12, WIDTH_OF_SCREEN/320*12)];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.masksToBounds = YES;
            [view.layer setCornerRadius:CGRectGetHeight([view bounds]) / 2];
            
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_OF_SCREEN/320*1, HEIGHT_OF_SCREEN/568*1, WIDTH_OF_SCREEN/320*10, WIDTH_OF_SCREEN/320*10)];
            subView.backgroundColor = [UIColor redColor];
            
            [subView.layer setCornerRadius:CGRectGetHeight([subView bounds]) / 2];

            [view addSubview:subView];
            
            [redButton addSubview:view];
            
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH_OF_SCREEN/320*12, WIDTH_OF_SCREEN/320*12)];
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.textColor = [UIColor whiteColor];
            numLabel.text = redNum;
            
            numLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(9)];
            [view addSubview:numLabel];
            
            
            [[ZMServerAPIs shareZMServerAPIs] getUserAssertSuccess:^(id response) {
                
                NSDictionary *dict = (NSDictionary *)response;
                CLog(@"%@",dict);
                NSDictionary *subDict = dict[@"data"];
                
                allStr = [subDict objectForKey:@"ALL"];
                
            } failure:^(id response) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
                
            }];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14*_appdelegate.autoSizeScaleY];
        NSDictionary *singeDic = [cellInfoArray objectAtIndex:indexPath.row+(indexPath.section-1)*1];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", [singeDic objectForKey:@"icon_normal"], (long)indexPath.row+indexPath.section-1]];
        cell.textLabel.text =[singeDic objectForKey:@"title"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
        return cell;
    }
    
    return nil;
}

-(void)redBtnClick
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
    sendRedPackController *SRC = [[sendRedPackController alloc] init];
    [self.navigationController pushViewController:SRC animated:YES];

}


- (void)changeViewWithH:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    __weak UITableView * tableView = _mainTableView;
    CGRect frame = _mainTableView.frame;
    CGRect frame1 = _showBtn.frame;
    if (sender.selected) {
        
        
        if (HEIGHT_OF_SCREEN == 480) {
            
            frame.origin.y = 190*_appdelegate.autoSizeScaleY;
            frame.size.height = HEIGHT_OF_SCREEN + 80;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  + 210);
            frame1.origin.y = HEIGHT_OF_SCREEN/568*122;
            
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                
            } completion:^(BOOL finished) {
                _titleTotalAmount.hidden = NO;
                _totalAmount.hidden = NO;
            }];
            
        }else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2){
            frame.origin.y = 194*_appdelegate.autoSizeScaleY;
            frame.size.height = HEIGHT_OF_SCREEN + 80;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  + 150);
            frame1.origin.y = HEIGHT_OF_SCREEN/568*116;
            //frame.origin.y = -50*_appdelegate.autoSizeScaleY;
            //  frame.size.height = 160*_appdelegate.autoSizeScaleY;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, -50*_appdelegate.autoSizeScaleY);
                
                
                
            } completion:^(BOOL finished) {
                _titleTotalAmount.hidden = NO;
                _totalAmount.hidden = NO;
            }];
        }
        else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2){
            
            frame.origin.y = 190*_appdelegate.autoSizeScaleY;
            frame.size.height = HEIGHT_OF_SCREEN + 80;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  + 160);
            frame1.origin.y = HEIGHT_OF_SCREEN/568*116;
            //frame.origin.y = -50*_appdelegate.autoSizeScaleY;
            //  frame.size.height = 160*_appdelegate.autoSizeScaleY;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, -50*_appdelegate.autoSizeScaleY);
                
                
                
            } completion:^(BOOL finished) {
                _titleTotalAmount.hidden = NO;
                _totalAmount.hidden = NO;
            }];
        }else{
            frame.origin.y = 206*_appdelegate.autoSizeScaleY;
            frame.size.height = HEIGHT_OF_SCREEN + 80;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  + 140);
            frame1.origin.y = HEIGHT_OF_SCREEN/568*115;
            //frame.origin.y = -50*_appdelegate.autoSizeScaleY;
            //  frame.size.height = 160*_appdelegate.autoSizeScaleY;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, -50*_appdelegate.autoSizeScaleY);
                
                
                
            } completion:^(BOOL finished) {
                _titleTotalAmount.hidden = NO;
                _totalAmount.hidden = NO;
            }];
        }
    } else {
        
        if (HEIGHT_OF_SCREEN == 480) {
            frame.origin.y = 160;
//            frame.size.height = HEIGHT_OF_SCREEN- 64;
            //        frame.size.height = HEIGHT_OF_SCREEN-160-49;
            frame1.origin.y = 64;
            //        frame.size.height = 110*_appdelegate.autoSizeScaleY;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  +180);
            
            _titleTotalAmount.hidden = YES;
            _totalAmount.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
                
            }];
        }else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2)
        {
            frame.origin.y = HEIGHT_OF_SCREEN/568*160;
            //        frame.size.height = HEIGHT_OF_SCREEN-160-49;
            frame1.origin.y = HEIGHT_OF_SCREEN/568*75;
            //        frame.size.height = 110*_appdelegate.autoSizeScaleY;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  +130);
            
            _titleTotalAmount.hidden = YES;
            _totalAmount.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
                
            }];
        }else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)
        {
            frame.origin.y = HEIGHT_OF_SCREEN/568*160;
            //        frame.size.height = HEIGHT_OF_SCREEN-160-49;
            frame1.origin.y = HEIGHT_OF_SCREEN/568*73;
            //        frame.size.height = 110*_appdelegate.autoSizeScaleY;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  +120);
            
            _titleTotalAmount.hidden = YES;
            _totalAmount.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            frame.origin.y = HEIGHT_OF_SCREEN/568*170;
            //        frame.size.height = HEIGHT_OF_SCREEN-160-49;
            frame1.origin.y = HEIGHT_OF_SCREEN/568*75;
            //        frame.size.height = 110*_appdelegate.autoSizeScaleY;
            _mainScroView.contentSize = CGSizeMake(WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN  +110);
            
            _titleTotalAmount.hidden = YES;
            _totalAmount.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                tableView.frame = frame;
                _showBtn.frame = frame1;
                //            tableView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
                
            }];
            
        }
    }
}
/*
 - (void)changeViewWithH:(UIButton *)sender
 {
 sender.selected = !sender.selected;
 [self.mainTableView reloadData];
 //    CLog(@"----------");
 //    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
 //    [self.mainTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
 //    [self.mainTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     //头
     if(indexPath.section==0 && indexPath.row == 0)
     {
     if(_upDownBtn.selected==YES)
     {
     return 160*_appdelegate.autoSizeScaleY;
     }
     
     return  110*_appdelegate.autoSizeScaleY;
     }
     else */
    if(indexPath.section==0&&indexPath.row == 0)
    {
        
        
        if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)
        {
            return 206;
        }
        else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2)
        {
            return 238;
        }
        else //iPhone 4S
        {
            return 162;
        }
    }
    //    else if(indexPath.section == 1 && indexPath.row == 0)
    //    {
    //        return 44*_appdelegate.autoSizeScaleY;
    //    }
    else
    {
        return 44*_appdelegate.autoSizeScaleY;
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section==0)
    {
        return 10;
    }
    if (section == 1){
        return 10;
    }
    return 0;
}

- (void)showAlertWithLoginView
{
    if(![[ZMAdminUserStatusModel shareAdminUserStatusModel] isLoggedIn])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您已经退出登陆，请重新登陆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    return;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showAlertWithLoginView];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    if(indexPath.section == 1&& indexPath.row == 0)
    {
        //我的奖励
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        MineRewardViewController *mineReward = [[MineRewardViewController alloc] init];
        [self.navigationController pushViewController:mineReward animated:YES];
        
    }
    if(indexPath.section == 2&& indexPath.row == 4)
    {//邀请好友;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        InvitefriendsViewController* invite = [[InvitefriendsViewController alloc] init];
        [self.navigationController pushViewController:invite animated:YES];
        
    
     }
    /*
     *  已投资产
     */
    if(indexPath.section == 2&& indexPath.row == 1)
    {
        //        recoderINVC.title = @"已投资";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        [self.navigationController pushViewController:recoderINVC animated:YES];
    }
    /*
     *  资金记录
     */
    if(indexPath.section == 2&& indexPath.row == 2)
    {
        cashHVC.title = @"资金流水";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        [self.navigationController pushViewController:cashHVC animated:YES];
        
    }
    /*
     *  回款计划
     */
    if(indexPath.section == 2&& indexPath.row == 3)
    {
        backCash.title = @"回款计划";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        [self.navigationController pushViewController:backCash animated:YES];
    }
    if(indexPath.section == 2&& indexPath.row == 0)
    {
        /*
         *  日资宝
         */
        RizibaoTableViewController *next = [[RizibaoTableViewController alloc] init];
        next.title = @"财行宝";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        [self.navigationController pushViewController:next animated:YES];
        
    }
}

/*
 *alertView
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[ZMAdminUserStatusModel shareAdminUserStatusModel] popLoginVCWithCurrentViewController:self];
    }

}


/*
 * 充值
 */
- (void)showRechargeView:(UIButton *)sender
{
    [self showAlertWithLoginView];
    //安全认证(实名认证)
    if([[ZMAdminUserStatusModel shareAdminUserStatusModel].adminuserBaseInfo.idCard isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"请先进行实名认证"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.tag = 100;
        [alert show];
        return;
    }
    //充值前，判断是否已经使用连连支付进行充值了。
    [self getUserCarList];
}
/*
 * 获取用户银行卡列表
 */
- (void)getUserCarList
{
    [[ZMServerAPIs shareZMServerAPIs] getUserBankListForWithdraw:NO Success:^(id response)
     {
         CLog(@"用户银行卡列表：success = %@", response);
         
         NSMutableArray *tempBankCardArray = [[response objectForKey:@"data"] objectForKey:@"userBanks"];
         
         if (tempBankCardArray==nil) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 AddBankCardViewController * next = [[AddBankCardViewController alloc]init];
                 next.isRechange = YES;
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
                 
                 [self.navigationController pushViewController: next animated:YES];
                 return ;
             });
             
             CLog(@"银行卡数据为空");
             
             return ;
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *LLPayUserBankInfo = [response objectForKey:@"data"][@"userBanks"][0];
                 RechargeViewController *rechargeViewController = [[RechargeViewController alloc]init];
                 rechargeViewController.title = @"充值";
                 rechargeViewController.selectedBankInfo = LLPayUserBankInfo;
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
                 
                 [self.navigationController pushViewController:rechargeViewController animated:YES];
             });
             
         }
     }
                                                         failure:^(id response){
                                                             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"账户异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                             [alertView show];
                                                             CLog(@"失败 = %@",response);
                                                         }];
    
}


/*
 * 提现
 */
- (void)showGetCashView:(UIButton *)sender
{
    [self showAlertWithLoginView];
    if (HEIGHT_OF_SCREEN == 480)
    {
        GetCashViewIp4ViewController *next = [[GetCashViewIp4ViewController alloc]init];
        next.title = @"提现";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        
        [self.navigationController pushViewController:next animated:YES];
    }
    else
    {
        GetCashViewController *next = [[GetCashViewController alloc]init];
        next.title = @"提现";
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hiden" object:nil];
        [self.navigationController pushViewController:next animated:YES];
    }
}

//网络连接检查
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    if([reach isReachable])
    {
        [self.mainTableView reloadData];
        [[ZMServerAPIs shareZMServerAPIs] getUserAssertSuccess:^(id response) {
            if ([[response objectForKey:@"code"] integerValue] == 1000)
            {
                NSDictionary *assertDic = [response objectForKey:@"data"];
                
                CLog(@"assertDic === %@", assertDic);
                
                _totalAmount.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userPointVO"] objectForKey:@"amount"] doubleValue]];
                _totalAlreadyProfitLabel.text = [NSString stringWithFormat:@"%.2f",[[[assertDic objectForKey:@"userProfitVo"] objectForKey:@"totalAlreadyProfit"] doubleValue]];
            }
        } failure:^(id response) {
            if ([[response objectForKey:@"code"] integerValue] != 1000) {
            }
        }];
    }
    else
    {
        [[HUD sharedHUDText] showForTime:2.0 WithText:@"网络异常,请检查网络"];
        
    }
    
}



@end