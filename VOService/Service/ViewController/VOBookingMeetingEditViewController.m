//
//  VOBookingMeetingEditViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/1.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingMeetingEditViewController.h"
#import "UIImageView+WebCache.h"

#import "VOBookingTimeView.h"
#import "VOBookingChangeTimeView.h"

#import "VOBookingTableView.h"
#import "NSString+DateString.h"

#import "VOBookingMeetingTableViewCell.h"
#import "VONetworking+Session.h"

#import "VOBookingSuccessModel.h"
#import "UIResultMessageView.h"

#import "VOBookingSuccessViewController.h"
#import "VOLoginManager.h"

#import "VOMinePaymentProtocolViewController.h"

#define kStatusBarHeight Height_NavBar
@interface VOBookingMeetingEditViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listView;
    VOBookingTimeView *_bookingView;
    
    VOBookingChangeTimeView *_changeView;
    NSMutableArray *_listData;
    
    UIButton *_bottomButton;
    MBProgressHUD *hud;
}
@property (nonatomic,strong) UIView *headView;
@end

@implementation VOBookingMeetingEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"预订会议室";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //_initSubViews
    [self _initSubViews];
    
    //_initData
    [self _initData];
}

-(void)backActionItem
{
    if (self.clearBlock) {
        self.model.bottomModel.nextEnable = NO;
        self.model.bottomModel.title = @"请选择时间段";
        self.model.viewModel.isHidden = YES;
        self.model.bottomModel.leftEnable = NO;
        self.model.viewModel.frame = CGRectMake(self.model.viewModel.frame.origin.x, self.model.viewModel.frame.origin.y, SCREEN_WIDTH/11, self.model.viewModel.frame.size.height);
        self.clearBlock();
    }
    [super backActionItem];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.clearBlock) {
        NSInteger count = self.navigationController.viewControllers.count;
        if (!count) {
            self.model.bottomModel.nextEnable = NO;
            self.model.bottomModel.title = @"请选择时间段";
            self.model.viewModel.isHidden = YES;
            self.model.bottomModel.leftEnable = NO;
            self.model.viewModel.frame = CGRectMake(self.model.viewModel.frame.origin.x, self.model.viewModel.frame.origin.y, SCREEN_WIDTH/11, self.model.viewModel.frame.size.height);
            self.clearBlock();
        }
    }
}

