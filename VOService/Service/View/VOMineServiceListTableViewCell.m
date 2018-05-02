//
//  VOMineServiceListTableViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/4.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineServiceListTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "VOServicePaceView.h"
#import "VOEvaluateView.h"

@interface VOMineServiceListTableViewCell()
{
    UIView *_backView;
    UILabel *_serviceStatus;
    
    UIView *_toplineView;
    UILabel *_startTime;
    
    UILabel *_serviceLocation;
    UILabel *_serviceType;
    
    UILabel *_serviceDes;
    UILabel *_serviceDesTitle;
    
    UILabel *_modifyTime;
    UIScrollView *_picsImageView;
    
    VOServicePaceView *_paceView;
    UIView *_lineView;
    
    UIButton *_serviceAction;
    VOEvaluateView *_evaView;
}
@end

@implementation VOMineServiceListTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _InitSubView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self _InitSubView];
}

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(VOMineServiceListPageModel *)serviceModel
{
    CGFloat offsetY = 0;
    //服务状态
    offsetY += 13. +20;
    //line view
    offsetY += 5. + 1.;
    //服务时间
    offsetY += 15. + 20.;
    //服务地点
    offsetY += 10. + 20.;
    //服务类型
    offsetY += 10. + 20.;
    //服务描述
    UILabel *_serviceDes = [UILabel new];
    _serviceDes.numberOfLines = 0;
    _serviceDes.font = [UIFont systemFontOfSize:14.];
    _serviceDes.text = serviceModel.descriptionService;
    _serviceDes.textColor = [UIColor hex:@"858497"];
    CGSize titleSize = [@"描述：" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.]}];
    CGFloat desWidth = SCREEN_WIDTH - 10.*2 - titleSize.width - 15.*2;
    CGSize desSize = [_serviceDes.text boundingRectWithSize:CGSizeMake(desWidth, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _serviceDes.font} context:nil].size;
    offsetY += 20 + desSize.height;
    //图片
    if (serviceModel.images.count)
    {
        offsetY += 15. + 100.;
    }
    //服务更新时间
    if ([serviceModel.status integerValue] == 1 || [serviceModel.status integerValue] == 2 || [serviceModel.status integerValue] == 3 || [serviceModel.status integerValue] == 4)   //服务-处理中、已完成 才显示进度
    {
        offsetY += (serviceModel.images.count ? 15. : 10) + 20.;
    }
    //服务进度
    if ([serviceModel.status integerValue] != 5.)
    {
        offsetY += 10. + 30.;
    }
    //line view
    if ([serviceModel.status integerValue] == 1 || [serviceModel.status integerValue] == 3 || [serviceModel.status integerValue] == 4)
    {
        offsetY += 20. + 1;
    }
    
    //服务取消&&评价
    if ([serviceModel.status integerValue] == 1 || [serviceModel.status integerValue] == 3)
    {
        offsetY += 10. + 33.;
    }
    //评价
    if ([serviceModel.status integerValue] == 4) {
        CGFloat evaHeight = [VOEvaluateView getHeight:serviceModel];
        offsetY += 10. + evaHeight;
    }
    offsetY += 10. + 10.;
    return offsetY;
}

