//
//  VOServiceAnnouncementView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/22.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOServiceAnnouncementModel.h"

@interface VOServiceAnnouncementView : UIView

@property (nonatomic,strong) VOServiceAnnouncementListModel *model;

+ (CGFloat)maxHeight;
@end
