//
//  VOMineServiceListModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/28.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@protocol VOMineServiceListPageModel;
@interface VOMineServiceListModel : VOJSONModel

@property (nonatomic,strong) NSArray <VOMineServiceListPageModel>*list;
@property (nonatomic,copy) NSString *pageNum;

@property (nonatomic,copy) NSString *pageSize;
@property (nonatomic,copy) NSString *totalSize;
@end

@class VOMineServiceListProjectModel;
@class VOMineServiceListTypeModel;
@class VOMineServiceListUnitModel;
@protocol VOMineServiceImageModel;
@interface VOMineServiceListPageModel : VOJSONModel

@property (nonatomic,copy) NSString *comments;
@property (nonatomic,copy) NSString *descriptionService;

@property (nonatomic,copy) NSString *gmtCreate;
@property (nonatomic,copy) NSString *gmtModify;

@property (nonatomic,copy) NSArray <VOMineServiceImageModel>*images;
@property (nonatomic,strong) VOMineServiceListProjectModel *project;

@property (nonatomic,copy) NSString *projectUpkeepRecordId;
@property (nonatomic,copy) NSString *star;

@property (nonatomic,copy) NSString *status;
@property (nonatomic,strong) VOMineServiceListTypeModel *type;

@property (nonatomic,strong) VOMineServiceListUnitModel *unit;
@end

@protocol VOMineServiceListPageModel
@end


@interface VOMineServiceListProjectModel : VOJSONModel

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *projectCompanyId;

@property (nonatomic,copy) NSString *projectId;
@property (nonatomic,copy) NSString *regionCode;

@property (nonatomic,copy) NSString *status;
@end

@interface VOMineServiceListTypeModel : VOJSONModel

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *projectUpkeepTypeId;
@end

@interface VOMineServiceListUnitModel : VOJSONModel

@property (nonatomic,copy) NSString *buildingArea;
@property (nonatomic,copy) NSString *floor;

@property (nonatomic,copy) NSString *projectBuildingId;
@property (nonatomic,copy) NSString *projectBuildingName;

@property (nonatomic,copy) NSString *projectId;
@property (nonatomic,copy) NSString *projectUnitId;

@property (nonatomic,copy) NSString *projectUnitName;
@property (nonatomic,copy) NSString *projectUnitType;
@end

@interface VOMineServiceImageModel : VOJSONModel

@property (nonatomic,copy) NSString *attachmentId;
@property (nonatomic,copy) NSString *height;

@property (nonatomic,copy) NSString *sourceName;
@property (nonatomic,copy) NSString *url;

@property (nonatomic,copy) NSString *width;
@end

@protocol VOMineServiceImageModel
@end
