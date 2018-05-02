//
//  VOMineAllServiceListViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/16.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineAllServiceListViewController.h"
#import "VONetworking+Session.h"

#import "VOMineServiceListModel.h"
#import "VOMineServiceListTableViewCell.h"

#import "UIResultMessageView.h"
#import "VOMineEvaluateViewController.h"

#import "VOServiceOfPropertyViewController.h"

@interface VOMineAllServiceListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_activitiesListView;
    
    NSInteger pageNum;
    NSInteger pageSize;
    
    NSMutableArray *_listData;
    NSInteger currentStatus;
    
    MBProgressHUD *hud;
}
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UILabel *placeHolderView;
@end

@implementation VOMineAllServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"全部服务记录";
    
    //base data
    _listData = [NSMutableArray array];
    pageNum = 1;
    pageSize = 20;
    
    [self loadWebData];
    
    [self _initSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
}

-(void)backActionItem
{
    NSArray *array = self.navigationController.viewControllers;
    BaseViewController *VC = [array safeObjectAtIndex:1];
    if ([VC isKindOfClass:[VOServiceOfPropertyViewController class]]) {
        [self.navigationController popToViewController:VC animated:YES];
    }else
    {
        [super backActionItem];
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer   *)gestureRecognizer{
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        [self backActionItem];
        return NO;
    }
    return YES;
}
#pragma mark - getter method
-(UIView *)headerView
{
    if (!_headerView) {
        _headerView = [UIView new];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 54.);
        _headerView.backgroundColor = [UIColor hex:@"45536F"];
        //seg view
        UISegmentedControl *_titleView = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"未处理",@"处理中",@"已完成"]];
        _titleView.frame = CGRectMake(10., 3., _headerView.width - 15.*2, 36.);
        _titleView.tintColor = [UIColor whiteColor];
        _titleView.selectedSegmentIndex = 0;
        [_titleView addTarget:self action:@selector(selectedRoomType:) forControlEvents:UIControlEventValueChanged];
        [_headerView addSubview:_titleView];
    }
    return _headerView;
}

-(UILabel *)placeHolderView
{
    if (!_placeHolderView)
    {
        _placeHolderView = [[UILabel alloc] initWithFrame:CGRectMake(0,  self.headerView.bottom + 20., SCREEN_WIDTH, 20.)];
        _placeHolderView.textColor = [UIColor hex:@"858497"];
        _placeHolderView.font = [UIFont systemFontOfSize:14.];
        _placeHolderView.textAlignment = NSTextAlignmentCenter;
    }
    return _placeHolderView;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    //UISegmentedControl view
    [self.view addSubview:self.headerView];
    
    //placeholder view
    [self.view addSubview:self.placeHolderView];
    
    //list view
    _activitiesListView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, SCREEN_WIDTH, self.view.height - self.headerView.bottom) style:UITableViewStyleGrouped];
    _activitiesListView.backgroundColor = [UIColor hex:@"45536F"];
    _activitiesListView.delegate = self;
    _activitiesListView.dataSource = self;
    _activitiesListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _activitiesListView.showsVerticalScrollIndicator = NO;
    _activitiesListView.sectionHeaderHeight = 0;
    _activitiesListView.sectionFooterHeight = 0;
    [self.view addSubview:_activitiesListView];
    
    //footer view
    UIView *footerView =  [UIView new];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20.);
    _activitiesListView.tableFooterView = footerView;
    
    //上拉组件
    _activitiesListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData];
    }];
    _activitiesListView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
}

