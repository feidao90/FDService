//
//  VOBookingMeetingEditViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/1.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"
#import "VOBookingMeetingRoomModel.h"

typedef void(^VOBookingClearBlock)(void);
@interface VOBookingMeetingEditViewController : BaseViewController

@property (nonatomic,strong) VOBookingMeetingRoomListModel *model;
@property (nonatomic,copy) NSString *bookingDay;

@property (nonatomic,strong) NSDate *unvalibleDate;
@property (nonatomic,strong) VOBookingClearBlock clearBlock;
@end
