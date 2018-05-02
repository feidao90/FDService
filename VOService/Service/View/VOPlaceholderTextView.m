//
//  VOPlaceholderTextView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/17.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOPlaceholderTextView.h"

@interface VOPlaceholderTextView()

@property (strong, nonatomic) UILabel *placeholderLabel;
@end

@implementation VOPlaceholderTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    [self _initSubViews];
    return self;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.font = [UIFont systemFontOfSize:17.];
    self.placeholderLabel.textColor = [UIColor hex:@"B2B1C0"];
    [self addSubview: self.placeholderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - UITextViewTextDidChangeNotification
- (void)textDidChange
{
    self.placeholderLabel.hidden = self.hasText;
}

#pragma mark - setter method
- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self textDidChange];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}
#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.placeholderLabel.frame;
    frame.origin.y = self.textContainerInset.top;
    frame.origin.x = self.textContainerInset.left+6.0f;
    frame.size.width = self.frame.size.width - self.textContainerInset.left*2.0;
    
    CGSize maxSize = CGSizeMake(frame.size.width, MAXFLOAT);
    frame.size.height = [self.placeholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeholderLabel.font} context:nil].size.height;
    self.placeholderLabel.frame = frame;
}

#pragma mark - dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
