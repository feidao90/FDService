//
//  VOCircleProgressView.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/24.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VOCircleProgressView : UIButton

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic,assign) BOOL isError;

- (void)dismiss;
+ (id)progressView;
@end
