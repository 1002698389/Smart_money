//
//  sendRedPackController.m
//  ZiMaCaiHang
//
//  Created by zhangyy on 15/10/14.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "sendRedPackController.h"
#import "SendRedPackTableViewCell.h"
#import "GTCommontHeader.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"

//分享
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

@interface sendRedPackController ()<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate>

@property (nonatomic,assign) NSInteger page;

@end

@implementation sendRedPackController

{
    NSMutableArray *_dataArray;
    NSString * shareUrl;
    NSString * shareTitle;
    NSString * shareImage;
    NSString * shareCenter;
    NSInteger *rows;
    NSArray *array;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView.gifHeader beginRefreshing];
    _page = 1;
    [self requestDataWithPage:_page];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.tableView.header endRefreshing];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.view.autoresizesSubviews = YES;
    
    self.title = @"发红包";
    
    _dataArray = [[NSMutableArray alloc] init];
    for (UIView* view in self.view.subviews){
        view.frame = GetFramByXib(view.frame);
        for (UIView* childview in view.subviews){
            childview.frame = GetFramByXib(childview.frame);
            for (UIView * childView1 in childview.subviews) {
                childView1.frame = GetFramByXib(childView1.frame);
            }
        }
    }

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加动画图片的下拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
//    [self.tableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(headUpdata)];
//    
//    //上拉加载
//    
//    if (array.count >19) {
//        [self.tableView addLegendFooterWithRefreshingBlock:^{
//                
//                _page = _page + 1;
//                
//                [self requestDataWithPage:_page];
//        }];
//    }
//    
//    // 设置普通状态的动画图片
//    NSMutableArray *idleImages = [NSMutableArray array];
//    for (NSUInteger i = 1; i<=9; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"跑步%zd", i]];
//        [idleImages addObject:image];
//    }
//    [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
//    
//    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    NSMutableArray *refreshingImages = [NSMutableArray array];
//    for (NSUInteger i = 1; i<=9; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"跑步%zd", i]];
//        [refreshingImages addObject:image];
//    }
//    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
//    
//    // 设置正在刷新状态的动画图片
//    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
//    
//    // 马上进入刷新状态
//    [self.tableView.gifHeader beginRefreshing];
    
    [self createTableVIew];
    _label1.font = [UIFont systemFontOfSize:GTFixHeightFlaot(16)];
    _label2.font = [UIFont systemFontOfSize:GTFixHeightFlaot(16)];
    _allRedEnvelopeLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(16)];
    _receiveRedEnvelopeLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(16)];
    
}

//-(void)headUpdata
//{
//    _page = 1;
//    [self requestDataWithPage:_page];
//}

-(void)requestDataWithPage:(NSInteger)page
{
    
    MBProgressHUD *HUDjz = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUDjz setLabelText:@"加载ing..."];
    
    NSString * loginKey = [[ZMAdminUserStatusModel shareAdminUserStatusModel] getLoginKey];
    
    [[ZMServerAPIs shareZMServerAPIs] getUserRedPackWithLoginKey:loginKey Page:page Rows:20 Success:^(id response) {
        CLog(@"%@",response);
        
        if (_dataArray.count > 0) {
            [_dataArray removeAllObjects];
        }
        NSDictionary *dict = (NSDictionary *)response;
        
        array = dict[@"redPShareList"];
        for (NSDictionary *subDict in array) {
            
            [_dataArray addObject:subDict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUDjz hide:YES afterDelay:0.5];
//            self.allRedEnvelopeLabel.text = [NSString stringWithFormat:@"%d个",[dict[@"redPNumSum"] intValue]];
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d个",[dict[@"redPNumSum"] intValue]]];
            [str1 addAttribute:NSForegroundColorAttributeName value:[ZMTools ColorWith16Hexadecimal:@"e35242"] range:NSMakeRange(0,str1.length-1)];
             [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:GTFixHeightFlaot(16)] range:NSMakeRange(str1.length-1,1)];
            
            self.allRedEnvelopeLabel.attributedText = str1;
//            self.receiveRedEnvelopeLabel.text = [NSString stringWithFormat:@"%d个",[dict[@"redPNumGainSum"] intValue]];
            
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d个",[dict[@"redPNumGainSum"] intValue]]];
            [str2 addAttribute:NSForegroundColorAttributeName value:[ZMTools ColorWith16Hexadecimal:@"e35242"] range:NSMakeRange(0,str2.length-1)];
            [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:GTFixHeightFlaot(16)] range:NSMakeRange(str2.length-1,1)];
            self.receiveRedEnvelopeLabel.attributedText = str2;
            
            [self.tableView reloadData];
//            [self.tableView.gifHeader endRefreshing];
//            [self.tableView.footer endRefreshing];
        });
        
    } failure:^(id response) {
//        [self.tableView.gifHeader endRefreshing];
//        [self.tableView.footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUDjz setLabelText:@"请检查网络"];
            [HUDjz hide:YES afterDelay:1];
            
        });
        
    }];
    
}

-(void)createTableVIew
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.backgroundColor = []
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_OF_SCREEN, 60)];
    [view addSubview:_dayLabel];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = view;
