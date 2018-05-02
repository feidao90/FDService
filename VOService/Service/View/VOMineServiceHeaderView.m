//
//  VOMineServiceHeaderView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/4.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineServiceHeaderView.h"

#define kIndexTag 0xDDDDDD
@interface VOMineServiceHeaderView()
{
    UIButton *lastSelectedButton;
}
@end

@implementation VOMineServiceHeaderView

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
    //圆角
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.layer.cornerRadius = 2.;
    self.layer.masksToBounds = YES;
    
    //边框
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.;
    
    
    //subviews
    NSArray *titleList = @[@"全部",@"未处理",@"处理中",@"已完成"];
    
    for (NSString *title in titleList)
    {
        NSInteger index = [titleList indexOfObject:title];
        UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempButton setTitle:title forState:UIControlStateNormal];
        if (!index)     //默认选择第一个
        {
            [tempButton setTitleColor:[UIColor hex:@"373745"] forState:UIControlStateNormal];
            tempButton.backgroundColor = [UIColor whiteColor];
            lastSelectedButton = tempButton;
        }else
        {
            [tempButton setTitleColor:[UIColor hex:@"FFFFFF"] forState:UIControlStateNormal];
            tempButton.backgroundColor = [UIColor hex:@"45536F"];
        }
        tempButton.tag = kIndexTag + index;
        [tempButton addTarget:self action:@selector(didSelectedIndex:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - button action
- (void)didSelectedIndex:(UIButton *)button
{
    if (button != lastSelectedButton)
    {
        [button setTitleColor:[UIColor hex:@"373745"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        
        [lastSelectedButton setTitleColor:[UIColor hex:@"FFFFFF"] forState:UIControlStateNormal];
        lastSelectedButton.backgroundColor = [UIColor hex:@"45536F"];
        
        lastSelectedButton = button;
        
        self.completeSelect(button.tag - kIndexTag);
    }
}
@end
