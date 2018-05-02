//
//  VODiagonalView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VODiagonalView.h"

@implementation VODiagonalView

- (void)drawRect:(CGRect)rect
{
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGFloat heightSpace = height/8;
    
     NSInteger percent = width/heightSpace + 8;
    for (int i = 0; i < percent; i ++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, heightSpace+ i * heightSpace > width ? width : heightSpace+ i * heightSpace,
                             heightSpace+ i * heightSpace > width ?  heightSpace * (i - (NSInteger)width/heightSpace + 1) : 0);
        //增加点
        CGContextAddLineToPoint(context,(heightSpace +i * heightSpace - height) > 0 ?  (heightSpace +i * heightSpace - height) : 0,
                                heightSpace +i * heightSpace - height > 0 ?  height : (i + 1) * heightSpace);
        //关闭路径
        CGContextClosePath(context);
        [[UIColor hex:@"B2B1C0" alpha:.5]  setStroke];
        
        //4.绘制路径
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}
@end
