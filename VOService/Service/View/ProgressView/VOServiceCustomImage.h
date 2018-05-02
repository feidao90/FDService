//
//  VOServiceCustomImage.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/26.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VOServiceCustomImage : UIImage

@property (nonatomic,assign) BOOL isStartLoading;
@property (nonatomic,assign) BOOL isError;

@property (nonatomic,strong) NSError *error;
@end