#pragma mark - getter method
-(UIView *)headView
{
    if (!_headView) {
        _headView = [UIView new];
        
        //头图
        UIImageView *_headImageView = [UIImageView new];
        _headImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200.);
        VOBookingMeetingRoomPictureDetailModel *picModel = [self.model.pictures safeObjectAtIndex:0];
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_%.0f,h_200/auto-orient,1",picModel.url,SCREEN_WIDTH]]];
        [_headView addSubview:_headImageView];
        
        //时间轴
        _bookingView = [VOBookingTimeView new];
        _bookingView.frame = CGRectMake(0, _headImageView.bottom, SCREEN_WIDTH, 80.);
        _bookingView.model = self.model;
        _bookingView.unvalibleDate = self.unvalibleDate;
        __weak typeof(self) weakSelf = self;
        _bookingView.refreshBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf->_bookingView setNeedsLayout];
            [strongSelf->_bookingView layoutIfNeeded];
            
            [strongSelf->_changeView setNeedsLayout];
            [strongSelf->_changeView layoutIfNeeded];
            
            strongSelf-> _bottomButton.userInteractionEnabled = !strongSelf.model.viewModel.isHidden;
            strongSelf-> _bottomButton.backgroundColor = !strongSelf.model.bottomModel.rightEnable ? [UIColor hex:@"D1D2DC"] : [UIColor hex:@"58A5F7"];
            
            //更新消费
            [strongSelf caculateBookPrice];
            [strongSelf->_listView reloadData];
        };
        [_headView addSubview:_bookingView];
        
        _changeView = [VOBookingChangeTimeView new];
        _changeView.frame = CGRectMake(0, _bookingView.bottom, SCREEN_WIDTH, 46.);
        _changeView.hidden =  NO;
        _changeView.model = self.model;
        _changeView.isHiddeBottom = YES;
        _changeView.backgroundColor = [UIColor whiteColor];
        _changeView.reduceBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.model.bottomModel.leftEnable || strongSelf.model.viewModel.isHidden) {
                return ;
            }
            strongSelf.model.viewModel.frame = CGRectMake(strongSelf.model.viewModel.frame.origin.x, strongSelf.model.viewModel.frame.origin.y, strongSelf.model.viewModel.frame.size.width - SCREEN_WIDTH/11 < SCREEN_WIDTH/11 ? SCREEN_WIDTH/11 : strongSelf.model.viewModel.frame.size.width - SCREEN_WIDTH/11, strongSelf.model.viewModel.frame.size.height);
            strongSelf.model.bottomModel.title =  [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11))];
            if (roundf(strongSelf.model.viewModel.frame.size.width/(SCREEN_WIDTH/11)) < 2)
            {
                strongSelf.model.bottomModel.leftEnable = NO;
            }else if (!strongSelf.model.viewModel.frame.size.width/(SCREEN_WIDTH/11))
            {
                strongSelf.model.bottomModel.nextEnable = NO;
            }
            
            NSInteger length = (strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11);
            if (length < 48) {
                strongSelf.model.bottomModel.nextEnable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextEnable = NO;
            }
            
            if ( [strongSelf isContainerUnselectRegion]) {
                strongSelf.model.bottomModel.nextTitle = @"时段不可用";
                strongSelf.model.bottomModel.rightEnable = NO;
                strongSelf.model.viewModel.isUnavailable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextTitle = @"下一步";
                strongSelf.model.bottomModel.rightEnable = YES;
                strongSelf.model.viewModel.isUnavailable = NO;
            }
            strongSelf-> _bottomButton.backgroundColor = strongSelf.model.viewModel.isUnavailable  ? [UIColor hex:@"D1D2DC"] : [UIColor hex:@"58A5F7"];
            strongSelf-> _bottomButton.userInteractionEnabled = !strongSelf.model.viewModel.isHidden;
            
            //更新消费
            [strongSelf caculateBookPrice];
            [strongSelf->_listView reloadData];
            
            //刷新
            [strongSelf->_bookingView setNeedsLayout];
            [strongSelf->_bookingView layoutIfNeeded];
            
            [strongSelf->_changeView setNeedsLayout];
            [strongSelf->_changeView layoutIfNeeded];
        };
        _changeView.plusBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSInteger length = (strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11);
            if (length < 48) {
                strongSelf.model.viewModel.frame = CGRectMake(strongSelf.model.viewModel.frame.origin.x, strongSelf.model.viewModel.frame.origin.y, strongSelf.model.viewModel.frame.size.width + SCREEN_WIDTH/11, strongSelf.model.viewModel.frame.size.height);
                strongSelf.model.bottomModel.leftEnable = YES;
                strongSelf.model.bottomModel.title =  [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11))];
                NSInteger lastIndex = (strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11);
                if (lastIndex < 48) {
                    strongSelf.model.bottomModel.nextEnable = YES;
                }else
                {
                    strongSelf.model.bottomModel.nextEnable = NO;
                }
                if ( [strongSelf isContainerUnselectRegion]) {
                    strongSelf.model.bottomModel.nextTitle = @"时段不可用";
                    strongSelf.model.bottomModel.rightEnable = NO;
                    strongSelf.model.viewModel.isUnavailable = YES;
                }else
                {
                    strongSelf.model.bottomModel.nextTitle = @"下一步";
                    strongSelf.model.bottomModel.rightEnable = YES;
                    strongSelf.model.viewModel.isUnavailable = NO;
                }
                strongSelf-> _bottomButton.backgroundColor = strongSelf.model.viewModel.isUnavailable ? [UIColor hex:@"D1D2DC"] : [UIColor hex:@"58A5F7"];
                strongSelf-> _bottomButton.userInteractionEnabled = !strongSelf.model.viewModel.isHidden;
                
                //更新消费
                [strongSelf caculateBookPrice];
                [strongSelf->_listView reloadData];
                //刷新
                [strongSelf->_bookingView setNeedsLayout];
                [strongSelf->_bookingView layoutIfNeeded];
                
                [strongSelf->_changeView setNeedsLayout];
                [strongSelf->_changeView layoutIfNeeded];
            }
        };
        [_headView addSubview:_changeView];
        
        //bottom view
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _changeView.bottom, SCREEN_WIDTH, 20.)];
        bottomView.backgroundColor = [UIColor hex:@"F2F3F8"];
        [_headView addSubview:bottomView];
        
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bottomView.bottom);
    }
    return _headView;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat bottomWidth = 50.;
    CGFloat top = kStatusBarHeight;
    //list View
    _listView = [[VOBookingTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - top - bottomWidth) style:UITableViewStyleGrouped];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.delaysContentTouches = NO;
    _listView.canCancelContentTouches = YES;
    _listView.sectionHeaderHeight = 0;
    [self.view addSubview:_listView];
    
    _listView.tableHeaderView = self.headView;
    //_bottomButton
    _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bottomButton.frame = CGRectMake(0, SCREEN_HEIGHT - bottomWidth - top, SCREEN_WIDTH, bottomWidth);
    if (IS_IPHONE_X) {
        _bottomButton.frame = CGRectMake(0, SCREEN_HEIGHT - bottomWidth - top - 16., SCREEN_WIDTH, bottomWidth + 16.);
        _bottomButton.titleEdgeInsets = UIEdgeInsetsMake(-16, 0, 0, 0);
    }
    [_bottomButton setTitle:@"确认预订" forState:UIControlStateNormal];
    [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bottomButton.backgroundColor = self.model.viewModel.isHidden || self.model.viewModel.isUnavailable ? [UIColor hex:@"D1D2DC"] : [UIColor hex:@"58A5F7"];
    _bottomButton.userInteractionEnabled = !self.model.viewModel.isHidden;
    [_bottomButton addTarget:self action:@selector(commitBooking) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bottomButton];
}

