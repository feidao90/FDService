//
//  VOBookingChangeTimeView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/31.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOBookingMeetingRoomModel.h"

typedef void(^VOReduceBlock)(void);
typedef void(^VOPlusBlock)(void);

typedef void(^VOCancleBlock)(void);
typedef void(^VONextBlock)(void);
@interface VOBookingChangeTimeView : UIView

@property (nonatomic,strong) VOBookingMeetingRoomListModel *model;
@property (nonatomic,copy) VOReduceBlock reduceBlock;

@property (nonatomic,copy) VOPlusBlock plusBlock;
@property (nonatomic,copy) VOCancleBlock cancleBlock;

@property (nonatomic,copy) VONextBlock nextBlock;
@property (nonatomic,assign) BOOL isHiddeBottom;
@end
