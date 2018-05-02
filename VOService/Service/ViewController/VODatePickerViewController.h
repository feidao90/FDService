//
//  VODatePickerViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^VOCompleteDateSelectedBlock)(NSString *dateString,NSString *bookingDate);
@interface VODatePickerViewController : BaseViewController

@property (nonatomic,copy) VOCompleteDateSelectedBlock selectBlock;
@end
