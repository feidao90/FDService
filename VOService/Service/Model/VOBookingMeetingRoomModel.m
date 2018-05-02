//
//  VOBookingMeetingRoomModel.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/29.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingMeetingRoomModel.h"

@implementation VOBookingMeetingRoomModel

@end

@implementation VOBookingMeetingRoomListModel
-(id)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super initWithJSONDictionary:dict]) {
        VOBookingMeetingRoomToastViewModel *viewModel = [[VOBookingMeetingRoomToastViewModel alloc] init];
        viewModel.contentOffset = CGPointMake(-1, -1);
        viewModel.isHidden = YES;
        viewModel.isUnavailable = NO;
        self.viewModel = viewModel;
        
        VOBookingMeetingRoomBottomViewModel *bottomModel = [VOBookingMeetingRoomBottomViewModel new];
        bottomModel.leftEnable = NO;
        bottomModel.title = @"请选择时间段";
        bottomModel.nextTitle = @"下一步";
        bottomModel.rightEnable = YES;
        bottomModel.nextEnable = NO;
        self.bottomModel = bottomModel;
    }
    return self;
}
@end

@implementation VOBookingMeetingRoomPictureDetailModel

@end


@implementation VOBookingMeetingRoomToastViewModel
@end

@implementation VOBookingMeetingRoomBottomViewModel
@end


