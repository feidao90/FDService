//
//  VOAnnouncementViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/22.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOAnnouncementViewController.h"

@interface VOAnnouncementViewController ()
{
    UILabel *_titleLabel;
    UILabel *_contentLabel;
    
    UILabel *_projectName;
    UILabel *_timeLabel;
    
    UIScrollView *_backgroundView;
}
@end

@implementation VOAnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"公告详情";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.model.isValidity.integerValue) {
        [self _initSubViews];
    }else
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"该公告已经被下架了" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertVC addAction:firstAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat offsetY = 64.;
    _backgroundView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY)];
    _backgroundView.showsVerticalScrollIndicator = NO;
    _backgroundView.showsHorizontalScrollIndicator = NO;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_backgroundView];
    //title
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.];
    _titleLabel.text = self.model.subject;
    _titleLabel.numberOfLines = 0;
    CGSize titleSize = [_titleLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _titleLabel.font} context:nil].size;
    _titleLabel.frame = CGRectMake(30., 30., SCREEN_WIDTH - 30.*2, titleSize.height);
    [_backgroundView addSubview:_titleLabel];
    
    //content
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:17.];
    _contentLabel.text = self.model.content;
    _contentLabel.numberOfLines = 0;
    CGSize contentSize = [_contentLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _contentLabel.font} context:nil].size;
    _contentLabel.frame = CGRectMake(30., _titleLabel.bottom + 20., SCREEN_WIDTH - 30.*2, contentSize.height);
    [_backgroundView addSubview:_contentLabel];
    
    //project name
    _projectName = [UILabel new];
    _projectName.font = [UIFont systemFontOfSize:14.];
    _projectName.textColor = [UIColor hex:@"858497"];
    _projectName.text = [NSString stringWithFormat:@"%@物业管理处",self.model.project.name];
    _projectName.frame = CGRectMake(30., _contentLabel.bottom + 50., SCREEN_WIDTH - 30.*2, 20.);
    _projectName.textAlignment = NSTextAlignmentRight;
    [_backgroundView addSubview:_projectName];
    
    //time
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:14.];
    _timeLabel.textColor = [UIColor hex:@"858497"];
    _timeLabel.text = [NSString formatterHanYuTime:self.model.gmtCreate];
    _timeLabel.frame = CGRectMake(30., _projectName.bottom, SCREEN_WIDTH - 30.*2, 20.);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [_backgroundView addSubview:_timeLabel];
    
    _backgroundView.contentSize = CGSizeMake(SCREEN_WIDTH, _timeLabel.bottom + 30.);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
