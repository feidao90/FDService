//
//  VOServicePropertyCollectionViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServicePropertyCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface VOServicePropertyCollectionViewCell()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    
    UILabel *_contentLabel;
}
@end

@implementation VOServicePropertyCollectionViewCell
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
    _imageView = [UIImageView new];
    [self addSubview:_imageView];
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    [self addSubview:_contentLabel];
}

#pragma mark -
-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(self.width/2 - 60./2, 24., 60., 60.);
    [_imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_120,h_120/auto-orient,1",self.model.icon.url]]];
    
    _titleLabel.frame = CGRectMake(24., _imageView.bottom + 8., self.width - 24.*2, 20.);
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
    _titleLabel.textColor = [UIColor hex:@"858497"];
    _titleLabel.text = self.model.name;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _contentLabel.font = [UIFont systemFontOfSize:11.];
    _contentLabel.textColor = [UIColor hex:@"B2B1C0"];
    _contentLabel.numberOfLines = 0;
    _contentLabel.text = self.model.comment;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    CGSize contentSize = [_contentLabel textRectForBounds:CGRectMake(0, 0, self.width - 24.*2, 5000) limitedToNumberOfLines:2].size;
    _contentLabel.frame = CGRectMake(24., _titleLabel.bottom, self.width - 24.*2, contentSize.height);
}
@end
