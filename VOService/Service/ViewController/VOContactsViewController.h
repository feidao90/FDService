//
//  VOContactsViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^VOCompleteContactName)(NSString *text);
@interface VOContactsViewController : BaseViewController

@property (nonatomic,copy) NSString *contactName;
@property (nonatomic,copy) VOCompleteContactName completeBlock;
@end
