//
//  VOPrinterInputModel.h
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/5.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOJSONModel.h"

@interface VOPrinterInputModel : VOJSONModel

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *ext_printer_id;

@property (nonatomic,copy) NSString *printer_ip;
@end
