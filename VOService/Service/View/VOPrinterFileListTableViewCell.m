//
//  VOPrinterFileListTableViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/2/5.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOPrinterFileListTableViewCell.h"

@interface VOPrinterFileListTableViewCell()
{
    UIImageView *_selectButton;
    UILabel *_titleLabel;
    
    UILabel *_infoLabel;
}
@end

@implementation VOPrinterFileListTableViewCell
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

#pragma mark - _initSubViews
- (void)_initSubViews
{
    _selectButton = [UIImageView new];
    [self addSubview:_selectButton];
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _infoLabel = [UILabel new];
    [self addSubview:_infoLabel];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _selectButton.frame = CGRectMake(15., self.height/2 - 27./2, 27., 27.);
    _selectButton.image = [UIImage imageNamed:@"choose"];
    _selectButton.highlightedImage = [UIImage imageNamed:@"choose-on"];
    _selectButton.highlighted = self.model.isSelected;
    
    //title
    _titleLabel.frame = CGRectMake(_selectButton.right + 15., 16., SCREEN_WIDTH - _selectButton.right - 15.*2, 24.);
    _titleLabel.font = [UIFont systemFontOfSize:17.];
    _titleLabel.text = self.model.docName;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    NSString *titleString = [NSString stringWithFormat:@"%@  %@%@  x%@", self.model.page_type, [self.model.double_print integerValue] == 1 ? @"单面" : @"双面", [self.model.color integerValue] == 1 ? @"黑白" : @"彩色", self.model.copies];
    _infoLabel.font = [UIFont systemFontOfSize:14.];
    _infoLabel.textColor = [UIColor hex:@"858497"];
    _infoLabel.text = titleString;
    _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _infoLabel.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 2, _titleLabel.width, 20.);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
