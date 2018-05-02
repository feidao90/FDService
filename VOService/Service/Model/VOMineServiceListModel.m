//
//  VOMineServiceListModel.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/28.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOMineServiceListModel.h"

@implementation VOMineServiceListModel
@end

@implementation VOMineServiceListPageModel
-(id)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super initWithJSONDictionary:dict]) {
        self.descriptionService = [dict safeObjectForKey:@"description"];
    }
    return self;
}
@end

@implementation VOMineServiceListProjectModel
@end

@implementation VOMineServiceListTypeModel
@end

@implementation VOMineServiceListUnitModel
@end

@implementation VOMineServiceImageModel
@end