#pragma mark - _initData
- (void)_initData
{
    _listData = [NSMutableArray array];
    
    NSMutableArray *firstSection = [NSMutableArray array];
    [firstSection safeAddObject:@{
                                  @"title" : @"预订日期",
                                  @"value" : [NSString formatterChineseTime:self.model.bookingDay]
                                  }];
    
    CGFloat widthDefulat = SCREEN_HEIGHT/11/2;
    NSInteger index = round(self.model.viewModel.frame.size.width/widthDefulat);
    [firstSection safeAddObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"title" : @"订单金额",
                                                                                @"value" : [NSString stringWithFormat:@"%.2f元",index*[self.model.price floatValue]/100]
                                                                                }]];
    [_listData safeAddObject:firstSection];
    
    NSMutableArray *secSection = [NSMutableArray array];
    [secSection safeAddObject:@{
                                  @"title" : @"名称",
                                  @"value" : self.model.meetingRoomName
                                   }];
    [secSection safeAddObject:@{
                                  @"title" : @"价格标准",
                                  @"value" : [NSString stringWithFormat:@"%.2f元／30分钟", [self.model.price floatValue]/100]
                                  }];
    [secSection safeAddObject:@{
                                  @"title" : @"位置",
                                  @"value" : [NSString stringWithFormat:@"%@%@·%@·%@层", self.model.cityName,self.model.projectName,self.model.buildingName,self.model.floor]
                                  }];
    [secSection safeAddObject:@{
                                  @"title" : @"可容纳人数",
                                  @"value" : [NSString stringWithFormat:@"%@人",self.model.capacity]
                                  }];
    [secSection safeAddObject:@{
                                  @"title" : @"配套",
                                  @"value" : self.model.supporting
                                  }];
    
    [_listData safeAddObject:secSection];
    
    [_listView reloadData];
}

#pragma mark - 计算预订消费
- (void)caculateBookPrice
{
    CGFloat widthDefulat = SCREEN_HEIGHT/11/2;
    NSInteger index = round(self.model.viewModel.frame.size.width/widthDefulat);
    NSMutableDictionary *priceDic = [[_listData safeObjectAtIndex:0] safeObjectAtIndex:1];
    [priceDic safeSetObject:[NSString stringWithFormat:@"%.2f元",index*[self.model.price floatValue]/100] forKey:@"value"];
}

#pragma mark - 更新用户信息
- (void)refreshLoginInfo
{
    [[VOLoginManager shared] refreshLoginfo:nil];
}

