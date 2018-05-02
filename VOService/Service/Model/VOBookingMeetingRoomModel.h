//
//  VOBookingMeetingRoomModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/29.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@protocol VOBookingMeetingRoomListModel;
@interface VOBookingMeetingRoomModel : VOJSONModel

@property (nonatomic,strong) NSArray <VOBookingMeetingRoomListModel>*list;
@property (nonatomic,copy) NSString *pageNum;

@property (nonatomic,copy) NSString *pageSize;
@property (nonatomic,copy) NSString *totalSize;
@end

@protocol VOBookingMeetingRoomPictureDetailModel;
@class VOBookingMeetingRoomToastViewModel;
@class VOBookingMeetingRoomBottomViewModel;
@interface VOBookingMeetingRoomListModel : VOJSONModel

@property (nonatomic,copy) NSString *bookingDay;
@property (nonatomic,copy) NSString *bookingStatus;

@property (nonatomic,copy) NSString *buildingName;
@property (nonatomic,copy) NSString *capacity;

@property (nonatomic,copy) NSString *cityCode;
@property (nonatomic,copy) NSString *cityName;

@property (nonatomic,copy) NSString *floor;
@property (nonatomic,copy) NSString *gmtCreate;

@property (nonatomic,copy) NSString *gmtModified;
@property (nonatomic,copy) NSString *meetingRoomId;

@property (nonatomic,copy) NSString *meetingRoomName;
@property (nonatomic,strong) NSArray<VOBookingMeetingRoomPictureDetailModel> *pictures;

@property (nonatomic,copy) NSString *price;
@property (nonatomic,copy) NSString *projectId;

@property (nonatomic,copy) NSString *projectName;
@property (nonatomic,copy) NSString *status;

@property (nonatomic,copy) NSString *supporting;
//view - model
@property (nonatomic,strong) VOBookingMeetingRoomToastViewModel *viewModel;

//view-mode
@property (nonatomic,strong) VOBookingMeetingRoomBottomViewModel *bottomModel;
@end

@protocol VOBookingMeetingRoomListModel
@end

@interface VOBookingMeetingRoomPictureDetailModel : VOJSONModel

@property (nonatomic,copy) NSString *attachmentId;
@property (nonatomic,copy) NSString *height;

@property (nonatomic,copy) NSString *sourceName;
@property (nonatomic,copy) NSString *url;

@property (nonatomic,copy) NSString *width;
@end

@protocol VOBookingMeetingRoomPictureDetailModel
@end

/*
 view -model
 */
@interface VOBookingMeetingRoomToastViewModel : VOJSONModel

@property (nonatomic) CGRect frame;
@property (nonatomic,assign) BOOL isHidden;

@property (nonatomic) CGPoint contentOffset;
@property (nonatomic,assign) BOOL isUnavailable;
@end

/*
 view -model
 */
@interface VOBookingMeetingRoomBottomViewModel : VOJSONModel

@property (nonatomic,assign) BOOL leftEnable;
@property (nonatomic,copy) NSString *title ;

@property (nonatomic,copy) NSString *nextTitle;
@property (nonatomic,assign) BOOL rightEnable;

@property (nonatomic,assign) BOOL nextEnable;
@end