//    self.tableView.sectionIndexBackgroundColor = [ZMTools ColorWith16Hexadecimal:@"f9f9f9"];
//    [[UITableViewHeaderFooterView appearance] setTintColor:[ZMTools ColorWith16Hexadecimal:@"f9f9f9"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.frame = CGRectMake(0, 64, WIDTH_OF_SCREEN, HEIGHT_OF_SCREEN-64);
        self.dayLabel.frame = CGRectMake(0, 20, WIDTH_OF_SCREEN, 30);
        self.dayLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(14)];
    });
}

#pragma mark ------ tableViewDelegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SendRedPackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"qqqq"];
    if (!cell) {

        cell = [[[NSBundle mainBundle] loadNibNamed:@"SendRedPackTableViewCell" owner:nil options:nil] lastObject];

        for (UIView* view in cell.contentView.subviews) {
            view.frame = GetFramByXib(view.frame);
            for (UIView* subview in view.subviews) {
                subview.frame = GetFramByXib(subview.frame);
            }
        }
    }

    
    cell.shengyuLabel.text = [NSString stringWithFormat:@"%@个已领取，剩余%@个",[[_dataArray objectAtIndex:indexPath.section] objectForKey:@"redPNumGain"],[[_dataArray objectAtIndex:indexPath.section] objectForKey:@"redPNum"]];
    cell.youxiaoDateLabel.text = [NSString stringWithFormat:@"有效期至：%@",[[_dataArray objectAtIndex:indexPath.section] objectForKey:@"endDate"]];
    
    cell.shengyuLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(14)];
    cell.youxiaoDateLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(10)];
    
    if ([[[_dataArray objectAtIndex:indexPath.section] objectForKey:@"redPNum"] intValue] == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.sendButton setTitle:@"发完了" forState:UIControlStateNormal];
            cell.sendButton.backgroundColor = [UIColor whiteColor];
            [cell.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            cell.sendButton.titleLabel.font = [UIFont systemFontOfSize:GTFixHeightFlaot(15)];
            cell.sendButton.userInteractionEnabled = NO;
        });
    }
    [cell.sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.sendButton.tag = 600+indexPath.section;
    return cell;
    
}

-(void)sendButtonClick:(UIButton *)button{
    
    shareUrl = [[_dataArray objectAtIndex:(button.tag-600)] objectForKey:@"share_url"];
    shareImage = [[_dataArray objectAtIndex:button.tag-600] objectForKey:@"share_imgurl"];
    shareTitle = [[_dataArray objectAtIndex:button.tag-600] objectForKey:@"shareTitle"];
    shareCenter = [[_dataArray objectAtIndex:button.tag-600] objectForKey:@"shareCenter"];
    
    [self ShareAction];
}

-(void)ShareAction{
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5599dac267e58ebe36003a91"
                                      shareText:nil
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToTencent,UMShareToQQ,nil]
                                       delegate:self];
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    
    if (platformName == UMShareToSina) {
        socialData.title = shareTitle;
        socialData.shareText = [NSString stringWithFormat:@"%@",shareCenter];
        NSData *dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImage]];
        socialData.shareImage = dateImg;
    }else if (platformName == UMShareToTencent) {
        
        socialData.shareText = [NSString stringWithFormat:@"%@%@",shareCenter,shareUrl];
        socialData.title = shareTitle;
        NSData *dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImage]];
        socialData.shareImage = dateImg;
    }
    else if (platformName == UMShareToQQ) {
        [UMSocialData defaultData].extConfig.qqData.title = shareTitle;
        socialData.shareText = shareCenter;
        //        socialData.shareImage = [UIImage imageNamed:@"fenxiang"];
        NSData *dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImage]];
        [UMSocialQQHandler setQQWithAppId:@"1104778512" appKey:@"VJsApXjPlwdgNZLg" url:shareUrl];
        [UMSocialData defaultData].extConfig.qqData.shareImage =dateImg;
        //        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.shareUrl];
        CLog(@"%@",shareUrl);
    }else if (platformName == UMShareToWechatSession) {
        [UMSocialWechatHandler setWXAppId:@"wxdd8ea8c380def15d" appSecret:@"9dc4d7e88d59acd4417ac1076dbf189a" url:shareUrl];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.title = shareTitle;
        socialData.shareText = shareCenter;
        socialData.title = shareTitle;
        NSData *dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImage]];
        socialData.shareImage = dateImg;
        CLog(@"%@",[NSURL URLWithString:shareImage]);
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault url:shareUrl];
        [[UMSocialData defaultData].urlResource setUrl:shareUrl];
        
        CLog(@"%@",shareUrl);
    }else if (platformName == UMShareToWechatTimeline) {
        [UMSocialWechatHandler setWXAppId:@"wxdd8ea8c380def15d" appSecret:@"9dc4d7e88d59acd4417ac1076dbf189a" url:shareUrl];
        
        NSData *dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:shareImage]];
        socialData.shareImage = dateImg;
        socialData.shareText = shareTitle;
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:shareUrl];
        CLog(@"%@",shareUrl);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_OF_SCREEN/568*62;

}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width,10)];
    [headerView setBackgroundColor:[ZMTools ColorWith16Hexadecimal:@"f9f9f9"]];
    
    return headerView;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
