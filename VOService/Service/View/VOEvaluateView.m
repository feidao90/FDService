//
//  VOEvaluateView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOEvaluateView.h"

@interface VOEvaluateView ()
{
    UILabel *_titleLabel;
    UIView *_starsView;
    
    UILabel *_evaDescription;
}
@end

@implementation VOEvaluateView
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

#pragma mark -
- (void)_initSubViews
{
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _starsView = [UIView new];
    [self addSubview:_starsView];
    
    _evaDescription = [UILabel new];
    [self addSubview:_evaDescription];
}

#pragma mark - get height
+ (CGFloat)getHeight:(VOMineServiceListPageModel *)serviceModel
{
    CGFloat offsetY = 0;
    offsetY += 20.;
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14.];
    label.text = serviceModel.comments;
    label.numberOfLines = 0;
    CGSize evaSize = [label.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.*2 - 10.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size;
    offsetY += evaSize.height + 10.;
    return offsetY;
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.font = [UIFont systemFontOfSize:14.];
    _titleLabel.text = @"评价：";
    CGSize titleSize = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _titleLabel.font}];
    _titleLabel.frame = CGRectMake(15., 0, titleSize.width, 20.);
    _titleLabel.textColor = [UIColor hex:@"373745"];
    
    _starsView.frame = CGRectMake(_titleLabel.right, 0, 5 * (15. + 18.), 20.);
    for (UIView *view  in _starsView.subviews) {
        [view removeFromSuperview];
    }
    for (NSInteger i = 0; i <5; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (15. + 18.), _starsView.height/2 - 18./2, 18., 18.)];
        imageView.image = [self.serviceModel.star integerValue] > i ? [UIImage imageNamed:@"star_blue"] :  [UIImage imageNamed:@"star_gray"];
        [_starsView addSubview:imageView];
    }
    
    _evaDescription.frame = CGRectMake(_starsView.left, _starsView.bottom + 15., self.width - _starsView.left - 15., 10);
    _evaDescription.font = [UIFont systemFontOfSize:14.];
    _evaDescription.textColor = [UIColor hex:@"858497"];
    _evaDescription.text = self.serviceModel.comments;
    _evaDescription.numberOfLines = 0;
    _evaDescription.lineBreakMode = NSLayoutFormatDirectionLeadingToTrailing;
    CGSize evaSize = [_evaDescription.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.*2 - 10.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _evaDescription.font} context:nil].size;
    _evaDescription.height = evaSize.height;
}
@end
