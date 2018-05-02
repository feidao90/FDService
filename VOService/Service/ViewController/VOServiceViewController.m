//
//  VOServiceViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/6.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOServiceViewController.h"
#import "VOLoginManager.h"

#import "VOMineJoinEnterpriseViewController.h"
#import "VOMineBelongEnterpriseViewController.h"

#import "VONetworking+Session.h"
#import "VOServiceAnnouncementModel.h"

#import "iCarousel.h"
#import "VOServiceAnnouncementView.h"

#import "VOAnnouncementViewController.h"
#import "VOServiceOfPropertyViewController.h"

#import "VOBookingMeetingRoomViewController.h"
#import "VOQRCodeViewController.h"

#import "UIResultMessageView.h"
#import "VOMineNotificationListViewController.h"

#define kButtonTag 0xDDDDDD
@interface VOServiceViewController ()<iCarouselDataSource, iCarouselDelegate>
{
    UIView *_topView;
    UIView *_bottomView;
    
    UILabel *_timeLabel;
    
    NSMutableArray *_listData;
    
    UIImageView *_placeHolderImage;
    UILabel *_placeHolderLabel;
    
    iCarousel *_iCarousel;
    UILabel *_currentIndex;
    
    UIButton *_reLoadButton;
    UILabel *_titleLabel;        
}
@property (nonatomic,strong) UIView *placeHolderView;
@property (nonatomic,strong) UIView *titleLabelView;
@end

@implementation VOServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hiddenLeftItem = YES;
    //通知用户信息变更  ** basevc 已经做了移除
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews) name:kLoginInfoChanggeNotification object:nil];
    
    self.navigationItem.titleView = self.titleLabelView;
    //_init datasource
    _listData = [NSMutableArray array];
    
    //_initSubViews
    [self _initSubViews];
    
    //loadWebData
    [self loadWebData];
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

- (void)refreshViews
{
    if (self.navigationController.visibleViewController == self) {
        [self refreshSelf];
    }
}

- (void)refreshSelf
{
    self.placeHolderView.hidden = [self hasEnterprise] ?  YES : NO;
    _topView.hidden = [self hasEnterprise] ? NO : YES;
    _bottomView.hidden = [self hasEnterprise] ? NO : YES;
    _titleLabel.text = [self hasEnterprise] ? @"" : @"服务";
    //_init datasource
    _listData = [NSMutableArray array];
    //loadWebData
    [self loadWebData];
    
    //refresh bottom view
    [self refreshBottomView];
}

