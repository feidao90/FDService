//
//  VOMineServiceListTableViewCell.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/4.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOMineServiceListModel.h"

typedef void(^VOMineServiceCancleBlock)(void);
typedef void(^VOMineServiceEvaluateBlock)(void);
@interface VOMineServiceListTableViewCell : UITableViewCell

@property (nonatomic,strong) VOMineServiceListPageModel *serviceModel;
@property (nonatomic,copy) VOMineServiceCancleBlock cancleBlock;

@property (nonatomic,copy) VOMineServiceEvaluateBlock evaluateBlock;

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(VOMineServiceListPageModel *)serviceModel;
@end
