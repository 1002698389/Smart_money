//
//  CashHistoryViewController.m
//  ZiMaCaiHang
//
//  Created by zhangyy on 15/6/26.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "CashHistoryViewController.h"
#import "AppDelegate.h"
#define PAGESIZE 1
#define ROWNUMS 20
#import "CashHistoryCell.h"
#import "CashHistoryModel.h"
#import "MJRefresh.h"
@interface CashHistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dataState;
@property (strong, nonatomic) IBOutlet UIView *allSubjectView;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *getCashBtn;
@property (weak, nonatomic) IBOutlet UIButton *backCashBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *rewardBtn;
@property (nonatomic,strong)NSMutableArray *rechangeSource;
@property (nonatomic,strong)NSMutableArray *backmoneySource;
@property (nonatomic,strong)NSMutableArray *getCashSource;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSMutableArray *jiangliSource;
@end

@implementation CashHistoryViewController
{
    UIButton *titleViewBtn;
    NSInteger _selectIndex;
    AppDelegate *_appdelegate;
    int _currentPage;
    int _pagetx;
    int _pagehk;
    int _pagecz;
    int _pagejl;
    NSString* nowType;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem =  [ZMTools item:@"DetailBackButton" target:self select:@selector(backVC)];
    _appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _selectIndex =1;
    _currentPage = 1;
    _pagecz = 1;
    _pagehk = 1;
    _pagetx = 1;
    _pagejl = 1;
    _dataSource = [[NSMutableArray alloc]init];
    _rechangeSource = [[NSMutableArray alloc]init];
    _getCashSource = [[NSMutableArray alloc]init];
    _backmoneySource = [[NSMutableArray alloc]init];
    _jiangliSource = [[NSMutableArray alloc]init];
//    [self.tableView addHeaderWithTarget:self action:@selector(headUpdate)];
//    [self.tableView addFooterWithTarget:self action:@selector(footerUpdate)];
    
    // 添加动画图片的下拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    [self.tableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(headUpdate)];
    
    //上拉加载
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        int footerPage = 1;
        if ([nowType isEqual:@"ALL"]) {
            footerPage = ++_currentPage ;
        }
        if ([nowType isEqual:@"RECHARGE"]) {
            footerPage =   ++_pagecz ;
        }
        if ([nowType isEqual:@"WITHDRAW"]) {
            footerPage =   ++_pagetx;
        }
        if ([nowType isEqual:@"PAYMENT"]) {
            footerPage = ++_pagehk ; 
        }
        if ([nowType isEqual:@"REWARD"]) {
            footerPage = ++_pagejl ;
        }
        [self requestData:footerPage Type:nowType];

    }];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=10; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"跑步%zd", i]];
        [idleImages addObject:image];
    }
    [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"跑步%zd", i]];
        [refreshingImages addObject:image];
    }
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    
    // 马上进入刷新状态
    [self.tableView.gifHeader beginRefreshing];
    
    //  导航栏的按钮
    nowType = @"ALL";
    titleViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleViewBtn.bounds = CGRectMake(0, 0, 80, 40);
    [titleViewBtn setTitle:@"全部" forState:UIControlStateNormal];
    titleViewBtn.selected = NO;
    [titleViewBtn setImage:[UIImage imageNamed:@"剪头"] forState:UIControlStateNormal];
    titleViewBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 60, 5, 5);
    titleViewBtn.titleEdgeInsets = UIEdgeInsetsMake(5, -10, 5, 5);
    [titleViewBtn addTarget:self action:@selector(AllsubjectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleViewBtn;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(AllsubjectView)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.allSubjectView addGestureRecognizer:tap];
//    [self headUpdate];

       // Do any additional setup after loading the view from its nib.
}
- (void)backVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView.gifHeader beginRefreshing];
}
#pragma mark - 刷新
- (void)headUpdate
{
    titleViewBtn.enabled = NO;
    
    if ([nowType isEqual:@"ALL"]) {
        _currentPage = 1;
    }
    if ([nowType isEqual:@"RECHARGE"]) {
        _pagecz = 1;
    }
    if ([nowType isEqual:@"WITHDRAW"]) {
        _pagetx = 1;
    }
    if ([nowType isEqual:@"PAYMENT"]) {
        _pagehk = 1;
    }
    if ([nowType isEqual:@"REWARD"]) {
        _pagejl = 1;
    }
    [self requestData:1 Type:nowType];
}
#pragma mark - 加载
- (void)footerUpdate
{
    int footerPage = 1;
    if ([nowType isEqual:@"ALL"]) {
        footerPage = ++_currentPage ;
    }
    if ([nowType isEqual:@"RECHARGE"]) {
        footerPage =   ++_pagecz ;
    }
    if ([nowType isEqual:@"WITHDRAW"]) {
        footerPage =   ++_pagetx;
    }
    if ([nowType isEqual:@"PAYMENT"]) {
        footerPage = ++_pagehk ;
    }
    if ([nowType isEqual:@"REWARD"]) {
        footerPage = ++_pagejl ;
    }
    [self requestData:footerPage Type:nowType];
    
}
#pragma mark - 网络请求
- (void)requestData:(int)page Type:(NSString*)type
{
    
    [[ZMServerAPIs shareZMServerAPIs] getCashRecordNewByPage:page RowCount:ROWNUMS Type:type Success:^(id response) {
        if(page==1)
        {
            if ([nowType isEqual:@"ALL"]) {
                [_dataSource removeAllObjects];
            }
            else if ([nowType isEqual:@"RECHARGE"]) {
                [_rechangeSource removeAllObjects];
            }
            else if ([nowType isEqual:@"WITHDRAW"]) {
                
                [_getCashSource removeAllObjects];
            }else if  ([nowType isEqual:@"PAYMENT"]) {
                [_backmoneySource removeAllObjects];
            }else if  ([nowType isEqual:@"REWARD"]) {
                [_jiangliSource removeAllObjects];
            }
        }
        
        NSDictionary *json = (NSDictionary *)response;
        NSArray *arrList = json[@"datas"];
        for(NSDictionary *dict in arrList)
        {
            CashHistoryModel *model = [[CashHistoryModel alloc] initModelDictiony:dict];
            
            if ([nowType isEqual:@"ALL"]) {
                [_dataSource addObject:model];
            }
            if ([nowType isEqual:@"RECHARGE"]) {
                [_rechangeSource addObject:model];
            }
            if ([nowType isEqual:@"WITHDRAW"]) {
                
                [_getCashSource addObject:model];
            }
            if ([nowType isEqual:@"PAYMENT"]) {
                [_backmoneySource addObject:model];
            }
            if ([nowType isEqual:@"REWARD"]) {
                [_jiangliSource addObject:model];
            }
        }
        
        if ([nowType isEqual:@"ALL"]) {
            if(_dataSource.count>0)
            {
                self.tableView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = YES;
            }        }
        if ([nowType isEqual:@"RECHARGE"]) {
            if(_rechangeSource.count>0)
            {
                self.tableView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = YES;
            }
        }
        if ([nowType isEqual:@"WITHDRAW"]) {
            
            if(_getCashSource.count>0)
            {
                self.tableView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = YES;
            }
        }
        if ([nowType isEqual:@"PAYMENT"]) {
            if(_backmoneySource.count>0)
            {
                self.tableView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = YES;
            }
        }
        if ([nowType isEqual:@"REWARD"]) {
            if(_jiangliSource.count>0)
            {
                self.tableView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            [self.tableView.gifHeader endRefreshing];
            [self.tableView.footer endRefreshing];
            titleViewBtn.enabled = YES;
            
        });
    } failure:^(id response) {
        
        [self.tableView.gifHeader endRefreshing];
        [self.tableView.footer endRefreshing];
        titleViewBtn.enabled = YES;
    }];
}



