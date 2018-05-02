//
//  VOBookingMeetingRoomViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/29.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingMeetingRoomViewController.h"
#import "VOLoginManager.h"

#import "VONetworking+Session.h"
#import "UIResultMessageView.h"

#import "VOBookingMeetingRoomModel.h"
#import "VOServiceBookingHeaderView.h"

#import "VODatePickerViewController.h"
#import "VOServiceBookingTableViewCell.h"

#import "VOBookingTableView.h"
#import "VOBookingMeetingEditViewController.h"

@interface VOBookingMeetingRoomViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    NSInteger pageNum;
    NSInteger pageSize;
    
    NSMutableArray *_listData;
    VOBookingTableView *_listView;
    
    VOServiceBookingHeaderView *_headerView;
    NSString *_bookingDate;
    
    NSDate *unvalibleDate;
    NSIndexPath *lastIndexPath;
    
    NSInteger _itemIndex;
}

@property (nonatomic,strong) UIView *placeHolderView;
@end

@implementation VOBookingMeetingRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //_initSubViews
    [self _initSubViews];
    
    //load web data
    [self loadWebData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer   *)gestureRecognizer
{
    return YES;
}

#pragma mark - getter method
-(UIView *)placeHolderView
{
    if (!_placeHolderView)
    {
        _placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,  _headerView.bottom, SCREEN_WIDTH, self.view.height - _headerView.bottom)];
        _placeHolderView.hidden = YES;
        //icon image
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"list_empty"];
        imageView.frame = CGRectMake(SCREEN_WIDTH/2 - 100./2, 200., 100., 60.);
        [_placeHolderView addSubview:imageView];
    }
    return _placeHolderView;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{        
    //data source
    _listData = [NSMutableArray array];
    pageNum = 1;
    pageSize = 20;
    unvalibleDate = [NSDate date];
    _itemIndex = 0;
    
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyyMMdd"];
    _bookingDate = [changeFormatter stringFromDate:[NSDate date]];
 
    //header view
    _headerView = [VOServiceBookingHeaderView new];
    _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44.);
    __weak typeof(self) weakSelf = self;
    _headerView.indexBlock = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf ->_itemIndex = index;
        switch (index) {
            case 0:
            {
                strongSelf->_bookingDate = [strongSelf getTodayDay];
                strongSelf->unvalibleDate = [NSDate date];
                [strongSelf-> _listView.mj_header beginRefreshing];
                //load web data
                [strongSelf loadWebData];
            }
                break;
            case 1:
            {
                strongSelf->_bookingDate = [strongSelf getTomorrowDay];
                strongSelf->unvalibleDate = nil;
                [strongSelf-> _listView.mj_header beginRefreshing];
                //load web data
                [strongSelf loadWebData];
            }
                break;
            case 2:
            {
                VODatePickerViewController *presentVC = [[VODatePickerViewController alloc] init];
                presentVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
                strongSelf.definesPresentationContext = YES;
                presentVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                presentVC.selectBlock = ^(NSString *dateString, NSString *bookingDate) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf-> _bookingDate = bookingDate;
                    strongSelf->unvalibleDate = nil;
                    //下拉
                    [strongSelf-> _listView.mj_header beginRefreshing];
                    //刷新item view
                    [strongSelf->_headerView setLastIndexSelected:dateString];
                    //load web data
                    [strongSelf loadWebData];
                };
                [strongSelf.navigationController presentViewController:presentVC animated:NO completion:nil];
            }
                break;
            default:
                break;
        }

    };
    [self.view addSubview:_headerView];
    
    [self.view addSubview:self.placeHolderView];
    
    CGFloat offsetY = 64.;
    //list View
    _listView = [[VOBookingTableView alloc] initWithFrame:CGRectMake(0, _headerView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY - _headerView.bottom) style:UITableViewStyleGrouped];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.sectionHeaderHeight = 0;
    _listView.sectionFooterHeight = 0;
    _listView.delaysContentTouches = NO;
    _listView.canCancelContentTouches = YES;
    //禁止漂移
    _listView.estimatedRowHeight = 0;
    _listView.estimatedSectionHeaderHeight = 0;
    _listView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_listView];
    
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData];
    }];
    
    _listView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
}
#pragma mark - 获取今日的时间
- (NSString *)getTodayDay
{
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyyMMdd"];
    return [changeFormatter stringFromDate:[NSDate date]];
}

#pragma mark - 获取第二天的时间
- (NSString *)getTomorrowDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    [components setDay:([components day]+1)];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    [dateday setDateFormat:@"yyyyMMdd"];
    return [dateday stringFromDate:beginningOfWeek];
}