#pragma mark - UISegmentedControl action
- (void)selectedRoomType:(UISegmentedControl *)seg
{
    //更新服务状态
    currentStatus = seg.selectedSegmentIndex;
    //reset contentoffset    
    [_activitiesListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //refresh data
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshListData];
    });
    //更新title
    switch (seg.selectedSegmentIndex)
    {
        case 0:
        {
            self.navigationItem.title = @"全部服务记录";
        }
            break;
        case 1:
        {
            self.navigationItem.title = @"未处理的服务记录";
        }
            break;
        case 2:
        {
            self.navigationItem.title = @"处理中服务记录";
        }
            break;
        case 3:
        {
            self.navigationItem.title = @"已完成的服务记录";
        }
            break;
        default:
            break;
    }
}
#pragma mark - loadWebData
- (void)loadWebData
{
    if (self.navigationController.view) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    NSDictionary *params = nil;
    if (currentStatus)
    {
        NSString *currentStatusSet = currentStatus == 3 ? [NSString stringWithFormat:@"3,4"] : [NSString stringWithFormat:@"%ld", (long)currentStatus];
        params =     [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSString stringWithFormat:@"%ld", (long)pageNum], @"pageNum",
                      [NSString stringWithFormat:@"%ld", (long)pageSize], @"pageSize",
                      currentStatusSet,@"status",nil];
    }else
    {
        params =     [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSString stringWithFormat:@"%ld", (long)pageNum], @"pageNum",
                      [NSString stringWithFormat:@"%ld", (long)pageSize], @"pageSize", nil];
    }

    [VONetworking getWithUrl:@"/v1.0.0/api/project/upkeep/record" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        VOMineServiceListModel *serviceModel = [[VOMineServiceListModel alloc] initWithJSONDictionary:response];
        [_listData addObjectsFromArray:serviceModel.list];
        
        if (serviceModel.list.count < pageSize)  //显示无更多数据加载
        {
            [_activitiesListView.mj_footer endRefreshingWithNoMoreData];
        }else if (_activitiesListView.mj_footer.state == MJRefreshStateRefreshing) //结束加载更多
        {
            [_activitiesListView.mj_footer endRefreshing];
        }
        if (_activitiesListView.mj_header.state == MJRefreshStateRefreshing) //结束刷新
        {
            [_activitiesListView.mj_header endRefreshing];
        }
        
        //hide toast
        [hud hideAnimated:YES];
        
        if (serviceModel.list.count)
        {
            _activitiesListView.hidden = NO;
            self.placeHolderView.hidden = YES;
            //刷新列表
            [_activitiesListView reloadData];
        }else
        {
            _activitiesListView.hidden = YES;
            self.placeHolderView.hidden = NO;
            switch (currentStatus) {
                case 0:
                {
                    self.placeHolderView.text = @"暂无全部服务记录";
                }
                    break;
                case 1:
                {
                    self.placeHolderView.text = @"暂无未处理的服务记录";
                }
                    break;
                case 2:
                {
                    self.placeHolderView.text = @"暂无处理中的服务记录";
                }
                    break;
                case 3:
                {
                    self.placeHolderView.text = @"暂无已完成的服务记录";
                }
                    break;
                    
                default:
                    break;
            }
        }
    } failBlock:^(NSError *error) {
        //hide toast
        [hud hideAnimated:YES];
        if (_activitiesListView.mj_footer.state == MJRefreshStateRefreshing) //结束加载更多
        {
            [_activitiesListView.mj_footer endRefreshing];
        }
        if (_activitiesListView.mj_header.state == MJRefreshStateRefreshing) //结束刷新
        {
            [_activitiesListView.mj_header endRefreshing];
        }
    }];
}

- (void)refreshListData
{
    //结束无更多数据状态
    if (_activitiesListView.mj_footer.state == MJRefreshStateNoMoreData)
    {
        [_activitiesListView.mj_footer resetNoMoreData];
    }
    pageNum = 1;
    pageSize = 20.;
    _listData = [NSMutableArray array];
    
    [self loadWebData];
}
- (void)loadMoreData
{
    pageNum += 1;
    [self loadWebData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VOMineServiceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[VOMineServiceListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.serviceModel = [_listData safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.cancleBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakCell) strongCell = weakCell;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"取消服务申请" message:@"是否确认取消服务申请？该操作不可撤销" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/project/upkeep/record/%@/cancel",strongCell.serviceModel.projectUpkeepRecordId];
            [VONetworking putWithUrl:url refreshRequest:NO cache:NO params:nil needSession:NO successBlock:^(id response) {
                strongCell.serviceModel.status = @"5";
                [strongSelf->_activitiesListView reloadData];
            } failBlock:^(NSError *error) {
                if (error.code != -9999)    // -9999为无网络码
                {
                    NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                    [messageView showMessageViewWithMessage:errorMessage];
                }
            }];
        }];
        [alertVC addAction:firstAction];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:cancleAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf presentViewController:alertVC animated:YES completion:nil];
        });
    };
    cell.evaluateBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakCell) strongCell = weakCell;
        VOMineEvaluateViewController *evaVC = [[VOMineEvaluateViewController alloc] init];
        evaVC.serviceModel = strongCell.serviceModel;
        __weak typeof(strongSelf) weakSecSelf = strongSelf;
        evaVC.successBlock = ^{
            __strong typeof(weakSecSelf) strongSecSelf = weakSecSelf;
            [strongSecSelf refreshListData];
        };
        [strongSelf.navigationController pushViewController:evaVC animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VOMineServiceListTableViewCell getCellHeight:[_listData safeObjectAtIndex:indexPath.row]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
