//
//  VOMineEvaluateViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineEvaluateViewController.h"
#import "VOMineStarEvaView.h"

#import "VOPlaceholderTextView.h"
#import "VONetworking+Session.h"

#import "UIResultMessageView.h"

@interface VOMineEvaluateViewController ()<UITextViewDelegate>
{
    VOPlaceholderTextView *_userNameEditView;
    NSInteger starCount;
}
@end

@implementation VOMineEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"评价";
    //right item
    [self createRightItemWithTitle:@"提交" target:self action:@selector(rightItemAction)];
    [self disEnableRightItem:YES];
    
    //_initSubViews
    [self _initSubViews];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    starCount = -1;
    //title
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.];
    titleLabel.textColor = [UIColor hex:@"373745"];
    titleLabel.frame = CGRectMake(0, 30., SCREEN_WIDTH, 25.);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"为我们的服务打个分吧！";
    [self.view addSubview:titleLabel];
    //mesage
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = [UIFont boldSystemFontOfSize:14.];
    messageLabel.textColor = [UIColor hex:@"B2B1C0"];
    messageLabel.frame = CGRectMake(30. + 25., titleLabel.bottom + 9., SCREEN_WIDTH - 30.*2 - 25.*2, 40.);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"帮助我们更好的提升我们的服务质量，以便下次能为您提供更好的服务";
    messageLabel.numberOfLines = 2.;
    [self.view addSubview:messageLabel];
    
    //star view
    VOMineStarEvaView *starView = [[VOMineStarEvaView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - [VOMineStarEvaView getWidth]/2, messageLabel.bottom + 20., [VOMineStarEvaView getWidth], [VOMineStarEvaView getHeight])];
    __weak typeof(self)weakSelf = self;
    starView.starBlock = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf-> starCount = index + 1;
        [strongSelf configRightItemStatus];
    };
    [self.view addSubview:starView];
    
    //text view
    _userNameEditView = [[VOPlaceholderTextView alloc] initWithFrame:CGRectMake(30., starView.bottom + 30., SCREEN_WIDTH - 30.*2, 150.)];
    _userNameEditView.autocorrectionType = UITextAutocorrectionTypeNo;
    _userNameEditView.spellCheckingType = UITextSpellCheckingTypeNo;
    _userNameEditView.backgroundColor = [UIColor whiteColor];
    _userNameEditView.placeholder = @"500字以内评价";
    _userNameEditView.font = [UIFont systemFontOfSize:17.];
    _userNameEditView.delegate = self;
    [_userNameEditView becomeFirstResponder];
    [self.view addSubview:_userNameEditView];
    
}

#pragma mark - right item action
- (void)rightItemAction
{
    NSDictionary *params = @{
                             @"comments" : _userNameEditView.text,
                             @"star" : [NSString stringWithFormat:@"%ld",(long)starCount]
                             };
    NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/project/upkeep/record/%@/star",self.serviceModel.projectUpkeepRecordId];
    [VONetworking putWithUrl:url refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //更新数据源
        self.serviceModel.star = [NSString stringWithFormat:@"%ld",(long)starCount];
        self.serviceModel.comments = _userNameEditView.text;
        //回调
        if (self.successBlock) {
            self.successBlock();
        }
        //toast
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"评价成功"];
        //返回上层页面
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failBlock:^(NSError *error) {
        if (error.code != -9999)    // -9999为无网络码
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

- (void)configRightItemStatus
{
    if (starCount >=0 && _userNameEditView.text.length)
    {
        [self disEnableRightItem:NO];
    }else
    {
        [self disEnableRightItem:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 500) {
        textView.text = [textView.text substringToIndex:500];
    }
    [self configRightItemStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
