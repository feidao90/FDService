//
//  VOBookingScrollView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/31.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingScrollView.h"
#import "VOBookingToastView.h"

@implementation VOBookingScrollView
-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[VOBookingToastView class]])
    {
        return NO;
    }
    return YES;
}

-(BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if ([view isKindOfClass:[VOBookingToastView class]])
    {
        return YES;
    }
    return NO;
}
@end
