//
//  VODatePickerViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VODatePickerViewController.h"

@interface VODatePickerViewController ()
{
    UIDatePicker *_datePicker;
}
@end

@implementation VODatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _initSubViews];
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.frame = CGRectMake(0, self.view.height -SCREEN_HEIGHT/3 , SCREEN_WIDTH, SCREEN_HEIGHT/3);
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    _datePicker.locale = locale;
    //设置日期模式(Displays month, day, and year depending on the locale setting)
    _datePicker.datePickerMode = UIDatePickerModeDate;
    // 设置当前显示时间
    [_datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2] animated:YES];
    // 设置显示最大时间（此处为当前时间）
    [_datePicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2]];
    [self.view addSubview:_datePicker];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, _datePicker.top - 48., SCREEN_WIDTH, 48.)];
    headerView.backgroundColor = [UIColor hex:@"F4F4F4"];
    [self.view addSubview:headerView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH - 15. - 80., headerView.height/2 - 24./2, 80, 24.);
    [button setTitle:@"已完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor hex:@"58A5F7"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17.];
    [button addTarget:self action:@selector(didFinishedSelected) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
}

#pragma mark  - didFinishedSelected
- (void)didFinishedSelected
{
    NSDateFormatter *changeFormatter = [NSDateFormatter new];
    [changeFormatter setDateFormat:@"yyyyMMdd"];
    
    NSDateFormatter *secFormatter = [NSDateFormatter new];
    [secFormatter setDateFormat:@"yyyy/MM/dd"];
    
    if (self.selectBlock) {
        self.selectBlock([secFormatter stringFromDate:_datePicker.date],[changeFormatter stringFromDate:_datePicker.date]);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
