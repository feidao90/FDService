//
//  VOBookingSuccessModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/2.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"
#import "VOBookingMeetingRoomModel.h"

@class VOBookingSuccessDetailModel;
@interface VOBookingSuccessModel : VOJSONModel

@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *bookingDay;

@property (nonatomic,copy) NSString *bookingHalfHourTotal;
@property (nonatomic,copy) NSString *bookingHourRange;

@property (nonatomic,copy) NSString *cancelTime;
@property (nonatomic,strong) VOBookingSuccessDetailModel *detail;

@property (nonatomic,copy) NSString *gmtCreate;
@property (nonatomic,copy) NSString *meetingRoomId;

@property (nonatomic,copy) NSString *meetingRoomOrderId;
@property (nonatomic,copy) NSString *orderNum;

@property (nonatomic,copy) NSString *paymentType;
@property (nonatomic,copy) NSString *status;

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *user;
@end


@interface VOBookingSuccessDetailModel : VOJSONModel

@property (nonatomic,copy) NSString *buildingId;
@property (nonatomic,copy) NSString *buildingName;

@property (nonatomic,copy) NSString *capacity;
@property (nonatomic,copy) NSString *cityCode;

@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *floor;

@property (nonatomic,copy) NSString *meetingRoomId;
@property (nonatomic,copy) NSString *meetingRoomName;

@property (nonatomic,strong) NSArray <VOBookingMeetingRoomPictureDetailModel>*pictures;
@property (nonatomic,copy) NSString *projectId;

@property (nonatomic,copy) NSString *projectName;
@property (nonatomic,copy) NSString *supporting;
@end
