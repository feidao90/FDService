//
//  VOServiceBookingTableViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServiceBookingTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "VOBookingTimeView.h"
#import "VOBookingChangeTimeView.h"

#define kConstentTag 0xDDDDDD
@interface VOServiceBookingTableViewCell()
{
    UIImageView *_headImageView;
    UILabel *_buldingInfo;
    
    UILabel *_supportingLabel;
    UILabel *_priceLabel;
    
    VOBookingTimeView *_bookingView;
    UIView *_bottomView;
    
    VOBookingChangeTimeView *_changeView;
}

@property (nonatomic,strong) UIView *titleBackView;
@end

@implementation VOServiceBookingTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _initSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self _initSubViews];
}

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(VOBookingMeetingRoomListModel *)model
{
    CGFloat offsetY = 0.;
    offsetY += 200.;
    offsetY += 80.;
    offsetY += model.viewModel.isHidden ? 0 : 92.;
    offsetY += 20.;
    return offsetY;
}

-(UIView *)titleBackView
{
    if (!_titleBackView) {
        _titleBackView = [UIView new];
        
        UIColor *colorOne = [UIColor hex:@"000000" alpha:.8];
        UIColor *colorTwo = [UIColor hex:@"1B1919" alpha:0];
        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
        CAGradientLayer *titleGradient = [CAGradientLayer layer];
        //设置开始和结束位置(设置渐变的方向)
        titleGradient.startPoint = CGPointMake(0, 1);
        titleGradient.endPoint = CGPointMake(0, 0);
        titleGradient.colors = colors;
        [_titleBackView.layer addSublayer:titleGradient];
    }
    return _titleBackView;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    //头图
    _headImageView = [UIImageView new];
    _headImageView.tag = kConstentTag;
    [self addSubview:_headImageView];
    
    //back view
    [self addSubview:self.titleBackView];
    
    //会议室信息
    _buldingInfo = [UILabel new];
    [_titleBackView addSubview:_buldingInfo];
    
    //配置
    _supportingLabel = [UILabel new];
    [_titleBackView addSubview:_supportingLabel];
    
    //价格
    _priceLabel = [UILabel new];
    [_titleBackView addSubview:_priceLabel];
    
    //时间轴
    _bookingView = [[VOBookingTimeView alloc] init];
    [self addSubview:_bookingView];
    
    //changeView
    _changeView = [[VOBookingChangeTimeView alloc] init];
    [self addSubview:_changeView];
    
    //bottom view
    _bottomView = [UIView new];
    [self addSubview:_bottomView];
}

