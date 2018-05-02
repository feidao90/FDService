//
//  VOMineServiceHeaderView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/4.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void  (^CompleteBlock)(NSInteger index);
@interface VOMineServiceHeaderView : UIView

@property (nonatomic,copy) CompleteBlock completeSelect;
@end
