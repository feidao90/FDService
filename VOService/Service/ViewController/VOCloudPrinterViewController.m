//
//  VOCloudPrinterViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/5.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOCloudPrinterViewController.h"
#import "VONetworking+Session.h"

#import "UIResultMessageView.h"
#import "VOPrinterFileListModel.h"

#import "VOPrinterFileListTableViewCell.h"
#import "MBProgressHUD.h"

@interface VOCloudPrinterViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listView;
    NSMutableArray *_listData;
    
    BOOL isSelectedAll;
    BOOL isShowPrint;
    
    MBProgressHUD *hud;
    UILabel *bottomLabel;
}
@property (nonatomic,strong) UIButton *bottomButton;
@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,strong) UIView *placeHolderView;
@end

@implementation VOCloudPrinterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"选择待打印文件";
    //right item
    [self createRightItemWithTitle:@"全选" target:self action:@selector(selectedAll)];
    self.hiddenRightItem = YES;
    
    //_initSubViews
    [self _initSubViews];
    
    //load web data
    [self getPrintFileList];
}

-(void)backActionItem
{
    //关闭打印机
    [self cloasePrinter];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - getter method
-(UIButton *)bottomButton
{
    if (!_bottomButton) {
        //编辑栏
        CGFloat height = 48.;
        if (IS_IPHONE_X) {
            height += 15.;
        }
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomButton setTitle:@"开始打印" forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomButton.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, height);
        [_bottomButton addTarget:self action:@selector(startPrint) forControlEvents:UIControlEventTouchUpInside];
        _bottomButton.backgroundColor = [UIColor hex:@"58A5F7"];
        if (IS_IPHONE_X) {
            _bottomButton.titleEdgeInsets = UIEdgeInsetsMake(-7.5, 0, 0, 0);
        }
    }
    return _bottomButton;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        _headerView.backgroundColor = [UIColor clearColor];
        
        NSString *titleString = @"扫描/复印请按打印机上的“SCAN”或“COPY”键开始，下载扫描文件请登录";
        NSString *linkString = @"www.vk-office.com";
        NSString *resultString = [NSString stringWithFormat:@"%@%@",titleString,linkString];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
        // 下划线
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:[resultString rangeOfString:linkString]];
        [attrStr addAttribute:NSUnderlineColorAttributeName value:[UIColor hex:@"58A5F7"] range:[resultString rangeOfString:linkString]];
        //字体颜色
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"858497"] range:[resultString rangeOfString:titleString]];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"58A5F7"] range:[resultString rangeOfString:linkString]];
        // 设置字体大小
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.] range:NSMakeRange(0, resultString.length)];
        //居中
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, resultString.length)];
        titleLabel.attributedText = attrStr;
        CGSize titleSize = [titleLabel.attributedText boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        titleLabel.frame = CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, titleSize.height);
        [_headerView addSubview:titleLabel];
        
        _headerView.height = titleLabel.bottom + 10.;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapURL)];
        [_headerView addGestureRecognizer:tap];
    }
    return _headerView;
}

