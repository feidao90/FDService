//
//  VOApplyServiceTableViewCell.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VOApplyServiceTableViewCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *info;

//get cell height
+ (CGFloat)getCellHeight:(NSDictionary *)info;
@end

typedef void(^VOAddImageBlock)(void);
typedef void(^VOSelectedImageBlock)(NSInteger index);
typedef void(^VOUploadImagesBlock)(NSMutableArray *array);
@interface VOApplyServiceUploadImageTableViewCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic,copy) VOAddImageBlock addImageBlock;

@property (nonatomic,copy) VOSelectedImageBlock selectedImageBlock;
@property (nonatomic,strong) NSMutableArray *uploadImages;

@property (nonatomic,copy) VOUploadImagesBlock imagesBlock;

+ (CGFloat)getCellHeight:(NSDictionary *)info;
#pragma mark - 上传图片
- (void)uploadImageWithIndex:(NSInteger) index;
@end

typedef void(^VOInputTextBlock)(NSString *content);
@interface VOApplyServiceDescriptionTableViewCell : UITableViewCell

@property (nonatomic,strong) NSMutableDictionary *info;
@property (nonatomic,copy) VOInputTextBlock textBlock;

+ (CGFloat)getCellHeight:(NSDictionary *)info;
@end
