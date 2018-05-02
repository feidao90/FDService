//
//  VOBookingTimeView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOBookingMeetingRoomModel.h"

typedef void(^VOBookingRefreshBlock)(void);
@interface VOBookingTimeView : UIView

@property (nonatomic,strong) VOBookingMeetingRoomListModel *model;
@property (nonatomic,copy) VOBookingRefreshBlock refreshBlock;

@property (nonatomic,strong) NSDate *unvalibleDate;
@end