-(UIView *)placeHolderView{
    if (!_placeHolderView) {
        _placeHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIImageView *headImage =  [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 120./2, 100., 120., 120.)];
        headImage.image = [UIImage imageNamed:@"print-nofiler"];
        [_placeHolderView addSubview:headImage];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.];
        titleLabel.textColor = [UIColor hex:@"858497"];
        titleLabel.text = @"暂无待打印的文件";
        titleLabel.frame = CGRectMake(0, headImage.bottom + 15., SCREEN_WIDTH, 24.);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_placeHolderView  addSubview:titleLabel];
        
        bottomLabel = [UILabel new];
        bottomLabel.userInteractionEnabled = YES;
        
        NSString *titleString = @"按打印机上的“SCAN”或“COPY”键开始扫描/复印，下载扫描文件请登录";
        NSString *linkString = @"www.vk-office.com";
        NSString *resultString = [NSString stringWithFormat:@"%@\n%@",titleString,linkString];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
        // 下划线
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:[resultString rangeOfString:linkString]];
        [attrStr addAttribute:NSUnderlineColorAttributeName value:[UIColor hex:@"58A5F7"] range:[resultString rangeOfString:linkString]];
        //字体颜色
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"858497"] range:[resultString rangeOfString:titleString]];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"58A5F7"] range:[resultString rangeOfString:linkString]];
        // 设置字体大小
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.] range:NSMakeRange(0, resultString.length)];
        //居中
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];        
        paragraphStyle.alignment = NSTextAlignmentCenter;
       [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, resultString.length)];
        bottomLabel.attributedText = attrStr;
        bottomLabel.numberOfLines = 0;
        CGSize titleSize = [bottomLabel.attributedText boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        bottomLabel.frame = CGRectMake(15., titleLabel.bottom + 30., SCREEN_WIDTH - 15.*2, titleSize.height);
        [_placeHolderView addSubview:bottomLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapURL)];
        [bottomLabel addGestureRecognizer:tap];
    }
    return _placeHolderView;
}

#pragma mark - 手势 actions
- (void)tapURL
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vk-office.com"]];
}

#pragma mark -  _initSubViews
- (void)_initSubViews
{
    //place hodler
    self.placeHolderView.hidden = YES;
    [self.view addSubview:self.placeHolderView];
    
    //data source
    _listData = [NSMutableArray array];
    
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
    _listView.hidden = YES;
    _listView.canCancelContentTouches = YES;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    
    _listView.tableHeaderView = self.headerView;
    
    
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData];
    }];
    //bottom button
    [self.view addSubview:self.bottomButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    CGPoint tapPoint = [oneTouch locationInView:self.view];
    if (!CGRectContainsPoint(bottomLabel.frame, tapPoint)) {
        //load web data
        if (!_listData.count) {
            [self connectPrinter];
        }
    }
}

#pragma mark - 全选
- (void)selectedAll
{
    isSelectedAll = !isSelectedAll;
    [self createRightItemWithTitle:isSelectedAll ? @"取消全选" : @"全选" target:self action:@selector(selectedAll)];
    for (VOPrinterFileListDetailModel *model in _listData) {
        model.isSelected = isSelectedAll;
    }
    //print status
    [self printShwoOrHide];
    [_listView reloadData];
}

- (void)refreshSelectedAll
{
    BOOL hasSelectedAll = YES;
    for (VOPrinterFileListDetailModel *model in _listData) {
        if(!model.isSelected)
        {
            hasSelectedAll = NO;
            break;
        }
    }
    if (isSelectedAll != hasSelectedAll) {
        isSelectedAll = hasSelectedAll;
        [self createRightItemWithTitle:isSelectedAll ? @"取消全选" : @"全选" target:self action:@selector(selectedAll)];
    }
}
#pragma mark - 呼出打印&隐藏打印
- (void)printShwoOrHide
{
    BOOL hasSelected = NO;
    for (VOPrinterFileListDetailModel *model in _listData) {
        if (model.isSelected) {
            hasSelected = YES;
            break;
        }
    }
    if (hasSelected == isShowPrint) {
        return;
    }
    if (hasSelected) {
        _listView.height -= self.bottomButton.height;
        [UIView animateWithDuration:.35 animations:^{
            CGFloat navHeight = Height_NavBar;
            self.bottomButton.frame = CGRectMake(self.bottomButton.left, self.bottomButton.top - self.bottomButton.height - navHeight, self.bottomButton.width, self.bottomButton.height);
        }];
    }else
    {
        _listView.height += self.bottomButton.height;
        [UIView animateWithDuration:.35 animations:^{
            self.bottomButton.frame = CGRectMake(self.bottomButton.left, SCREEN_HEIGHT, self.bottomButton.width, self.bottomButton.height);
        }];
    }
    
    isShowPrint = hasSelected;
}