#pragma mark - 预订
- (void)commitBooking
{
    if (self.model.viewModel.isHidden || self.model.viewModel.isUnavailable) {
        return;
    }
    if (self.navigationController.view) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    __weak typeof(self) weakSelf = self;
    [[VOLoginManager shared] refreshLoginfoWithOutNotification:^(BOOL isSuccess) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        VOLoginResponseModel *model = [[VOLoginManager shared] getLoginInfo];
        if (![self getMaxContractEndTime:model.user.currentProject andBookingDate:self.bookingDay]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选中日期提示" message:@"您选择的预订日期不能大于合同截止日期，请重新选择。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVC addAction:firstAction];
            [strongSelf presentViewController:alertVC animated:YES completion:nil];
            //hide toast
            [hud hideAnimated:YES];
            return;
        }
        
        BOOL hasAtuthsize = model.user.paymentAuthorizeType != 1;
        if (hasAtuthsize) {
            //hide toast
            [hud hideAnimated:YES];
            if ([model.user.type integerValue] == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{                    
                    VOMinePaymentProtocolViewController *payment = [[VOMinePaymentProtocolViewController alloc] init];
                    __weak typeof(strongSelf) newWeakSelf = strongSelf;
                    payment.authorizeBlock = ^{
                        __strong typeof(newWeakSelf) newStrongSelf = newWeakSelf;
                        //更新用户信息
                        [newStrongSelf refreshLoginInfo];
                    };
                    [strongSelf.navigationController pushViewController:payment animated:YES];
                });
            }else if ([model.user.type integerValue] == 2)
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"预订失败！" message:@"你所在的企业未签订企业支付协议，请联系企业管理理员。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVC addAction:firstAction];
                [strongSelf presentViewController:alertVC animated:YES completion:nil];
            }
            return;
        }
        CGFloat startPercent = self.model.viewModel.frame.origin.x /(SCREEN_WIDTH/11);
        NSInteger startIndex = (NSInteger)roundf(startPercent);
        
        NSString *url = [NSString stringWithFormat:@"%@%@%@",@"/v1.0.0/api/meetingroom/",self.model.meetingRoomId,@"/order"];
        NSDictionary *params = @{
                                 @"bookingDay" : strongSelf.bookingDay,
                                 @"bookingHour" : [strongSelf dateFormatterStringFromIndex:startIndex]
                                 };
        [VONetworking postWithUrl:url refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
            //hide toast
            [hud hideAnimated:YES];
            VOBookingSuccessModel *model = [[VOBookingSuccessModel alloc] initWithJSONDictionary:response];
            VOBookingSuccessViewController *VC = [[VOBookingSuccessViewController alloc] init];
            VC.model = model;
            [strongSelf.navigationController pushViewController:VC animated:YES];
        } failBlock:^(NSError *error) {
            //hide toast
            [hud hideAnimated:YES];
            if (error)
            {
                if ([[error.userInfo objectForKey:@"message"] isEqualToString:@"BS00140025"] && [model.user.type integerValue] == 2) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"预订失败！" message:@"你所在的企业未签订企业支付协议，请联系企业管理理员。" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertVC addAction:firstAction];
                    [strongSelf presentViewController:alertVC animated:YES completion:nil];
                }else
                {
                    if (error.code != -9999)    // -9999为无网络码
                    {
                        NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                        [messageView showMessageViewWithMessage:errorMessage];
                    }
                }
            }
        }];
    }];
}

#pragma mark - 最大合同时间
- (NSInteger)getMaxContractEndTime:(VOProjectsModel *)projectsModel andBookingDate:(NSString *)bookingDate
{
    BOOL hasContaint = NO;
    for (VOContractTimesModel *model in projectsModel.contractTimes) {
        if ([bookingDate integerValue] >= [model.beginTime integerValue] && [bookingDate integerValue] <= [model.endTime integerValue]) {
            hasContaint = YES;
            break;
        }
    }
    return hasContaint;
}