#pragma mark - _InitSubView
- (void)_InitSubView
{
    _backView = [[UIView alloc] init];
    [self addSubview:_backView];
    
    //服务状态
    _serviceStatus = [[UILabel alloc] init];
    [_backView addSubview:_serviceStatus];
    
    //line view
    _toplineView = [[UIView alloc] init];
    [_backView addSubview:_toplineView];
    
    
    //服务时间
    _startTime = [UILabel new];
    [_backView addSubview:_startTime];
    
    //服务地点
    _serviceLocation = [UILabel new];
    [_backView addSubview:_serviceLocation];
    
    //服务类型
    _serviceType = [UILabel new];
    [_backView addSubview:_serviceType];
    
    //服务描述
    _serviceDes = [UILabel new];
    [_backView addSubview:_serviceDes];
    
    //title
    _serviceDesTitle = [UILabel new];
    [_backView addSubview:_serviceDesTitle];
    
    //服务更新时间
    _modifyTime = [UILabel new];
    [_backView addSubview:_modifyTime];
    
    //服务进度
    _paceView = [VOServicePaceView new];
    [_backView addSubview:_paceView];
    
    //line view
    _lineView = [UIView new];
    [_backView addSubview:_lineView];
    
    //服务取消&&评价
    _serviceAction = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backView addSubview:_serviceAction];
    //评价
    _evaView = [VOEvaluateView new];
    [_backView addSubview:_evaView];
    
    //服务图片
    _picsImageView = [UIScrollView new];
    [_backView addSubview:_picsImageView];
}