#pragma mark - 开始打印
- (void)startPrint
{
    NSMutableArray *resultList = [NSMutableArray array];
    for (VOPrinterFileListDetailModel *model in _listData) {
        if(model.isSelected)
        {
            [resultList safeAddObject:model.jobId];
        }
    }
    
    NSDictionary *params = @{
                             @"equipIp" : self.model.printer_ip,
                             @"jobId" : [resultList componentsJoinedByString:@","],
                             @"stationId" :  self.model.ext_printer_id
                             };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VONetworking postWithUrl:@"/v1.0.0/api/cloudprint/print_order" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //hide HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"打印已完成，是否退出？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self cloasePrinter];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertVC addAction:firstAction];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //load web data
            _listData = [NSMutableArray array];
            [self connectPrinter];
        }];
        [alertVC addAction:cancleAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    } failBlock:^(NSError *error) {
        //hide HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            if (error.code == 400) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"您已超过2分钟未操作，请重新扫描解锁" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alertVC addAction:firstAction];
                [self presentViewController:alertVC animated:YES completion:nil];
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
}
#pragma mark - 链接打印机&获取打印文件列表
//连接打印机
- (void)connectPrinter
{
    if (self.navigationController.view) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/cloudprint/printer/%@/unlock",  self.model.ext_printer_id];
    NSDictionary *params = @{
                             @"equipIp" : self.model.printer_ip.length ?  self.model.printer_ip : @"",
                             @"stationId" : self.model.ext_printer_id.length ? self.model.ext_printer_id : @""
                             };
    [VONetworking postWithUrl:url refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        [self getPrintFileList];
    } failBlock:^(NSError *error) {
        //hide toast
        [hud hideAnimated:YES];
        //结束刷新
        if (_listView.mj_header.state == MJRefreshStateRefreshing)
        {
            [_listView.mj_header endRefreshing];
        }
        if (error)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
            if (self.failureBlock) {
                self.failureBlock();
            }
        }
    }];
}

//断开打印机
- (void)cloasePrinter
{
    NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/cloudprint/printer/%@/lock", self.model.ext_printer_id];
    [VONetworking postWithUrl:url refreshRequest:NO cache:NO params:nil needSession:NO successBlock:^(id response) {
        
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

//获取待打印文件
- (void)getPrintFileList
{
    NSDictionary *params = @{
                             @"equipIp" : self.model.printer_ip.length ?  self.model.printer_ip : @"",
                             @"stationId" : self.model.ext_printer_id.length ? self.model.ext_printer_id : @""
                             };
    [VONetworking getWithUrl:@"/v1.0.0/api/cloudprint/print_file" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //hide toast
        [hud hideAnimated:YES];
        //结束刷新
        if (_listView.mj_header.state == MJRefreshStateRefreshing)
        {
            [_listView.mj_header endRefreshing];
        }
        VOPrinterFileListModel *model = [[VOPrinterFileListModel alloc] initWithJSONDictionary:response];
        [_listData addObjectsFromArray:model.list];
        //print status
        [self printShwoOrHide];
        // 刷新right item
        [self refreshSelectedAll];
        if (_listData.count) {
            _listView.hidden = NO;
            self.placeHolderView.hidden = YES;
            self.hiddenRightItem = NO;
            [_listView reloadData];
        }else
        {
            _listView.hidden = YES;
            self.placeHolderView.hidden = NO;
            self.hiddenRightItem = YES;
        }
    } failBlock:^(NSError *error) {
        //hide toast
        [hud hideAnimated:YES];
        //结束刷新
        if (_listView.mj_header.state == MJRefreshStateRefreshing)
        {
            [_listView.mj_header endRefreshing];
        }
        if (error.code != -9999)    // -9999为无网络码
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

- (void)refreshListData
{
    _listData = [NSMutableArray array];
    [self connectPrinter];
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
    VOPrinterFileListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[VOPrinterFileListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = [_listData safeObjectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.;
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
    VOPrinterFileListDetailModel *model = [_listData safeObjectAtIndex:indexPath.row];
    model.isSelected = !model.isSelected;
    //print status
    [self printShwoOrHide];
    // 刷新right item
    [self refreshSelectedAll];
    [_listView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
