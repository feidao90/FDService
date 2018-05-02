//
//  VOServiceBookingHeaderView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/29.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServiceBookingHeaderView.h"

#define kButtonTag 0xDDDDDD
@interface VOServiceBookingHeaderView()
{
    UIButton *_leftButton;
    UIButton *_midButton;
    
    UIButton *_rightButton;
    UIView *_selectedView;
    
    NSInteger lastIndex;
    UIView *_backView;
}
@end

@implementation VOServiceBookingHeaderView
-(instancetype)init
{
    if (self = [super init]) {
        [self _initSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initSubViews];
    }
    return self;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    
    self.backgroundColor = [UIColor hex:@"45536F"];
    
    _backView = [[UIView alloc] init];
    [self addSubview:_backView];
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setTitle:@"今天" forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(selectedItems:) forControlEvents:UIControlEventTouchUpInside];
    _leftButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    _leftButton.tag = kButtonTag;
    [_backView addSubview:_leftButton];
    
    _midButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_midButton setTitle:@"明天" forState:UIControlStateNormal];
    [_midButton setTitleColor:[UIColor hex:@"FFFFFF" alpha:.5] forState:UIControlStateNormal];
    _midButton.titleLabel.font = [UIFont systemFontOfSize:14.];
    [_midButton addTarget:self action:@selector(selectedItems:) forControlEvents:UIControlEventTouchUpInside];
    _midButton.tag = kButtonTag + 1;
    [_backView addSubview:_midButton];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTitle:@"选择日期" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor hex:@"FFFFFF" alpha:.5] forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:14.];
    [_rightButton addTarget:self action:@selector(selectedItems:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.tag = kButtonTag + 2;
    [_backView addSubview:_rightButton];
    
    _selectedView = [UIView new];
    [_backView addSubview:_selectedView];
}

#pragma mark - actions
- (void)selectedItems:(UIButton *)button
{
    NSInteger index = button.tag - kButtonTag;
    if (index < 2)
    {
        button.titleLabel.font = [UIFont systemFontOfSize:17.];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectedView.frame = CGRectMake(button.left, self.height - 2, button.width, 2);
        
        UIButton *lastButton = [_backView viewWithTag:kButtonTag + lastIndex];
        lastButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [lastButton setTitleColor:[UIColor hex:@"FFFFFF" alpha:.5] forState:UIControlStateNormal];
        lastIndex = index;
    }        
    if (self.indexBlock) {
        self.indexBlock(index);
    }
}

- (void)setLastIndexSelected:(NSString *)dateString
{
    UIButton *lastButton = [_backView viewWithTag:kButtonTag + lastIndex];
    lastButton.titleLabel.font = [UIFont systemFontOfSize:14.];
    [lastButton setTitleColor:[UIColor hex:@"FFFFFF" alpha:.5] forState:UIControlStateNormal];

    UIButton *button = [_backView viewWithTag:kButtonTag + 2];
    button.titleLabel.font = [UIFont systemFontOfSize:17.];
    [button setTitle:dateString forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _selectedView.frame = CGRectMake(button.left, self.height - 2, button.width, 2);
    
    lastIndex = 2;
}
#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = SCREEN_WIDTH/3;
    
    _backView.frame = self.bounds;
    
    _leftButton.frame = CGRectMake(0, 0, width, self.height);
    
    _midButton.frame = CGRectMake(_leftButton.right, 0, width, self.height);
    
    _rightButton.frame = CGRectMake(_midButton.right, 0, width, self.height);
    
    _selectedView.frame = CGRectMake(_leftButton.left, self.height - 2., width, 2.);
    _selectedView.backgroundColor = [UIColor hex:@"A1A8B6"];
}
@end
