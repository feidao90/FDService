//
//  VOBookingToastView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/31.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingToastView.h"

@interface VOBookingToastView()
{
    CGPoint startPoint;
    NSInteger movingType;
}
@end

@implementation VOBookingToastView

#pragma mark - touch method
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{    
    startPoint = [[touches anyObject] locationInView:[[touches anyObject] view]];
    if (startPoint.x > self.width - (SCREEN_WIDTH/11)/2)    //拉长
    {
        movingType = 1;

    }else   //拖动
    {
        movingType = 2;

    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint movePoint = [[touches anyObject] locationInView:[[touches anyObject] view]];
    switch (movingType) {
        case 1:
        {
            if (self.widthBlock) {
                self.widthBlock(movePoint.x - startPoint.x);
            }
            startPoint = movePoint;
        }
            break;
        case 2:
        {
            if (self.movingBlock) {
                self.movingBlock(movePoint.x - startPoint.x);
            }
        }
            break;
        default:
            break;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    switch (movingType) {
        case 1:
        {
            if (self.endWidthBlock) {
                self.endWidthBlock();
            }
        }
            break;
        case 2:
        {
            if (self.endBlock) {
                self.endBlock();
            }
        }
            break;
        default:
            break;
    }
}
@end
