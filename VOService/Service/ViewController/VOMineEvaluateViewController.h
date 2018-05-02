//
//  VOMineEvaluateViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "BaseViewController.h"
#import "VOMineServiceListModel.h"

typedef void(^VOMineFinishedEvaBlock)(void);
@interface VOMineEvaluateViewController : BaseViewController

@property (nonatomic,strong) VOMineServiceListPageModel *serviceModel;
@property (nonatomic,copy) VOMineFinishedEvaBlock successBlock;
@end