- (void)refreshBottomView
{
    for (UIView *view in _bottomView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat iconWidth = 80.;
    VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
    BOOL hasPrinter = loginInfoModel.user.hasPrinter == 1 ? YES : NO;
    NSArray *images = @[@"booking",@"property_services",@"open_door",@"print"];
    NSArray *hightlightImage = @[@"booking-on",@"property_services_on",@"open_door_on",@"print-on"];
    NSArray *titles = @[@"订会议室",@"物业服务",@"扫码开门",@"云打印机"];
    CGFloat spaceWidth = hasPrinter ? (SCREEN_WIDTH - iconWidth*4 )/5 : (SCREEN_WIDTH - iconWidth*3)/4;
    CGFloat bottomSpace = 30.;
    for (NSInteger i = 0; i < (hasPrinter ? 4 : 3); i ++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[images safeObjectAtIndex:i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[hightlightImage safeObjectAtIndex:i]] forState:UIControlStateSelected];
        button.frame = CGRectMake(spaceWidth + i*(iconWidth + spaceWidth), bottomSpace, iconWidth, iconWidth);
        button.tag = kButtonTag + i;
        [button addTarget:self action:@selector(didSeletedInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:button];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.];
        titleLabel.textColor = [UIColor hex:@"858497"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [titles safeObjectAtIndex:i];
        titleLabel.frame = CGRectMake(button.left + 2, button.bottom - 10., iconWidth, 20.);
        [_bottomView addSubview:titleLabel];
        
        if (i == 3)
        {
            button.hidden = !hasPrinter;
            titleLabel.hidden = !hasPrinter;
        }
    }
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    self.placeHolderView.hidden = [self hasEnterprise] ?  YES : NO;
    [self.view addSubview:self.placeHolderView];
    
    
    _titleLabel.text = [self hasEnterprise] ? @"" : @"服务";
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10.)];
    _topView.backgroundColor = [UIColor hex:@"45536F"];
    _topView.hidden = [self hasEnterprise] ? NO : YES;
    [self.view addSubview:_topView];
    
    //time label
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13.];
    _timeLabel.textColor = [UIColor hex:@"B2B1C0"];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.frame = CGRectMake(0,  8., _topView.width, 18.);
    [_topView addSubview:_timeLabel];
    //placeholder image
    _placeHolderImage = [UIImageView new];
    if (self.view.height > 568.) {
        _placeHolderImage.frame = CGRectMake(55., _timeLabel.bottom + 47, SCREEN_WIDTH - 55.*2, 230.);
    }else
    {
        _placeHolderImage.frame = CGRectMake(55., _timeLabel.bottom + 47, SCREEN_WIDTH - 55.*2, 180.);
    }
    _placeHolderImage.image = [UIImage imageNamed:@"v"];
    _placeHolderImage.contentMode = UIViewContentModeScaleAspectFit;
    _placeHolderImage.hidden = YES;
    [_topView addSubview:_placeHolderImage];
    
    //place holder label
    _placeHolderLabel = [UILabel new];
    _placeHolderLabel.font = [UIFont systemFontOfSize:20.];
    _placeHolderLabel.textColor = [UIColor hex:@"FFFFFF" alpha:.5];
    _placeHolderLabel.textAlignment = NSTextAlignmentCenter;
    _placeHolderLabel.frame = CGRectMake(0, _placeHolderImage.bottom + 10., SCREEN_WIDTH, 26.);
    _placeHolderLabel.text = @"- 暂无园区公告 -";
    _placeHolderLabel.hidden = YES;
    [_topView addSubview:_placeHolderLabel];
    
    //reload button
    _reLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _reLoadButton.frame = CGRectMake(SCREEN_WIDTH/2 - 200/2, 100, 200, 200);
    [_reLoadButton setTitle:@"加载失败，点击刷新" forState:UIControlStateNormal];
    [_reLoadButton setTitleColor:[UIColor hex:@"858497"] forState:UIControlStateNormal];
    [_reLoadButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    _reLoadButton.hidden = YES;
    [self.view addSubview:_reLoadButton];
    
    //iCarousel初始设置
    CGFloat statusBarHeight = Height_NavBar;
    CGFloat heightTabBar = Height_TabBar;
    CGFloat maxHeight = SCREEN_HEIGHT - 150 - heightTabBar - _timeLabel.bottom - statusBarHeight - 30. - 42.;
    _iCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, _timeLabel.bottom + 30., SCREEN_WIDTH, maxHeight)];
    _iCarousel.type = iCarouselTypeCustom;
    _iCarousel.delegate = self;
    _iCarousel.dataSource = self;
    _iCarousel.pagingEnabled = YES;
    _iCarousel.scrollOffset = 0;
    _iCarousel.perspective =  -2.0/500.0;
    [_topView addSubview:_iCarousel];
    
    //index
    _currentIndex = [UILabel new];
    _currentIndex.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.];
    _currentIndex.textColor = [UIColor whiteColor];
    _currentIndex.textAlignment = NSTextAlignmentCenter;
    _currentIndex.frame = CGRectMake(0, _iCarousel.bottom + 40/2 -20./2, _topView.width, 20.);
    [_topView addSubview:_currentIndex];
    //top height
    _topView.height = _iCarousel.bottom + 40.;
    //bottom view
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bottom, SCREEN_WIDTH, 150 + 1)]; //1px是为了解决 tabbar移除阴影失效添加的...
    _bottomView.backgroundColor = [UIColor whiteColor];
    _bottomView.hidden = [self hasEnterprise] ? NO : YES;
    [self.view addSubview:_bottomView];
    
    CGFloat iconWidth = 80.;
    VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
    BOOL hasPrinter = loginInfoModel.user.hasPrinter == 1 ? YES : NO;    
    CGFloat spaceWidth = hasPrinter ? (SCREEN_WIDTH - iconWidth*4)/5 : (SCREEN_WIDTH - iconWidth*3)/4;
    NSArray *images = @[@"booking",@"property_services",@"open_door",@"print"];
    NSArray *hightlightImage = @[@"booking-on",@"property_services_on",@"open_door_on",@"print-on"];
    NSArray *titles = @[@"订会议室",@"物业服务",@"扫码开门",@"云打印机"];
    CGFloat bottomSpace = 30.;
    for (NSInteger i = 0; i < (hasPrinter ? 4 : 3); i ++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[images safeObjectAtIndex:i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[hightlightImage safeObjectAtIndex:i]] forState:UIControlStateSelected];
        button.frame = CGRectMake(spaceWidth + i*(iconWidth + spaceWidth), bottomSpace, iconWidth, iconWidth);
        button.tag = kButtonTag + i;
        button.contentMode = UIViewContentModeScaleAspectFill;
        [button addTarget:self action:@selector(didSeletedInfo:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [_bottomView addSubview:button];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.];
        titleLabel.textColor = [UIColor hex:@"858497"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [titles safeObjectAtIndex:i];
        titleLabel.frame = CGRectMake(button.left + 2, button.bottom -10. , iconWidth, 20.);
        [_bottomView addSubview:titleLabel];
        
        if (i == 3)
        {
            button.hidden = !hasPrinter;
            titleLabel.hidden = !hasPrinter;
        }
    }
}