#pragma mark - index to string
- (NSString *)dateFormatterStringFromIndex:(NSInteger )index
{
    NSString *resultString = nil;
    NSInteger widthIndex = self.model.viewModel.frame.size.width/(SCREEN_WIDTH/11);
    NSInteger startHour = index/2;
    NSInteger startmin = index%2*30;
    
    NSInteger endHour = startHour + (index%2 + widthIndex)/2;
    NSInteger endmin = (index + widthIndex)%2*30;
    
    resultString = [NSString stringWithFormat:@"%02ld:%.2ld~%02ld:%.2ld",(long)startHour,startmin,endHour,endmin];
    return resultString;
}
#pragma mark - index to time
- (NSString *)dateStringFromIndex:(NSInteger )index
{
    NSString *resultString = nil;
    NSInteger widthIndex = self.model.viewModel.frame.size.width/(SCREEN_WIDTH/11);
    NSInteger startHour = index/2;
    NSInteger startmin = index%2*30;
    
    NSInteger endHour = (index + widthIndex)/2;
    NSInteger endmin = (index + widthIndex)%2*30;
    
    resultString = [NSString stringWithFormat:@"%ld:%.2ld  至  %ld:%.2ld",(long)startHour,startmin,endHour,endmin];
    return resultString;
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _listData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_listData safeObjectAtIndex:section] count];
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
    cell.info = [[_listData safeObjectAtIndex:indexPath.section] safeObjectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VOBookingMeetingTableViewCell getCellHeight:[[_listData safeObjectAtIndex:indexPath.section] safeObjectAtIndex:indexPath.row]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 62;
    }
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 62.)];

        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:13.];
        label.textColor = [UIColor hex:@"B2B1C0"];
        label.frame = CGRectMake(14., 0, SCREEN_WIDTH - 14.*2, 10);
        label.text = @"您所有的预订订单都将会合并到企业的租赁账单中，以月结的方式结算，如有任何疑问请咨询企业管理员。";
        label.numberOfLines = 2;
        CGSize size =  [label.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 14.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size;
        label.frame = CGRectMake(14., backView.height/2 - size.height/2, size.width, size.height);
        [backView addSubview:label];
        return backView;
    }else if (section == 1)
    {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20.)];
        return bottomView;
    }
    return [UIView new];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"您所有的预订订单都将会合并到企业的租赁账单中，以月结的方式结算，如有任何疑问请咨询企业管理员。";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - 计算越区
- (BOOL)isContainerUnselectRegion
{
    BOOL hasRegion = NO;
    NSMutableArray *resultArray = [NSMutableArray array];
    [self indexFromString:[NSMutableString stringWithString:self.model.bookingStatus] setArray:resultArray];
    NSInteger startIndex = roundf(self.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11));
    NSInteger endIndex = roundf((self.model.viewModel.frame.origin.x + self.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11));
    if (startIndex < roundf([self caculateTime]*2)) {
        hasRegion = YES;
        return hasRegion;
    }
    for (NSNumber *numIndex in resultArray)
    {
        if ([numIndex integerValue] >= startIndex && endIndex > [numIndex integerValue]) {
            hasRegion = YES;
            break;
        }else if ([numIndex integerValue] + 1> startIndex && endIndex > [numIndex integerValue] + 1 )
        {
            hasRegion = YES;
            break;
        }
    }
    return hasRegion;
}

#pragma mark - 时间计算
- (CGFloat)caculateTime
{
    CGFloat index = 0;
    if (self.unvalibleDate) {
        NSDate *nowDate = self.unvalibleDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH"];
        
        NSDateFormatter *secFormat = [[NSDateFormatter alloc] init];
        [secFormat setDateFormat:@"mm"];
        NSString * hourStr=[dateFormat stringFromDate:nowDate];
        NSString *minStr  = [secFormat stringFromDate:nowDate];
        if ([minStr integerValue] > 30) {
            index = [hourStr integerValue] + 1;
        }else
        {
            index = [hourStr integerValue] + .5;
        }
    }
    return  index;
}
#pragma mark -  递归获取 index
- (void)indexFromString:(NSMutableString *)temp setArray:(NSMutableArray *)indexSet
{
    if ([temp rangeOfString:@"1"].location != NSNotFound && [temp rangeOfString:@"1"].length != 0)
    {
        [indexSet safeAddObject:[NSNumber numberWithInteger:[temp rangeOfString:@"1"].location]];
        [temp replaceCharactersInRange:[temp rangeOfString:@"1"] withString:@"0"];
        [self indexFromString:temp setArray:indexSet];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
