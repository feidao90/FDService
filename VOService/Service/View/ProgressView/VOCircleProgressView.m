//
//  VOCircleProgressView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/24.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOCircleProgressView.h"
@implementation VOCircleProgressView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress >= 1.0) {
            [self removeFromSuperview];
        } else {
            [self setNeedsDisplay];
        }
    });
}

// 清除指示器
- (void)dismiss
{
    self.progress = 1.0;
}

+ (id)progressView
{
    return [[self alloc] init];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - 10;
    
    // 背景遮罩
    if (!_isError) {
        [[UIColor hex:@"000000" alpha:.6] set];
        CGFloat lineW = MAX(rect.size.width, rect.size.height) * 0.5;
        CGContextSetLineWidth(ctx, lineW);
        CGContextAddArc(ctx, xCenter, yCenter, radius + lineW * 0.5 + 5, 0, M_PI * 2, 1);
        CGContextStrokePath(ctx);
    }
    
    // 进程圆
    if (!_isError) {
        CGContextSetLineWidth(ctx, 1);
        CGContextMoveToPoint(ctx, xCenter, yCenter);
        CGContextAddLineToPoint(ctx, xCenter, 0);
        CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
        CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
    }
    
    //错误页面
    if (_isError) {
        //遮罩
        [[UIColor hex:@"000000" alpha:.6] set];
        //绘制实心矩形
        UIRectFill(rect);
        
        /**
         *  画空心圆
         */
        CGRect bigRect = CGRectMake(rect.size.width/2 - 38./2,
                                    rect.size.height/2 - 38./2,
                                    38.,
                                    38.);
        
        //设置空心圆的线条宽度
        CGContextSetLineWidth(ctx, 2);
        //以矩形bigRect为依据画一个圆
        CGContextAddEllipseInRect(ctx, bigRect);
        //填充当前绘画区域的颜色
        [[UIColor hex:@"FF5A60"] set];
        //(如果是画圆会沿着矩形外围描画出指定宽度的（圆线）空心圆)/（根据上下文的内容渲染图层）
        CGContextStrokePath(ctx);
        
        //错误图片
        // 裁剪图片
        UIImage *image = [UIImage imageNamed:@"warning"];
        // 把图片加入smallRect的矩形区域内，超过上面设定的裁剪区域的部分将被裁剪掉
        [image drawInRect:CGRectMake(rect.size.width/2 - image.size.width/2, rect.size.height/2 - image.size.height/2, image.size.width, image.size.height)];
        // 将上下文的内容渲染到视图的layer图层上
        CGContextStrokePath(ctx);
    }
}

@end
