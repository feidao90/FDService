//
//  VOServiceBookingHeaderView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/29.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VOBookingSelectedIndexBlock)(NSInteger index);
@interface VOServiceBookingHeaderView : UIView

@property (nonatomic,copy) VOBookingSelectedIndexBlock indexBlock;

- (void)setLastIndexSelected:(NSString *)dateString;
@end