#pragma mark - load web data
- (void)loadWebData
{
    VOLoginResponseModel *userInfo = [[VOLoginManager shared] getLoginInfo];
    NSDictionary *params = @{
                             @"pageNum" : [NSString stringWithFormat:@"%ld",(long)pageNum],
                             @"pageSize" : [NSString stringWithFormat:@"%ld",(long)pageSize],
                             @"projectId" : userInfo.user.currentProject.projectId,
                             @"bookingDay" : _bookingDate
                             };
    [VONetworking getWithUrl:@"/v1.0.0/api/meetingroom" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        VOBookingMeetingRoomModel *model = [[VOBookingMeetingRoomModel alloc] initWithJSONDictionary:response];
        VOBookingMeetingRoomListModel *meetingModel = [model.list safeObjectAtIndex:0];
        self.navigationItem.title = [NSString stringWithFormat:@"%@·%@",meetingModel.cityName.length ? meetingModel.cityName : userInfo.user.currentProject.cityName ,meetingModel.projectName.length ? meetingModel.projectName : userInfo.user.currentProject.name];
        
        [_listData addObjectsFromArray:model.list];
        
        if (model.list.count < pageSize)  //显示无更多数据加载
        {
            [_listView.mj_footer endRefreshingWithNoMoreData];
        }else if (_listView.mj_footer.state == MJRefreshStateRefreshing) //结束加载更多
        {
            [_listView.mj_footer endRefreshing];
        }
        if (_listView.mj_header.state == MJRefreshStateRefreshing) //结束刷新
        {
            [_listView.mj_header endRefreshing];
        }
        
        if (model.list.count)
        {
            self.placeHolderView.hidden = YES;
            _listView.hidden = NO;
            //刷新列表
            [_listView reloadData];
            [(MJRefreshAutoStateFooter *)_listView.mj_footer setTitle:@"已经全部加载完毕" forState:MJRefreshStateNoMoreData];
        }else
        {
            self.placeHolderView.hidden = NO;
            [(MJRefreshAutoStateFooter *)_listView.mj_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
        }
    } failBlock:^(NSError *error) {
        if (error)
        {
            if (error.code != -9999)    // -9999为无网络码
            {
                NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                [messageView showMessageViewWithMessage:errorMessage];
            }
            
            if (_listView.mj_footer.state == MJRefreshStateRefreshing) //结束加载更多
            {
                [_listView.mj_footer endRefreshing];
            }
            if (_listView.mj_header.state == MJRefreshStateRefreshing) //结束刷新
            {
                [_listView.mj_header endRefreshing];
            }
        }
    }];
}

- (void)refreshListData
{
    //结束无更多数据状态
    if (_listView.mj_footer.state == MJRefreshStateNoMoreData)
    {
        [_listView.mj_footer resetNoMoreData];
    }
    if (!_itemIndex) {
        unvalibleDate = [NSDate date];
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
    VOServiceBookingTableViewCell *cell = [[VOServiceBookingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = [_listData safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.reloadBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf->lastIndexPath && strongSelf->lastIndexPath != indexPath) {
                VOBookingMeetingRoomListModel *model = [strongSelf->_listData safeObjectAtIndex:lastIndexPath.row];
                model.viewModel.isHidden = YES;
                model.bottomModel.nextEnable = NO;
                model.bottomModel.title = @"请选择时间段";
                model.viewModel.frame = CGRectMake(model.viewModel.frame.origin.x, model.viewModel.frame.origin.y, SCREEN_WIDTH/11, model.viewModel.frame.size.height);
                [tableView beginUpdates];
                [strongSelf->_listView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
            [tableView beginUpdates];
            [strongSelf->_listView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
            strongSelf->lastIndexPath = indexPath;
        });
    };
    cell.jumpBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        VOBookingMeetingEditViewController *editVC = [[VOBookingMeetingEditViewController alloc] init];
        editVC.model = [strongSelf->_listData safeObjectAtIndex:indexPath.row];
        editVC.bookingDay = strongSelf-> _bookingDate;
        editVC.unvalibleDate = strongSelf->unvalibleDate;
        editVC.clearBlock = ^{
            [tableView beginUpdates];
            [strongSelf->_listView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        };
        [strongSelf.navigationController pushViewController:editVC animated:YES];
    };
    cell.unvalibleDate = unvalibleDate;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VOServiceBookingTableViewCell getCellHeight:[_listData safeObjectAtIndex:indexPath.row]];
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
    VOBookingMeetingEditViewController *editVC = [[VOBookingMeetingEditViewController alloc] init];
    editVC.model = [_listData safeObjectAtIndex:indexPath.row];
    editVC.bookingDay = _bookingDate;
    editVC.unvalibleDate = unvalibleDate;
    __weak typeof(self) weakSelf = self;
    editVC.clearBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [tableView beginUpdates];
        if (lastIndexPath) {            
            [strongSelf->_listView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [tableView endUpdates];
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