#pragma mark - getter method
-(UIView *)titleLabelView
{
    if (!_titleLabelView) {
        _titleLabelView = [UIView new];
        _titleLabelView.frame = CGRectMake(20., 0, SCREEN_WIDTH - 20*2, 44.);
        _titleLabelView.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [UILabel new];
        _titleLabel.frame = CGRectMake(0, 44./2 - 28/2, SCREEN_WIDTH - 20*2, 28.);
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20.];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabelView addSubview:_titleLabel];
    }
    return _titleLabelView;
}

-(UIView *)placeHolderView
{
    if (!_placeHolderView)
    {
        _placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, SCREEN_WIDTH, self.view.height)];
        VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
        BOOL hasEnterprise = YES;
        if ([loginInfoModel.user.processingApplication.status integerValue] == 1)
        {
            hasEnterprise = NO;
        }else if (loginInfoModel.user.enterprise.name)
        {
            hasEnterprise = YES;
        }else
        {
            hasEnterprise = NO;
        }
        _placeHolderView.hidden = hasEnterprise ? YES : NO;
        //title
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"服务功能仅限入驻万科旗下产业办公园区的企业及其下成员使用，若您是入驻企业的成员，请点击下方按钮加入您所属的企业，享受更多服务";
        titleLabel.textColor = [UIColor hex:@"B2B1C0"];
        titleLabel.font = [UIFont systemFontOfSize:14.];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(50., _placeHolderView.height/4, SCREEN_WIDTH - 50.*2, 10);
        
        CGSize titleSize = [titleLabel textRectForBounds:CGRectMake(0, 0, titleLabel.width, 5000) limitedToNumberOfLines:10].size;
        titleLabel.height = titleSize.height;
        [_placeHolderView addSubview:titleLabel];
        
        UIButton *jionEnterprise = [UIButton buttonWithType:UIButtonTypeCustom];
        jionEnterprise.titleLabel.font =  [UIFont systemFontOfSize:17.];
        jionEnterprise.backgroundColor = [UIColor hex:@"58A5F7"];
        [jionEnterprise setTitle:@"立即加入企业" forState:UIControlStateNormal];
        [jionEnterprise setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        jionEnterprise.frame = CGRectMake(SCREEN_WIDTH/2 - 180./2, titleLabel.bottom + 15., 180., 42.);
        [jionEnterprise addTarget:self action:@selector(joinEnterprise) forControlEvents:UIControlEventTouchUpInside];
        [_placeHolderView addSubview:jionEnterprise];
    }
    return _placeHolderView;
}

#pragma mark - 加入企业
- (void)joinEnterprise
{
   VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
    if ([loginInfoModel.user.processingApplication.status integerValue] == 1)
    {
        VOMineBelongEnterpriseViewController *beEnterpriseVC = [[VOMineBelongEnterpriseViewController alloc] init];
        beEnterpriseVC.hidesBottomBarWhenPushed = YES;
        beEnterpriseVC.userModel =  loginInfoModel.user;
        [self.navigationController pushViewController:beEnterpriseVC animated:YES];
    }else
    {
        VOMineJoinEnterpriseViewController *joinVC = [[VOMineJoinEnterpriseViewController alloc] init];
        [self.navigationController presentViewController:joinVC animated:YES completion:^{
        }];
    }
}

