//
//  VOEvaluateView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOMineServiceListModel.h"

@interface VOEvaluateView : UIView

@property (nonatomic,strong) VOMineServiceListPageModel *serviceModel;

+ (CGFloat)getHeight:(VOMineServiceListPageModel *)serviceModel;
@end