#pragma mark - layoutsubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL isCancle = self.serviceModel.status.integerValue == 5;
    _backView.frame = CGRectMake(10., 0, SCREEN_WIDTH - 10.*2, 0);
    _backView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _backView.layer.cornerRadius = 2.;
    _backView.layer.masksToBounds = YES;
    
    //服务状态
    _serviceStatus.frame = CGRectMake(15., 13., _backView.width - 15.*2, 20.);
    _serviceStatus.backgroundColor = [UIColor clearColor];
    _serviceStatus.font = [UIFont boldSystemFontOfSize:14.];
    _serviceStatus.textAlignment = NSTextAlignmentLeft;
    _serviceStatus.textColor = isCancle ? [UIColor hex:@"B1B2C0"] : [UIColor hex:@"58A5F7"];
    switch ([self.serviceModel.status integerValue]) {
        case 1: //未处理
        {
            _serviceStatus.text = @"未处理";
        }
            break;
        case 2: //处理中
        {
            _serviceStatus.text = @"处理中";
        }
            break;
        case 3: //已完成
        {
            _serviceStatus.text = @"已完成";
        }
            break;
        case 4: //  已评价
        {
            _serviceStatus.text = @"已评价";
        }
            break;
        case 5: //已取消
        {
            _serviceStatus.text = @"已取消";
        }
            break;
        default:
            break;
    }
    
    //line view
    _toplineView.backgroundColor = [UIColor hex:@"979797" alpha:.2];
    _toplineView.frame = CGRectMake(15., _serviceStatus.bottom + 5., _backView.width - 15.*2, 1);
    
    //服务时间
    _startTime.frame = CGRectMake(15., _toplineView.bottom + 15., _backView.width - 15.*2, 20.);
    [self setSempleLabel:_startTime];
    
    [self setLabelWithStander:_startTime title:@"时间：" info:[NSString formatterMonthTime:self.serviceModel.gmtCreate]];
    //服务地点
    _serviceLocation.frame = CGRectMake(15., _startTime.bottom + 10, _backView.width - 15.*2, 20.);
    [self setSempleLabel:_serviceLocation];
    [self setLabelWithStander:_serviceLocation title:@"地点：" info:self.serviceModel.project.name];
    //服务类型
    _serviceType.frame = CGRectMake(15., _serviceLocation.bottom + 10, _backView.width - 15.*2, 20.);
    [self setSempleLabel:_serviceType];
    [self setLabelWithStander:_serviceType title:@"类型：" info:self.serviceModel.type.name.length ? self.serviceModel.type.name : @""];
    //服务描述title
    _serviceDesTitle.frame =CGRectMake(15., _serviceType.bottom + 10, 10, 20.);
    [self setSempleLabel:_serviceDesTitle];
    _serviceDesTitle.text = @"描述：";
    _serviceDesTitle.textColor =  isCancle ? [UIColor hex:@"B1B2C0"] : [UIColor hex:@"373745"];
    CGSize titleSize = [_serviceDesTitle.text sizeWithAttributes:@{NSFontAttributeName : _serviceDesTitle.font}];
    _serviceDesTitle.width = titleSize.width;
    //服务描述
    _serviceDes.frame = CGRectMake(_serviceDesTitle.right,  _serviceDesTitle.top, _backView.width - 15. - _serviceDesTitle.right, 20.);
    [self setSempleLabel:_serviceDes];
    //reset label
    _serviceDes.numberOfLines = 0;
    _serviceDes.text = self.serviceModel.descriptionService;
    _serviceDes.textColor = isCancle ? [UIColor hex:@"B1B2C0"] :  [UIColor hex:@"858497"];
    CGSize desSize = [_serviceDes.text boundingRectWithSize:CGSizeMake(_serviceDes.width, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _serviceDes.font} context:nil].size;
    _serviceDes.height = desSize.height;
    
    CGFloat offsetY = 10 + _serviceDes.bottom;
    //服务图片
    if (self.serviceModel.images.count)
    {
        for (UIView *view in _picsImageView.subviews)
        {
            [view removeFromSuperview];
        }
        _picsImageView.hidden = NO;
        _picsImageView.frame = CGRectMake(15., _serviceDes.bottom + 15., _backView.width - 15.*2, 100.);
        NSInteger picCount = self.serviceModel.images.count;
        CGFloat contentWidth = picCount > 1 ? (picCount * 100 + (picCount-1)*10.) : _picsImageView.width;
        _picsImageView.contentSize = CGSizeMake(contentWidth, _picsImageView.height);
        if (picCount > 1)
        {
            for (int i =0; i < picCount; i ++)
            {
                VOMineServiceImageModel *imageModel = [self.serviceModel.images safeObjectAtIndex:i];
                UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(i *(100. + 10.), 0, 100., 100.)];
                [picImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_200,h_200/auto-orient,1",imageModel.url]]];
                picImage.contentMode = UIViewContentModeScaleAspectFill;
                [_picsImageView addSubview:picImage];
            }
        }else
        {
            VOMineServiceImageModel *imageModel = [self.serviceModel.images safeObjectAtIndex:0];
            UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _picsImageView.width, _picsImageView.height)];
            NSInteger imageWidth = _picsImageView.width;
            picImage.contentMode = UIViewContentModeScaleAspectFill;
            [picImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_%ld,h_200/auto-orient,1",imageModel.url,(long)imageWidth]]];
            [_picsImageView addSubview:picImage];
        }
        offsetY += _picsImageView.height + 15.;
    }else
    {
        _picsImageView.hidden = YES;
    }
    //服务更新时间
    if ([self.serviceModel.status integerValue] == 1 || [self.serviceModel.status integerValue] == 2 || [self.serviceModel.status integerValue] == 3 || [self.serviceModel.status integerValue] == 4)   //服务-处理中、已完成 才显示进度
    {
        _modifyTime.frame = CGRectMake(15., offsetY + (_picsImageView.hidden ? 10. : 15.), SCREEN_WIDTH - 15.*2, 20.);
        [self setSempleLabel:_modifyTime];
        [self setLabelWithStander:_modifyTime title:@"进度：" info:[NSString stringWithFormat:@"更新于 %@",[NSString formatterMonthTime:self.serviceModel.gmtModify]]];
        offsetY += (_picsImageView.hidden ? 10. : 15.) + 20.;
    }else
    {
        _modifyTime.frame = CGRectZero;
    }
    
    //服务进度
    if ([self.serviceModel.status integerValue] != 5.)
    {
        _paceView.hidden = NO;
        _paceView.frame = CGRectMake(15., offsetY + 10., _backView.width - 15.*2, 30.);
        _paceView.statusType = [self.serviceModel.status integerValue];
        [_paceView setNeedsLayout];
        [_paceView layoutIfNeeded];
        offsetY += 10. + 30.;
    }else
    {
        _paceView.hidden = YES;
    }
    //line view
    if ([self.serviceModel.status integerValue] == 1 || [self.serviceModel.status integerValue] == 3 || [self.serviceModel.status integerValue] == 4)
    {
        _lineView.hidden = NO;
        _lineView.frame = CGRectMake(0, offsetY + 20., _backView.width, 1);
        _lineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.2];
        offsetY += 20. + 1;
    }else
    {
        _lineView.hidden = YES;
    }
    
    //服务取消&&评价
    if ([self.serviceModel.status integerValue] == 1 || [self.serviceModel.status integerValue] == 3)
    {
        _serviceAction.hidden = NO;
        _serviceAction.titleLabel.font = [UIFont systemFontOfSize:15.];
        [_serviceAction setTitle:[self.serviceModel.status integerValue] == 1 ? @"取消服务申请" : @"去评价" forState:UIControlStateNormal];
        [_serviceAction setTitleColor:[UIColor hex:@"B2B1C0"] forState:UIControlStateNormal];
        _serviceAction.layer.backgroundColor = [UIColor clearColor].CGColor;
        _serviceAction.layer.cornerRadius = 2.;
        _serviceAction.layer.masksToBounds = YES;
        _serviceAction.layer.borderColor = [UIColor hex:@"B2B1C0"].CGColor;
        _serviceAction.layer.borderWidth = 1.;
        [_serviceAction addTarget:self action:@selector(cancleOrJudge) forControlEvents:UIControlEventTouchUpInside];
        CGSize actionSize = [_serviceAction.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _serviceAction.titleLabel.font}];
        _serviceAction.frame = CGRectMake(_backView.width - actionSize.width - 20 - 15., offsetY + 10., actionSize.width + 20., 33.);
        offsetY += 10. + 33.;
    }else
    {
        _serviceAction.hidden = YES;
    }
    //评价
    if ([self.serviceModel.status integerValue] == 4) {
        _evaView.hidden = NO;
        CGFloat evaHeight = [VOEvaluateView getHeight:self.serviceModel];
        _evaView.frame = CGRectMake(15., offsetY + 10., _backView.width - 15.*2, evaHeight);
        _evaView.serviceModel = self.serviceModel;
        offsetY += 10. + evaHeight;
        [_evaView setNeedsLayout];
        [_evaView layoutIfNeeded];
    }else
    {
        _evaView.hidden = YES;
    }
    _backView.height = offsetY + 10.;
}

