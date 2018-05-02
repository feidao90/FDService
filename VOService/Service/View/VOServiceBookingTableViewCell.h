//
//  VOServiceBookingTableViewCell.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOBookingMeetingRoomModel.h"

typedef void(^VOBookingCellReloadBlock)(void);
typedef void(^VOBookingJumpBlock)(void);
@interface VOServiceBookingTableViewCell : UITableViewCell

@property (nonatomic,strong) VOBookingMeetingRoomListModel *model;
@property (nonatomic,copy) VOBookingCellReloadBlock reloadBlock;

@property (nonatomic,copy) VOBookingJumpBlock jumpBlock;
@property (nonatomic,strong) NSDate *unvalibleDate;

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(VOBookingMeetingRoomListModel *)model;
@end
