//
//  VOServiceDetailInfoViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/12.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServiceDetailInfoViewController.h"
#import "VOMineServiceListTableViewCell.h"

#import "VONetworking+Session.h"
#import "UIResultMessageView.h"

#import "VOMineEvaluateViewController.h"
#import "VOMineActivitiesIntroModel.h"

@interface VOServiceDetailInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_activitiesListView;
    NSMutableArray *_listData;
}

@property (nonatomic,strong) UILabel *placeHolderView;
@end

@implementation VOServiceDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"服务详情";
    
    //_initSubViews
    [self _initSubViews];
    
    //loadWebData
    [self loadWebData];
}

#pragma mark - getter method
-(UILabel *)placeHolderView
{
    if (!_placeHolderView)
    {
        _placeHolderView = [[UILabel alloc] initWithFrame:CGRectMake(0,  20., SCREEN_WIDTH, 20.)];
        _placeHolderView.textColor = [UIColor hex:@"858497"];
        _placeHolderView.font = [UIFont systemFontOfSize:14.];
        _placeHolderView.textAlignment = NSTextAlignmentCenter;
    }
    return _placeHolderView;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{    
    //placeholder view
    [self.view addSubview:self.placeHolderView];
    //list view
    CGFloat offsetY = 64.;
    _activitiesListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.height - offsetY) style:UITableViewStyleGrouped];
    _activitiesListView.backgroundColor = [UIColor whiteColor];
    _activitiesListView.delegate = self;
    _activitiesListView.dataSource = self;
    _activitiesListView.bounces = NO;
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
}

#pragma mark - loadWebData
- (void)loadWebData
{
    _listData = [NSMutableArray array];
    [VONetworking getWithUrl:self.url refreshRequest:NO cache:NO params:nil needSession:NO successBlock:^(id response) {
        VOMineServiceListPageModel *listModel = [[VOMineServiceListPageModel alloc] initWithJSONDictionary:response];
        [_listData safeAddObject:listModel];
        [_activitiesListView reloadData];
    } failBlock:^(NSError *error) {
        if (error)
        {
            if (error.code != -9999)    // -9999为无网络码
            {
                NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                [messageView showMessageViewWithMessage:errorMessage];
            }
        }
    }];
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
            [strongSecSelf loadWebData];
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
