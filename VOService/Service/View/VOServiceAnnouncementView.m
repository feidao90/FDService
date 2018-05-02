//
//  VOServiceAnnouncementView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/22.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServiceAnnouncementView.h"

@interface VOServiceAnnouncementView()
{
    UILabel *_titleLabel;
    UILabel *_contentLabel;
}
@end

@implementation VOServiceAnnouncementView
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

#pragma mark - get height
+ (CGFloat)maxHeight
{
    return 220. + 20. + 20. + 20. + 24.;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{    
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 2.;
    self.layer.masksToBounds = YES;
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    [self addSubview:_contentLabel];
}

#pragma mark - layoutSubViews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.];
    _titleLabel.frame = CGRectMake(20, 20., self.width - 20.*2, 24.);
    _titleLabel.text = self.model.subject;
    
    _contentLabel.textColor = [UIColor hex:@"373745"];
    _contentLabel.numberOfLines = 0;    
    _contentLabel.frame = CGRectMake(20., _titleLabel.bottom + 20., self.width - 20.*2, 20);
    _contentLabel.font = [UIFont systemFontOfSize:14.];
    _contentLabel.text = self.model.content;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize contentSize = [_contentLabel.text boundingRectWithSize:CGSizeMake(_contentLabel.width, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _contentLabel.font} context:nil].size;
    if (contentSize.height > self.height - _contentLabel.top - 20.) {
        contentSize.height = self.height - _contentLabel.top - 20.;
    }
    _contentLabel.height = contentSize.height;
   
}
@end
