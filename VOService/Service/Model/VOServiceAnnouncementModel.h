//
//  VOServiceAnnouncementModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/22.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@protocol VOServiceAnnouncementListModel;
@interface VOServiceAnnouncementModel : VOJSONModel

@property (nonatomic,strong) NSArray<VOServiceAnnouncementListModel>*list;
@property (nonatomic,copy) NSString *pageNum;

@property (nonatomic,copy) NSString *pageSize;
@property (nonatomic,copy) NSString *totalSize;
@end

@class  VOServiceAnnouncementProjectModel;
@interface VOServiceAnnouncementListModel : VOJSONModel

@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *gmtCreate;

@property (nonatomic,copy) NSString *gmtModified;
@property (nonatomic,copy) NSString *isValidity;

@property (nonatomic,copy) NSString *num;
@property (nonatomic,strong) VOServiceAnnouncementProjectModel *project;

@property (nonatomic,copy) NSString *projectAnnouncementId;
@property (nonatomic,copy) NSString *subject;
@end

@protocol VOServiceAnnouncementListModel
@end

@interface VOServiceAnnouncementProjectModel : VOJSONModel

@property (nonatomic,copy) NSString *dateOpening;
@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *projectCompanyId;
@property (nonatomic,copy) NSString *projectId;

@property (nonatomic,copy) NSString *regionCode;
@property (nonatomic,copy) NSString *status;
@end
