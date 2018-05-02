//
//  VOPropertyListModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@protocol VOPropertyListTypeModel;
@interface VOPropertyListModel : VOJSONModel

@property (nonatomic,copy) NSString *projectId;
@property (nonatomic,copy) NSArray *telephones;

@property (nonatomic,strong) NSArray <VOPropertyListTypeModel>*types;
@end


@class VOPropertyListIconModel;
@interface VOPropertyListTypeModel : VOJSONModel

@property (nonatomic,copy) NSString *comment;
@property (nonatomic,copy) NSString *gmtCreate;

@property (nonatomic,copy) NSString *gmtModify;
@property (nonatomic,strong) VOPropertyListIconModel *icon;

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *projectId;

@property (nonatomic,copy) NSString *projectUpkeepTypeId;
@property (nonatomic,copy) NSString *required;

@property (nonatomic,copy) NSString *selected;
@end

@protocol VOPropertyListTypeModel
@end

@interface VOPropertyListIconModel : VOJSONModel

@property (nonatomic,copy) NSString *attachmentId;
@property (nonatomic,copy) NSString *height;

@property (nonatomic,copy) NSString *sourceName;
@property (nonatomic,copy) NSString *url;

@property (nonatomic,copy) NSString *width;
@end