#pragma mark - 服务选项
- (void)didSeletedInfo:(UIButton *)button
{
    NSInteger index = button.tag - kButtonTag;
    VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
    switch (index) {
        case 0: //订会议室
        {
            if (loginInfoModel.user.currentProject.inSettledPeriod == 1 && loginInfoModel.user.currentProject.isExpired == 0) {
                VOBookingMeetingRoomViewController *VC = [[VOBookingMeetingRoomViewController alloc] init];
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else
            {
                NSString *message = [NSString stringWithFormat:@"您好，当前时间不在贵公司与%@的合同承租期内，不能预订会议室。", loginInfoModel.user.currentProject.name];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"发起会议室预订失败！" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVC addAction:firstAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
        case 1: //物业服务
        {
            if (loginInfoModel.user.currentProjectExpired) {
                NSString *message = [NSString stringWithFormat:@"您好，当前时间不在贵公司与%@的合同承租期内，不能发起物业服务。", loginInfoModel.user.currentProject.name];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"发起物业服务失败！" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVC addAction:firstAction];
                [self presentViewController:alertVC animated:YES completion:nil];
                return;
            }
            VOServiceOfPropertyViewController *servicePropertyVC = [[VOServiceOfPropertyViewController alloc] init];
            servicePropertyVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:servicePropertyVC animated:YES];
        }
            break;
        case 2:
        {
            //扫码开门
            if (loginInfoModel.user.currentProjectExpired) {
                NSString *message = [NSString stringWithFormat:@"您好，当前时间不在贵公司与%@的合同承租期内，无开门权限。", loginInfoModel.user.currentProject.name];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫码开门失败！" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVC addAction:firstAction];
                [self presentViewController:alertVC animated:YES completion:nil];
                return;
            }
            VOQRCodeViewController *qrVC = [[VOQRCodeViewController alloc] init];
            qrVC.hidesBottomBarWhenPushed = YES;
            qrVC.inputType = VOQRCodeInputViewType_OpenDoor;
            __weak typeof(self) weakSelf = self;
            qrVC.openDoorBlock = ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:strongSelf.view];
                [messageView showMessageViewWithMessage:@"开门成功"];
            };
            [self.navigationController pushViewController:qrVC animated:YES];
        }
            break;
        case 3:
        {
            //云打印机
            VOQRCodeViewController *qrVC = [[VOQRCodeViewController alloc] init];
            qrVC.hidesBottomBarWhenPushed = YES;
            qrVC.inputType = VOQRCodeInputViewType_CloudPrinter;
            qrVC.openDoorFailureBlock = ^{
            };
            [self.navigationController pushViewController:qrVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 有无企业
- (BOOL)hasEnterprise
{
    BOOL hasEnterprise = YES;
    VOLoginResponseModel *loginInfoModel = [[VOLoginManager shared] getLoginInfo];
    if ([loginInfoModel.user.processingApplication.status integerValue] == 1)
    {
        hasEnterprise = NO;
    }else if (loginInfoModel.user.enterprise.name)
    {
        hasEnterprise = YES;
    }else if([loginInfoModel.user.type integerValue] == 1)
    {
        hasEnterprise = YES;
    }else
    {
        hasEnterprise = NO;
    }
    return hasEnterprise;
}

#pragma mark - loadWebData
- (void)loadWebData
{
    VOLoginResponseModel *userInfoModel = [[VOLoginManager shared] getLoginInfo];
    if (userInfoModel.user.currentProject.projectId.length)
    {
        NSString *url =  [NSString stringWithFormat:@"/v1.0.0/api/project/%@/announcement",userInfoModel.user.currentProject.projectId];
        [VONetworking getWithUrl:url refreshRequest:NO cache:NO params:nil needSession:NO successBlock:^(id response) {
            VOServiceAnnouncementModel *model = [[VOServiceAnnouncementModel alloc] initWithJSONDictionary:response];
            [_listData addObjectsFromArray:model.list];
            [_iCarousel reloadData];
            if (_listData.count)
            {
                _placeHolderImage.hidden = YES;
                _placeHolderLabel.hidden = YES;
                _reLoadButton.hidden = YES;
                _timeLabel.hidden = NO;
                _currentIndex.hidden = NO;
            }else
            {
                _placeHolderImage.hidden = NO;
                _placeHolderLabel.hidden = NO;
                _timeLabel.hidden = YES;
                _currentIndex.hidden = YES;
                _titleLabel.text = [NSString stringWithFormat:@"%@园区公告", userInfoModel.user.currentProject.name.length ?  userInfoModel.user.currentProject.name : @""];
            }
        } failBlock:^(NSError *error) {
            VOLoginResponseModel *model =  [[VOLoginManager shared] getLoginInfo];
            _titleLabel.text = [NSString stringWithFormat:@"%@园区公告", model.user.currentProject.name.length ?  model.user.currentProject.name : @""];
            if (error.code != -9999)    // -9999为无网络码
            {
                if ([[error.userInfo safeObjectForKey:@"message"] isEqualToString:@"BS99999999"]) {
                    _reLoadButton.hidden = NO;
                }else
                {
                    _placeHolderImage.hidden = NO;
                    _placeHolderLabel.hidden = NO;
                    NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                    [messageView showMessageViewWithMessage:errorMessage];
                }
            }
        }];
    }else
    {
        _placeHolderImage.hidden = NO;
        _placeHolderLabel.hidden = NO;
    }
    
}

#pragma mark - 时间戳转换
- (NSString *)getFormatterTime:(NSString *)createTime
{    
    CGFloat nowTime = [[NSDate date] timeIntervalSince1970];
    NSDate *changeDate = [NSDate dateWithTimeIntervalSince1970:[createTime integerValue]/1000.];
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    if ((nowTime - [createTime floatValue]/1000) < 24*60*60)
    {
        [changeFormatter setDateFormat:@"HH:mm"];
    }else
    {
        [changeFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    return [changeFormatter stringFromDate:changeDate];
}

#pragma mark - iCarousel代理方法
//自定义iCarousel
-(CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    static CGFloat max_sacle = 1.0f;
    static CGFloat min_scale = 0.6f;
    if (offset <= 1 && offset >= -1) {
        float tempScale = offset < 0 ? 1+offset : 1-offset;
        float slope = (max_sacle - min_scale) / 1;
        
        CGFloat scale = min_scale + slope*tempScale;
        transform = CATransform3DScale(transform, scale, scale, 1);
    }else{
        transform = CATransform3DScale(transform, min_scale, min_scale, 1);
    }
    return CATransform3DTranslate(transform, offset * _iCarousel.itemWidth * 1.4, 0.0, 0.0);
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel * __nonnull)carousel {
    return _listData.count;
}
- (UIView *)carousel:(iCarousel * __nonnull)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view {
    VOServiceAnnouncementListModel *model = [_listData safeObjectAtIndex:index];
    CGFloat statusBarHeight = Height_NavBar;
    CGFloat heightTabbar = Height_TabBar;
    CGFloat maxHeight = SCREEN_HEIGHT - 150 - heightTabbar - _timeLabel.bottom - statusBarHeight - 30. - 42.;
    if (view == nil) {
        view =[[UIView alloc] initWithFrame:CGRectMake(38., 0, SCREEN_WIDTH - 38.*2,  maxHeight)];
        view.layer.backgroundColor = [UIColor clearColor].CGColor;
        view.layer.cornerRadius = 4.;
        view.layer.masksToBounds = YES;
    }
    VOServiceAnnouncementView * announcementView = [[VOServiceAnnouncementView alloc] init];
    announcementView.model =model;
    announcementView.frame = view.bounds;
    [view addSubview:announcementView];
    return view;
}

//转动触发方法
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    if (_listData.count) {        
        VOServiceAnnouncementListModel *model = [_listData safeObjectAtIndex:_iCarousel.currentItemIndex];        
        _titleLabel.text = [NSString stringWithFormat:@"%@园区公告", model.project.name.length ?  model.project.name : @""];
        _timeLabel.text = [NSString stringWithFormat:@"发布于  %@", [NSString formatterMonthTime:model.gmtCreate]];
        _currentIndex.text = [NSString stringWithFormat:@"%ld/%ld", (long)_iCarousel.currentItemIndex + 1, (long)_listData.count];
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (index == carousel.currentItemIndex)
    {
        VOAnnouncementViewController *annuouncement = [[VOAnnouncementViewController alloc] init];
        annuouncement.model = [_listData safeObjectAtIndex:index];;
        annuouncement.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:annuouncement animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