//  加手势移除选择的条目
- (void)AllsubjectView
{
     [self.allSubjectView removeFromSuperview];
}
//  点击导航栏中间的按钮弹出试图
- (void)AllsubjectBtnClick:(UIButton *)subjectBtn
{
   
        [self.view addSubview:self.allSubjectView];
}
//  切换条目的按钮方法
- (IBAction)chooseSubject:(UIButton *)sender {
 
    if(sender==self.allBtn)
    {
        nowType = @"ALL";
//        [self requestData:1 Type:nowType];
//        _currentPage = 1;
        [titleViewBtn setTitle:@"全部" forState:UIControlStateNormal];
        [self.tableView.gifHeader beginRefreshing];
        [self.allSubjectView removeFromSuperview];
        _selectIndex = 1;
        [self.tableView reloadData];
        if(_dataSource.count>0)
        {
            self.tableView.hidden = NO;
        }
        else
        {
            self.tableView.hidden = YES;
        }
    }
    else if ( sender == self.rechargeBtn)
    {
        nowType = @"RECHARGE";

         [titleViewBtn setTitle:@"充值" forState:UIControlStateNormal];
        [self.tableView.gifHeader beginRefreshing];
        [self.allSubjectView removeFromSuperview];
        _selectIndex = 2;
        

//        [self.tableView reloadData];

        
        
        if(_rechangeSource.count>0)
        {
            self.tableView.hidden = NO;
        }
        else
        {
//            self.tableView.hidden = YES;
            nowType = @"RECHARGE";
            [self requestData:1 Type:nowType];
        }
    }
    else if(sender == self.getCashBtn)
    {
       
//        [_getCashSource removeAllObjects];
        nowType = @"WITHDRAW";

        _currentPage = 1;

         [titleViewBtn setTitle:@"提现" forState:UIControlStateNormal];
        [self.tableView.gifHeader beginRefreshing];
        [self.allSubjectView removeFromSuperview];
        _selectIndex = 3;
//        [self.tableView reloadData];
        if(_getCashSource.count>0)
        {
            self.tableView.hidden = NO;
        }
        else
        {
            nowType = @"WITHDRAW";
            [self requestData:1 Type:nowType];
        }
    }
    else if(sender == self.backCashBtn)
    {
//        [_backmoneySource removeAllObjects];
        nowType = @"PAYMENT";

        _currentPage = 1;
         [titleViewBtn setTitle:@"回款" forState:UIControlStateNormal];
        [self.tableView.gifHeader beginRefreshing];
        [self.allSubjectView removeFromSuperview];
        _selectIndex = 4;
//        [self.tableView reloadData];
        if(_backmoneySource.count>0)
        {
            self.tableView.hidden = NO;
        }
        else
        {
            nowType = @"PAYMENT";
            [self requestData:1 Type:nowType];
        }
    }else
    {
        //        [_backmoneySource removeAllObjects];
        nowType = @"REWARD";
        
        _currentPage = 1;
        [titleViewBtn setTitle:@"奖励" forState:UIControlStateNormal];
        [self.tableView.gifHeader beginRefreshing];
        [self.allSubjectView removeFromSuperview];
        _selectIndex = 5;
//        [self.tableView reloadData];
        if(_jiangliSource.count>0)
        {
            self.tableView.hidden = NO;
        }
        else
        {
            nowType = @"REWARD";
            [self requestData:1 Type:nowType];
        }
    }
}
- (void)viewWillLayoutSubviews
{
    self.allSubjectView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identy = @"CashHistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    if(cell==nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CashHistoryCell" owner:nil options:nil] lastObject];
    }
    CashHistoryCell *cashCell = (CashHistoryCell *)cell;
    if(_selectIndex==1)
    {
        cashCell.model = _dataSource[indexPath.row];
    }
   else if(_selectIndex==2)
    {
         cashCell.model = _rechangeSource[indexPath.row];
    }
   else if(_selectIndex==3)
    {
         cashCell.model = _getCashSource[indexPath.row];
    }
    else if(_selectIndex==4)
    {
         cashCell.model = _backmoneySource[indexPath.row];
    }
   else
    {
        cashCell.model = _jiangliSource[indexPath.row];
    }
   
    return cashCell;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_selectIndex==1)
    {
        if(_dataSource.count>0)

        {
            return _dataSource.count;
        }
        return 0;
    }
   else if(_selectIndex==2)
    {
        if(_rechangeSource.count>0)
            
        {
            return _rechangeSource.count;
        }
        return 0;
    }
 else  if(_selectIndex==3)
    {
        if(_getCashSource.count>0)
            
        {
            return _getCashSource.count;
        }
        return 0;
    }
    else if(_selectIndex==4)
    {
        if(_backmoneySource.count>0)
            
        {
            return _backmoneySource.count;
        }
        return 0;
    }
    else
    {
        if(_jiangliSource.count>0)
            
        {
            return _jiangliSource.count;
        }
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.0 && Ratio_OF_WIDTH_FOR_IPHONE6 < 1.2)
    {
        //        return (HEIGHT_OF_SCREEN - 64 - 49)/3;  //375 x 160
        return 43*_appdelegate.autoSizeScaleY;
    }
    else if(Ratio_OF_WIDTH_FOR_IPHONE6 > 1.2)
    {
        //        return (HEIGHT_OF_SCREEN - 64 - 49)/3;  //414 x 177
        return 43*_appdelegate.autoSizeScaleY;
    }
    else //iPhone 4S
    {
        return 43;
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    return view;
}
@end
