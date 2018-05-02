//
//  VOServicePaceView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/4.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServicePaceView.h"

@interface VOServicePaceView()

@property (nonatomic) UIView *leftLineView;
@property (nonatomic) UILabel *leftLabel;

@property (nonatomic) UILabel *midLabel;
@property (nonatomic) UILabel *rightLabel;

@property (nonatomic) UIView *rightLineView;
@end

@implementation VOServicePaceView
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

#pragma mark - getter method
-(UIView *)leftLineView
{
    if (!_leftLineView) {
        _leftLineView = [[UIView alloc] init];
        _leftLineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.2];
    }
    return _leftLineView;
}

-(UIView *)rightLineView
{
    if (!_rightLineView) {
        _rightLineView = [[UIView alloc] init];
        _rightLineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.2];
    }
    return _rightLineView;
}

-(UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [UILabel new];
    }
    return _leftLabel;
}

-(UILabel *)midLabel
{
    if (!_midLabel) {
        _midLabel = [UILabel new];
    }
    return _midLabel;
}


-(UILabel *)rightLabel
{
    if (!_rightLabel) {
        _rightLabel = [UILabel new];
    }
    return _rightLabel;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    [self addSubview:self.leftLineView];
    
    [self addSubview:self.rightLineView];
    
    [self addSubview:self.leftLabel];
    
    [self addSubview:self.rightLabel];
    
    [self addSubview:self.midLabel];
}

#pragma mark - layoutsubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //左线
    self.leftLineView.frame = CGRectMake(0, self.height/2, self.width/2, 1);
    //右线
    self.self.rightLineView.frame = CGRectMake(self.width/2, self.height/2, self.width/2, 1);
    
    //线条
    switch (self.statusType) {
        case 1:     //未处理
        {
            //left label
            self.leftLabel.frame = CGRectMake(0, self.height/2 - 30./2, 62., 30.);
            [self setStanderHighLightedLabel:self.leftLabel text:@"未处理"];
            
            //mid label
            self.midLabel.frame = CGRectMake(self.width/2 - 30./2, 0, 30., 30.);
            [self setStanderNomarlLabel:self.midLabel text:@"2"];
            
            //right label
            self.rightLabel.frame = CGRectMake(self.width - 30., 0, 30., 30.);
            [self setStanderNomarlLabel:self.rightLabel text:@"3"];
        }
        break;
        case 2:     //处理中
        {
            //left label
            self.leftLabel.frame = CGRectMake(0, self.height/2 - 30./2, 30., 30.);
            [self setStanderHighLightedLabel:self.leftLabel text:@"1"];
            
            //mid label
            self.midLabel.frame = CGRectMake(self.width/2 - 62./2, 0, 62., 30.);
            [self setStanderHighLightedLabel:self.midLabel text:@"处理中"];
            
            //right label
            self.rightLabel.frame = CGRectMake(self.width - 30., 0, 30., 30.);
            [self setStanderNomarlLabel:self.rightLabel text:@"3"];
        }
            break;
            
        case 3:     //已完成
        case 4:
        {
            //left label
            self.leftLabel.frame = CGRectMake(0, self.height/2 - 30./2, 30., 30.);
            [self setStanderHighLightedLabel:self.leftLabel text:@"1"];
            
            //mid label
            self.midLabel.frame = CGRectMake(self.width/2 - 30./2, 0, 30., 30.);
            [self setStanderHighLightedLabel:self.midLabel text:@"2"];
            
            //right label
            self.rightLabel.frame = CGRectMake(self.width - 62., 0, 62., 30.);
            [self setStanderHighLightedLabel:self.rightLabel text:@"已完成"];
        }
            break;
        default:
            break;
    }
}
#pragma mark - public method
- (void)setStanderNomarlLabel:(UILabel *)label text:(NSString *)text
{
    label.layer.backgroundColor = [UIColor hex:@"E0E0E7"].CGColor;
    label.font = [UIFont systemFontOfSize:13.];
    label.layer.cornerRadius = CGRectGetHeight(self.leftLabel.frame)/2;
    label.layer.masksToBounds = YES;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
}
- (void)setStanderHighLightedLabel:(UILabel *)label text:(NSString *)text
{
    label.layer.backgroundColor = [UIColor hex:@"58A5F7"].CGColor;
    label.font = [UIFont systemFontOfSize:14.];
    label.layer.cornerRadius = CGRectGetHeight(self.leftLabel.frame)/2;
    label.layer.masksToBounds = YES;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
}
@end
