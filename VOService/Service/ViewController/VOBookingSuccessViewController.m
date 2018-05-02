//
//  VOBookingSuccessViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/2.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingSuccessViewController.h"
#import "NSString+DateString.h"

#import "UIImageView+WebCache.h"
#import "VOBookingMeetingTableViewCell.h"

#import "VOBookingMeetingRoomViewController.h"
#import "VOLoginManager.h"

@interface VOBookingSuccessViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    UITableView *_listView;
    NSMutableArray *_listData;
}

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *bottomView;
@end

@implementation VOBookingSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"预订成功";
    self.automaticallyAdjustsScrollViewInsets = NO;
    //left item
    [self createLeftItemWithImage:[UIImage imageNamed:@"search_close"] target:self action:@selector(leftItemAction)];
    
    
    //_initSubViews
    [self _initSubViews];
    
    //_initData
    [self _initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - item actions
- (void)leftItemAction
{
    for (BaseViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[VOBookingMeetingRoomViewController class]]) {
            [(VOBookingMeetingRoomViewController *)viewController refreshListData];
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer   *)gestureRecognizer{
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        [self leftItemAction];
        return NO;
    }
    return YES;
}
#pragma mark - getter method
-(UIView *)headerView
{
    if (!_headerView) {
        _headerView = [UIView new];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *headImage = [UIImageView new];
        headImage.frame = CGRectMake(SCREEN_WIDTH/2 - 160/2, 40, 160., 132.);
        headImage.image = [UIImage imageNamed:@"done_pic"];
        [_headerView addSubview:headImage];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:14.];
        titleLabel.textColor = [UIColor hex:@"858497"];
        titleLabel.text = @"已成功预订！";
        titleLabel.frame = CGRectMake(0, headImage.bottom + 20., SCREEN_WIDTH, 23.);
        titleLabel.textAlignment  = NSTextAlignmentCenter;
        [_headerView addSubview:titleLabel];
        
        //分割线
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(15, titleLabel.bottom + 25., SCREEN_WIDTH - 15*2, 1)];
        topLineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
        [_headerView addSubview:topLineView];
        
        //会议室主图
        UIImageView *meetingRoomImage = [UIImageView new];
        meetingRoomImage.frame = CGRectMake(15., topLineView.bottom + 15., 48., 48.);
        VOBookingMeetingRoomPictureDetailModel *picModel = [self.model.detail.pictures safeObjectAtIndex:0];
        [meetingRoomImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_96,h_96/auto-orient,1",picModel.url]]];
        [_headerView addSubview:meetingRoomImage];
        
        UILabel *roomName = [UILabel new];
        roomName.font = [UIFont boldSystemFontOfSize:17.];
        roomName.text = self.model.detail.meetingRoomName;
        roomName.frame = CGRectMake(meetingRoomImage.right + 15., topLineView.bottom + 15., SCREEN_WIDTH -meetingRoomImage.right - 15.*2 - 15 , 24.);
        roomName.lineBreakMode = NSLineBreakByTruncatingTail;
        [_headerView addSubview:roomName];
        
        UILabel *supporting = [UILabel new];
        supporting.font = [UIFont boldSystemFontOfSize:14.];
        supporting.text = self.model.detail.supporting;
        supporting.textColor = [UIColor hex:@"858497"];
        supporting.frame = CGRectMake(meetingRoomImage.right + 15., roomName.bottom + 4., SCREEN_WIDTH -meetingRoomImage.right - 15.*2 - 15 , 20.);
        supporting.lineBreakMode = NSLineBreakByTruncatingTail;
        [_headerView addSubview:supporting];
        
        //分割线
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(15, supporting.bottom + 15., SCREEN_WIDTH - 15*2, 1)];
        bottomLineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
        [_headerView addSubview:bottomLineView];
        
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bottomLineView.bottom);
    }
    return _headerView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
        
        UIView *backView = [UIView new];
        backView.backgroundColor = [UIColor whiteColor];
        backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
        [_bottomView addSubview:backView];
        
        //分割线
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 15*2, 1)];
        topLineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
        [backView addSubview:topLineView];
        
        //订单时间
        UILabel *orderTime = [UILabel new];
        orderTime.font = [UIFont systemFontOfSize:17.];
        orderTime.textColor = [UIColor hex:@"373745"];
        orderTime.text = @"订单创建时间";
        orderTime.frame = CGRectMake(15., topLineView.bottom + 15., SCREEN_WIDTH - 15.*2, 20.);
        [backView addSubview:orderTime];
        
        UILabel *valueLabel = [UILabel new];
        valueLabel.textColor = [UIColor hex:@"858497"];
        valueLabel.font = [UIFont systemFontOfSize:17.];
        valueLabel.frame = CGRectMake(0, orderTime.top, SCREEN_WIDTH - 15., 20.);
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.text = [NSString formatterAllTime:self.model.gmtCreate];
        [backView addSubview:valueLabel];
        //订单编号
        UILabel *orderId = [UILabel new];
        orderId.font = [UIFont systemFontOfSize:17.];
        orderId.textColor = [UIColor hex:@"373745"];
        orderId.text = @"订单编号";
        orderId.frame = CGRectMake(15., orderTime.bottom + 15., SCREEN_WIDTH - 15.*2, 20.);
        [backView addSubview:orderId];
        
        UILabel *valueId = [UILabel new];
        valueId.textColor = [UIColor hex:@"858497"];
        valueId.font = [UIFont systemFontOfSize:17.];
        valueId.frame = CGRectMake(0, orderId.top, SCREEN_WIDTH - 15., 20.);
        valueId.textAlignment = NSTextAlignmentRight;
        valueId.text = self.model.orderNum;
        [backView addSubview:valueId];
        
        backView.height  = valueId.bottom + 25.;
        
        UIImageView *bottomImage = [UIImageView new];
        bottomImage.frame = CGRectMake(0, backView.bottom, SCREEN_WIDTH, 8);
        bottomImage.image = [UIImage imageNamed:@"foot"];
        [_bottomView addSubview:bottomImage];
        
        _bottomView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bottomImage.bottom);
    }
    return _bottomView;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat offsetY = 64.;
    //list View
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY) style:UITableViewStyleGrouped];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.sectionHeaderHeight = 0;
    _listView.sectionFooterHeight = 0;
    _listView.delaysContentTouches = NO;
    _listView.canCancelContentTouches = YES;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    
    _listView.tableHeaderView = self.headerView;
    _listView.tableFooterView = self.bottomView;
}

