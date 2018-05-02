//
//  VOPrinterFileListModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/5.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@protocol VOPrinterFileListDetailModel;
@interface VOPrinterFileListModel : VOJSONModel

@property (nonatomic,copy) NSString *errcode;
@property (nonatomic,copy) NSString *errmsg;

@property (nonatomic,copy) NSString *jobIds;
@property (nonatomic,strong) NSArray<VOPrinterFileListDetailModel> *list;

@property (nonatomic,copy) NSString *scanCodePrintType;
@property (nonatomic,copy) NSString *total;
@end

@interface VOPrinterFileListDetailModel : VOJSONModel

@property (nonatomic,copy) NSString *color;
@property (nonatomic,copy) NSString *copies;

@property (nonatomic,copy) NSString *createOn;
@property (nonatomic,copy) NSString *docName;

@property (nonatomic,copy) NSString *double_print;
@property (nonatomic,copy) NSString *jobId;

@property (nonatomic,copy) NSString *orientation;
@property (nonatomic,copy) NSString *page_size;

@property (nonatomic,copy) NSString *page_type;
@property (nonatomic,copy) NSString *paper_source;

@property (nonatomic,copy) NSString *printed_page_count;
@property (nonatomic,copy) NSString *state;

@property (nonatomic,copy) NSString *submit_time;
@property (nonatomic,copy) NSString *total_page;

@property (nonatomic,copy) NSString *userName;
//view property
@property (nonatomic,assign) BOOL isSelected;
@end

@protocol VOPrinterFileListDetailModel
@end
