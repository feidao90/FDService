//
//  VOBookingMeetingTableViewCell.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/1.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VOBookingMeetingTableViewCell : UITableViewCell

@property (nonatomic,copy) NSDictionary *info;

+ (CGFloat)getCellHeight:(NSDictionary *)info;
@end