#pragma mark - _initData
- (void)_initData
{
    _listData = [NSMutableArray array];
    
    [_listData safeAddObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"title" : @"订单金额",
                                                                                @"value" : [NSString stringWithFormat:@"%.2f元",[self.model.amount floatValue]/100]
                                                                                }]];
    [_listData safeAddObject:@{
                               @"title" : @"支付方式",
                               @"value" : [self.model.paymentType integerValue] == 1 ? @"企业账单月结" : @""
                               }];
    [_listData safeAddObject:@{
                                  @"title" : @"所属项目",
                                  @"value" : [NSString stringWithFormat:@"%@%@", self.model.detail.cityName, self.model.detail.projectName]
                                  }];
    [_listData safeAddObject:@{
                                  @"title" : @"位置",
                                  @"value" : [NSString stringWithFormat:@"%@·%@层", self.model.detail.buildingName,self.model.detail.floor]
                                  }];
    [_listData safeAddObject:@{
                                  @"title" : @"可容纳人数",
                                  @"value" : [NSString stringWithFormat:@"%@人",self.model.detail.capacity]
                                  }];
    
    NSMutableString *temp = [NSMutableString stringWithString:self.model.bookingDay];
    [temp insertString:@"/" atIndex:4];
    [temp insertString:@"/" atIndex:7];
    [_listData safeAddObject:@{
                                  @"title" : @"预订时段",
                                  @"value" : [NSString stringWithFormat:@"%@ %@", temp, self.model.bookingHourRange]
                                  }];
                                  
      [_listData safeAddObject:@{
                                 @"title" : @"预订时长",
                                 @"value" : [NSString stringWithFormat:@"%.1f小时", [self.model.bookingHalfHourTotal floatValue]/2]
                                 }];
    
    VOLoginResponseModel *model = [[VOLoginManager shared] getLoginInfo];
    [_listData safeAddObject:@{
                               @"title" : @"预订人",
                               @"value" : model.user.name.length ? model.user.name : @""
                               }];
    [_listView reloadData];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_listData  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    VOBookingMeetingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[VOBookingMeetingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.info = [_listData safeObjectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VOBookingMeetingTableViewCell getCellHeight:[_listData  safeObjectAtIndex:indexPath.row]];
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