#pragma mark - publick method
- (void)setLabelWithStander:(UILabel *)label title:(NSString *)title info:(NSString *)info
{
    NSString *resultString = [NSString stringWithFormat:@"%@%@",title,info];
    NSRange firstRange = [resultString rangeOfString:title.length ? title : @""];
    NSRange secRange = [resultString rangeOfString:info.length ? info : @""];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
    //字体
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.] range:firstRange];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.] range:secRange];
    
    //字体颜色颜色
    BOOL isCancle = self.serviceModel.status.integerValue == 5;
    [attrStr addAttribute:NSForegroundColorAttributeName value: isCancle ? [UIColor hex:@"B1B2C0"] : [UIColor hex:@"373745"] range:firstRange];
    [attrStr addAttribute:NSForegroundColorAttributeName value: isCancle ? [UIColor hex:@"B1B2C0"] : [UIColor hex:@"858497"] range:secRange];
    label.attributedText = attrStr;
}

- (void)setSempleLabel:(UILabel *)label
{
    label.font = [UIFont systemFontOfSize:14.];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
}

#pragma mark - 取消服务申请 | 评价
- (void)cancleOrJudge
{
    if ([self.serviceModel.status integerValue] == 1)   ///取消申请
    {
        if (self.cancleBlock) {
            self.cancleBlock();
        }
    }else if ([self.serviceModel.status integerValue] == 3)     //评价
    {
        if (self.evaluateBlock) {
            self.evaluateBlock();
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
