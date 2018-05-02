//
//  VOMineStarEvaView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VOStarBlock)(NSInteger index);
@interface VOMineStarEvaView : UIView

@property (nonatomic,copy) VOStarBlock starBlock;

+ (CGFloat)getWidth;
+ (CGFloat)getHeight;
@end
