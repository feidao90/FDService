//
//  VOBookingMeetingTableViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/1.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingMeetingTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface VOBookingMeetingTableViewCell()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *userInfoLabel;

@end

@implementation VOBookingMeetingTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self _initSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self _initSubViews];
}

#pragma mark - getter method
-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:17.];
        _titleLabel.textColor = [UIColor hex:@"373745"];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

-(UILabel *)userInfoLabel
{
    if (!_userInfoLabel) {
        _userInfoLabel = [[UILabel alloc] init];
        _userInfoLabel.textAlignment = NSTextAlignmentRight;
        _userInfoLabel.font = [UIFont systemFontOfSize:17.];
        _userInfoLabel.backgroundColor = [UIColor clearColor];
        _userInfoLabel.textColor = [UIColor hex:@"858497"];
        _userInfoLabel.numberOfLines = 0;
        _userInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _userInfoLabel;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    //title
    [self addSubview:self.titleLabel];
    
    //info
    [self addSubview:self.userInfoLabel];
}

#pragma mark - get height
+ (CGFloat)getCellHeight:(NSDictionary *)info
{
    NSString *text = [info safeObjectForKey:@"value"];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17.]};
    CGSize size = CGSizeZero;
    if ([[info objectForKey:@"limit"] boolValue]) {
        size = CGSizeMake(SCREEN_WIDTH - 100 - 35, 46.);
    }else
    {
        size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 100 - 35, 5000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    return size.height + 10.*2;
}
#pragma mark - layoutsubview
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellheight = [VOBookingMeetingTableViewCell getCellHeight:self.info];
    //title
    self.titleLabel.frame = CGRectMake(15., cellheight/2 - 24./2, 10, 24.);
    self.titleLabel.text = [self.info safeObjectForKey:@"title"];
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    self.titleLabel.width = titleSize.width;
    
    self.userInfoLabel.text = [self.info safeObjectForKey:@"value"];
    self.userInfoLabel.hidden = NO;
    NSDictionary *attribute = @{NSFontAttributeName: self.userInfoLabel.font};
    CGSize size = [self.userInfoLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 100 - 35, 5000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    self.userInfoLabel.numberOfLines = 0;
    self.userInfoLabel.frame = CGRectMake(self.titleLabel.right + 15., 10., SCREEN_WIDTH - self.titleLabel.right - 15. - 15., size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
