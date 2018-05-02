//
//  VOServicePhoneViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^VOCompletePhoneNum)(NSString *text);
@interface VOServicePhoneViewController : BaseViewController

@property (nonatomic,copy) NSString *phoneNum;
@property (nonatomic,copy) VOCompletePhoneNum completeBlock;
@end
