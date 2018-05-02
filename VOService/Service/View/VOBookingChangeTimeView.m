//
//  VOBookingChangeTimeView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/31.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingChangeTimeView.h"

@interface VOBookingChangeTimeView()
{
    UIButton *_deleteButton;
    UIButton *_addButton;
    
    UILabel *_titleLabel;
    UIButton *_cancleButton;
    
    UIButton *_nextButton;
    UIView *_lineView;
    
    UIView *_powLineView;
    UIView *_topLineView;
}
@end

@implementation VOBookingChangeTimeView
-(instancetype)init
{
    if (self = [super init]) {
        [self _initSubViews];
    }
    return self;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_deleteButton];
    
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_addButton];
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_cancleButton];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_nextButton];
    
    _lineView = [UIView new];
    [self addSubview:_lineView];
    
    _powLineView = [UIView new];
    [self addSubview:_powLineView];
    
    _topLineView = [UIView new];
    [self addSubview:_topLineView];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //减少时间
    [_deleteButton setImage:self.model.bottomModel.leftEnable ? [UIImage imageNamed:@"minus"] : [UIImage imageNamed:@"minus_disable"] forState:UIControlStateNormal];
    _deleteButton.frame = CGRectMake(15., 8., 30., 30.);
    [_deleteButton addTarget:self action:@selector(reduceTimeStamp) forControlEvents:UIControlEventTouchUpInside];
    
    //增加时间
    [_addButton setImage:self.model.bottomModel.nextEnable ?  [UIImage imageNamed:@"plus"] : [UIImage imageNamed:@"plus_disable"] forState:UIControlStateNormal];
    _addButton.frame = CGRectMake(SCREEN_WIDTH - 15. - 30., 8., 30., 30.);
    [_addButton addTarget:self action:@selector(addTimeStamp) forControlEvents:UIControlEventTouchUpInside];
    
    //时间范围
    _titleLabel.font = [UIFont systemFontOfSize:15.];
    _titleLabel.frame = CGRectMake(_deleteButton.right + 15., 13., SCREEN_WIDTH - (_deleteButton.right + 15) * 2, 20.);
    _titleLabel.text = self.model.bottomModel.title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = self.model.viewModel.isHidden ? [UIColor hex:@"FF5A60"] : [UIColor hex:@"373745"];
    //取消
    [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleButton setTitleColor:[UIColor hex:@"858497"] forState:UIControlStateNormal];
    _cancleButton.frame = CGRectMake(0, _titleLabel.bottom + 13., SCREEN_WIDTH/2, 45.);
    [_cancleButton addTarget:self action:@selector(cancleTimeStamp) forControlEvents:UIControlEventTouchUpInside];
    _cancleButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    _cancleButton.hidden = self.isHiddeBottom;
    //下一步
    [_nextButton setTitle:self.model.bottomModel.nextTitle forState:UIControlStateNormal];
    [_nextButton setTitleColor:self.model.bottomModel.rightEnable ?  [UIColor hex:@"373745"] :  [UIColor hex:@"D1D2DC"] forState:UIControlStateNormal];
    _nextButton.userInteractionEnabled = self.model.bottomModel.rightEnable;
    _nextButton.frame = CGRectMake(SCREEN_WIDTH/2, _titleLabel.bottom + 13., SCREEN_WIDTH/2, 45.);
    [_nextButton addTarget:self action:@selector(nextTimeStamp) forControlEvents:UIControlEventTouchUpInside];
    _nextButton.titleLabel.font = [UIFont systemFontOfSize:17.];
    _nextButton.hidden = self.isHiddeBottom;
    //line view
    _lineView.backgroundColor =  [UIColor hex:@"B2B1C0" alpha:.5];
    _lineView.frame = CGRectMake(0, _titleLabel.bottom + 12., SCREEN_WIDTH, 1);
    
    _powLineView.frame = CGRectMake(SCREEN_WIDTH/2 - .5, _lineView.bottom, 1, 45.);
    _powLineView.backgroundColor =  [UIColor hex:@"B2B1C0" alpha:.5];
    _powLineView.hidden = self.isHiddeBottom;    
}

#pragma mark - button actions
- (void)reduceTimeStamp
{
    if (self.model.bottomModel.leftEnable) {
        if (self.reduceBlock) {
            self.reduceBlock();
        }
    }
}

- (void)addTimeStamp
{
    if (self.model.bottomModel.nextEnable) {
        if (self.plusBlock) {
            self.plusBlock();
        }
    }
}

- (void)cancleTimeStamp
{
    if (self.cancleBlock) {
        self.cancleBlock();
    }
}

- (void)nextTimeStamp
{
    if (self.nextBlock) {
        self.nextBlock();
    }
}
@end
