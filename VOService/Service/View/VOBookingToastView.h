//
//  VOBookingToastView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/31.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VOMovingBlock)(CGFloat offsetX);
typedef void(^VOEndMovingBlock)(void);

typedef void(^VOResetWidthBlock)(CGFloat offsetX);
typedef void(^VOEndResetWidthBlock)(void);
@interface VOBookingToastView : UIView

@property (nonatomic,copy) VOMovingBlock movingBlock;
@property (nonatomic,copy) VOResetWidthBlock widthBlock;

@property (nonatomic,copy) VOEndMovingBlock endBlock;
@property (nonatomic,copy) VOEndResetWidthBlock endWidthBlock;
@end
