//
//  VOCloudPrinterViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/5.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"
#import "VOPrinterInputModel.h"

typedef void(^VOQRCodeFailureBlock)(void);
@interface VOCloudPrinterViewController : BaseViewController

@property (nonatomic,strong) VOPrinterInputModel *model;
@property (nonatomic,copy) VOQRCodeFailureBlock failureBlock;
@end
