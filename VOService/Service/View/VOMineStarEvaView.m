//
//  VOMineStarEvaView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineStarEvaView.h"

#define  kVOStarTag 0xDDDDDD
@interface VOMineStarEvaView()
{
    NSInteger lastIndex;
}
@end

@implementation VOMineStarEvaView
-(instancetype)init
{
    if (self = [super init]) {
        [self _initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

+ (CGFloat)getWidth
{
    return 35.*5 + 20.*4;
}

+ (CGFloat)getHeight
{
    return 35.;
}

#pragma mark  - _initSubViews
- (void)_initSubViews
{
    lastIndex = -1;
    for (int i = 0; i < 5; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * (20. + 35.), 0, 35., 35.)];
        [button setImage:[UIImage imageNamed:@"star_gray"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(starIndex:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = kVOStarTag + i;
        [self addSubview:button];
    }
}

- (void)starIndex:(UIButton *)button
{
    NSInteger index = button.tag - kVOStarTag;
    if (lastIndex == index)
    {
        return;
    }
    if (self.starBlock) {
        self.starBlock(index);
    }
    
    for (int i = 0; i < 5; i ++)
    {
        UIButton *button = [self viewWithTag:kVOStarTag + i];
        if (i>index)
        {
            [button setImage:[UIImage imageNamed:@"star_gray"] forState:UIControlStateNormal];
        }else
        {
            [button setImage:[UIImage imageNamed:@"star_blue"] forState:UIControlStateNormal];
        }
    }
    lastIndex = index;
}
@end