#pragma mark -
-(void)layoutSubviews
{
    [super layoutSubviews];

    //头图
    _headImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200.);    
    VOBookingMeetingRoomPictureDetailModel *picModel = [self.model.pictures safeObjectAtIndex:0];
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?x-oss-process=image/resize,limit_1,m_fill,w_%.0f,h_200/auto-orient,1",picModel.url,SCREEN_WIDTH]]];
    
    
    //会议室信息
    _buldingInfo.font = [UIFont boldSystemFontOfSize:15.];
    _buldingInfo.text = [NSString stringWithFormat:@"%@ 【%@·%@层】",self.model.meetingRoomName,self.model.buildingName,self.model.floor];
    _buldingInfo.numberOfLines = 0;
    CGSize buildingSize = [_buldingInfo textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH - 15.*2, 5000) limitedToNumberOfLines:2].size;
    _buldingInfo.frame = CGRectMake(15., _titleBackView.height - 17 - 4 - buildingSize.height - 4, SCREEN_WIDTH - 15.*2, buildingSize.height);
    _buldingInfo.textColor = [UIColor whiteColor];
    //配置
    _supportingLabel.font = [UIFont systemFontOfSize:12.];
    _supportingLabel.textColor = [UIColor whiteColor];
    _supportingLabel.text  = self.model.supporting;
    _supportingLabel.frame = CGRectMake(15., _titleBackView.height - 17 - 4, SCREEN_WIDTH - 170  - 15., 17.);
    
    //back view frame
    _titleBackView.frame = CGRectMake(0, _headImageView.height - _buldingInfo.height - _supportingLabel.height  - 8 - 20, SCREEN_WIDTH, _buldingInfo.height + _supportingLabel.height + 8 + 20);
    _buldingInfo.frame = CGRectMake(15., _titleBackView.height - 17 - 4 - buildingSize.height - 4, SCREEN_WIDTH - 15.*2, buildingSize.height);
    _supportingLabel.frame = CGRectMake(15., _titleBackView.height - 17 - 4, SCREEN_WIDTH - 170  - 15., 17.);
    
    for (CALayer *layer in _titleBackView.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = _titleBackView.bounds;
            [_titleBackView.layer insertSublayer:layer atIndex:0];
            break;
        }
    }

    //价格
    NSString *priceString = [NSString stringWithFormat:@"￥%.2f",[self.model.price floatValue]/100];
    NSString *percentTime = @"/30分钟";
    NSString *resultString = [NSString stringWithFormat:@"%@%@",priceString,percentTime];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
    //字体
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.] range:[resultString rangeOfString:priceString]];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.] range:[resultString rangeOfString:percentTime]];
    //颜色
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"FF5A60"] range:[resultString rangeOfString:priceString]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[resultString rangeOfString:percentTime]];
    _priceLabel.attributedText = attr;
    
    _priceLabel.frame = CGRectMake(SCREEN_WIDTH - 170., _titleBackView.height - 28. - 4.,  170. - 15., 28.);
    _priceLabel.textAlignment = NSTextAlignmentRight;
    //时间轴
    _bookingView.frame = CGRectMake(0, _headImageView.bottom, SCREEN_WIDTH, 80.);    
    _bookingView.model = self.model;
    _bookingView.unvalibleDate = self.unvalibleDate;
    __weak typeof(self) weakSelf = self;
    _bookingView.refreshBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.reloadBlock) {
            strongSelf.reloadBlock();
        }
    };
    
    //changeView
    _changeView.frame = CGRectMake(0, _bookingView.bottom, SCREEN_WIDTH, 92.);
    _changeView.hidden =  self.model.viewModel.isHidden;
    _changeView.model = self.model;
    _changeView.reduceBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.model.viewModel.frame.size.width/(SCREEN_WIDTH/11) > 1)
        {
            strongSelf.model.viewModel.frame = CGRectMake(strongSelf.model.viewModel.frame.origin.x, strongSelf.model.viewModel.frame.origin.y, strongSelf.model.viewModel.frame.size.width - SCREEN_WIDTH/11 < SCREEN_WIDTH/11 ? SCREEN_WIDTH/11 : strongSelf.model.viewModel.frame.size.width - SCREEN_WIDTH/11, strongSelf.model.viewModel.frame.size.height);
            strongSelf.model.bottomModel.title =  [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11))];
            if (roundf(strongSelf.model.viewModel.frame.size.width/(SCREEN_WIDTH/11)) < 2)
            {
                strongSelf.model.bottomModel.leftEnable = NO;
            }
            NSInteger length = (strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11);
            if (length < 48) {
                strongSelf.model.bottomModel.nextEnable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextEnable = NO;
            }
            if ( [strongSelf isContainerUnselectRegion]) {
                strongSelf.model.bottomModel.nextTitle = @"时段不可用";
                strongSelf.model.bottomModel.rightEnable = NO;
                strongSelf.model.viewModel.isUnavailable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextTitle = @"下一步";
                strongSelf.model.bottomModel.rightEnable = YES;
                strongSelf.model.viewModel.isUnavailable = NO;
            }
            if (strongSelf.reloadBlock) {
                strongSelf.reloadBlock();
            }
        }
    };
    _changeView.plusBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger length = (strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11);
        if (length < 48) {
            strongSelf.model.viewModel.frame = CGRectMake(strongSelf.model.viewModel.frame.origin.x, strongSelf.model.viewModel.frame.origin.y, strongSelf.model.viewModel.frame.size.width + SCREEN_WIDTH/11, strongSelf.model.viewModel.frame.size.height);
            strongSelf.model.bottomModel.leftEnable = YES;
            strongSelf.model.bottomModel.title =  [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11))];
            
            if ((strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11) < 48) {
                strongSelf.model.bottomModel.nextEnable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextEnable = NO;
            }
            if ( [strongSelf isContainerUnselectRegion]) {
                strongSelf.model.bottomModel.nextTitle = @"时段不可用";
                strongSelf.model.bottomModel.rightEnable = NO;
                strongSelf.model.viewModel.isUnavailable = YES;
            }else
            {
                strongSelf.model.bottomModel.nextTitle = @"下一步";
                strongSelf.model.bottomModel.rightEnable = YES;
                strongSelf.model.viewModel.isUnavailable = NO;
            }
            
            if (strongSelf.reloadBlock) {
                strongSelf.reloadBlock();
            }
        }
    };
    _changeView.cancleBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.model.viewModel.isHidden = YES;
        strongSelf.model.bottomModel.nextEnable = NO;
        strongSelf.model.bottomModel.title = @"请选择时间段";
        strongSelf.model.bottomModel.leftEnable = NO;
        strongSelf.model.viewModel.frame = CGRectMake(strongSelf.model.viewModel.frame.origin.x, strongSelf.model.viewModel.frame.origin.y, SCREEN_WIDTH/11, strongSelf.model.viewModel.frame.size.height);
        if (strongSelf.reloadBlock) {
            strongSelf.reloadBlock();
        }
    };
    _changeView.nextBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.jumpBlock) {
            strongSelf.jumpBlock();
        }
    };
    
    //bottom view
    _bottomView.frame = CGRectMake(0,  self.model.viewModel.isHidden ? _bookingView.bottom : _changeView.bottom, self.width, 20.);
    _bottomView.backgroundColor = [UIColor hex:@"F2F3F8"];
}

#pragma mark - index to time
- (NSString *)dateStringFromIndex:(NSInteger )index
{
    NSString *resultString = nil;
    NSInteger widthIndex = self.model.viewModel.frame.size.width/(SCREEN_WIDTH/11);
    NSInteger startHour = index/2;
    NSInteger startmin = index%2*30;
    
    NSInteger endHour = (index + widthIndex)/2;
    NSInteger endmin = (index + widthIndex)%2*30;
    
    resultString = [NSString stringWithFormat:@"%ld:%.2ld   至   %ld:%.2ld",(long)startHour,startmin,endHour,endmin];
    return resultString;
}

#pragma mark - 计算越区
- (BOOL)isContainerUnselectRegion
{
    BOOL hasRegion = NO;
    NSMutableArray *resultArray = [NSMutableArray array];
    [self indexFromString:[NSMutableString stringWithString:self.model.bookingStatus] setArray:resultArray];
    NSInteger startIndex = roundf(self.model.viewModel.frame.origin.x/(SCREEN_WIDTH/11));
    NSInteger endIndex = roundf((self.model.viewModel.frame.origin.x + self.model.viewModel.frame.size.width)/(SCREEN_WIDTH/11));
    if (startIndex < roundf([self caculateTime]*2)) {
        hasRegion = YES;
        return hasRegion;
    }
    for (NSNumber *numIndex in resultArray)
    {
        if ([numIndex integerValue] >= startIndex && endIndex > [numIndex integerValue]) {
            hasRegion = YES;
            break;
        }else if ([numIndex integerValue] + 1> startIndex && endIndex > [numIndex integerValue] + 1 )
        {
            hasRegion = YES;
            break;
        }
    }
    return hasRegion;
}

#pragma mark - 时间计算
- (CGFloat)caculateTime
{
    CGFloat index = 0;
    if (self.unvalibleDate) {
        NSDate *nowDate = self.unvalibleDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH"];
        
        NSDateFormatter *secFormat = [[NSDateFormatter alloc] init];
        [secFormat setDateFormat:@"mm"];
        NSString * hourStr=[dateFormat stringFromDate:nowDate];
        NSString *minStr  = [secFormat stringFromDate:nowDate];
        if ([minStr integerValue] > 30) {
            index = [hourStr integerValue] + 1;
        }else
        {
            index = [hourStr integerValue] + .5;
        }
    }
    return  index;
}

#pragma mark -  递归获取 index
- (void)indexFromString:(NSMutableString *)temp setArray:(NSMutableArray *)indexSet
{
    if ([temp rangeOfString:@"1"].location != NSNotFound && [temp rangeOfString:@"1"].length != 0)
    {
        [indexSet safeAddObject:[NSNumber numberWithInteger:[temp rangeOfString:@"1"].location]];
        [temp replaceCharactersInRange:[temp rangeOfString:@"1"] withString:@"0"];
        [self indexFromString:temp setArray:indexSet];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
