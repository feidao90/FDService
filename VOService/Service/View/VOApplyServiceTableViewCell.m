//
//  VOApplyServiceTableViewCell.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOApplyServiceTableViewCell.h"
#import "VOPlaceholderTextView.h"

#import "VOCircleProgressView.h"
#import "VOServiceCustomImage.h"

#import "VONetworking+Session.h"
#import "VOMineUploadTokenModel.h"

#import "VOLoginManager.h"

#define kLeftWidth 70.
@interface VOApplyServiceTableViewCell()
{
    UILabel *_titleLabel;
    UILabel *_infoLabel;
}
@end

@implementation VOApplyServiceTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _initSubViews];
    }
    return self;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _infoLabel = [UILabel new];
    [self addSubview:_infoLabel];
}

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(NSDictionary *)info
{
    NSString *titleString = [info safeObjectForKey:@"title"];
    CGSize titleSize = [titleString boundingRectWithSize:CGSizeMake(kLeftWidth, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.]} context:nil].size;
    
    NSString *infoString = [info safeObjectForKey:@"value"];
    CGSize infoSize = [infoString boundingRectWithSize: [[info safeObjectForKey:@"edit"] boolValue] ? CGSizeMake(SCREEN_WIDTH - 15.*2 - kLeftWidth - 20. - 36., 5000) : CGSizeMake(SCREEN_WIDTH - 15.*2 - kLeftWidth - 20., 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.]} context:nil].size;
    
    return titleSize.height > infoSize.height ? titleSize.height + 15.*2 : infoSize.height + 15.*2;
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //title
    _titleLabel.font = [UIFont systemFontOfSize:17.];
    _titleLabel.text = [self.info safeObjectForKey:@"title"];
    _titleLabel.frame = CGRectMake(15., 15., kLeftWidth, 24.);
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    CGSize titleSize = [_titleLabel.text boundingRectWithSize:CGSizeMake(_titleLabel.width, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _titleLabel.font} context:nil].size;
    _titleLabel.height = titleSize.height;
    
    //info
    _infoLabel.font = [UIFont systemFontOfSize:17.];
    _infoLabel.text = [self.info safeObjectForKey:@"value"];
    _infoLabel.frame = [[self.info safeObjectForKey:@"hasArrow"] boolValue] ? CGRectMake(_titleLabel.right + 20., 15., self.width - _titleLabel.right - 20. - 15. - 36., 24.) : CGRectMake(_titleLabel.right + 20., 15., self.width - _titleLabel.right - 20. - 15., 24.);
    _infoLabel.numberOfLines = 0;
    _infoLabel.textColor = [UIColor hex:@"858497"];
    _infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize infoSize = [_infoLabel.text boundingRectWithSize:CGSizeMake(_infoLabel.width, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _infoLabel.font} context:nil].size;
    _infoLabel.height = infoSize.height;
    if ([[self.info safeObjectForKey:@"type"] isEqualToString:kServiceApplyTypeInfo])
    {
        if (_infoLabel.font.lineHeight < _infoLabel.height) {
                _infoLabel.textAlignment = NSTextAlignmentLeft;
        }else
        {
            _infoLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }else if ([[self.info safeObjectForKey:@"type"] isEqualToString:kServiceApplyContactsInfo] || [[self.info safeObjectForKey:@"type"] isEqualToString:kServiceApplyPhoneInfo])
    {
        _infoLabel.textAlignment = NSTextAlignmentRight;
    }
}
@end

#define kImageViewsTag 0xDDDDDD
#define kProgressViewTag 0xCCCCCC
@interface VOApplyServiceUploadImageTableViewCell()
{
    UIButton *_addImage;
    UILabel *_placeHolderImage;
}

@end

@implementation VOApplyServiceUploadImageTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _initSubViews];
    }
    return self;
}

#pragma mark - gettet method
-(NSMutableArray *)uploadImages
{
    if (!_uploadImages) {
        _uploadImages = [NSMutableArray arrayWithCapacity:9];
        
        for (int i = 0; i <9; i ++)
        {
            [_uploadImages safeAddObject:@""];
        }
    }
    return _uploadImages;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    _addImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addImage setImage:[UIImage imageNamed:@"add_image"] forState:UIControlStateNormal];
    [_addImage addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addImage];
    
    _placeHolderImage = [UILabel new];
    [self addSubview:_placeHolderImage];
}

#pragma mark - get cell height
+ (CGFloat)getCellHeight:(NSDictionary *)info
{
    NSArray *imageSet = [info safeObjectForKey:@"images"];
    NSInteger rank = imageSet.count / 4;
    return  15.*2 + 72 + rank *(72 + 15.);
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSMutableArray *imageSet = [self.info safeObjectForKey:@"images"];
    CGFloat widthSpace = (SCREEN_WIDTH - 4*72)/5;
    for (VOServiceCustomImage *image in imageSet)
    {
        NSInteger index  = [imageSet indexOfObject:image];
        NSInteger row = index % 4;
        NSInteger rank = index / 4;
        UIButton *imageView = [UIButton buttonWithType:UIButtonTypeCustom];
        imageView.frame = CGRectMake(widthSpace + row * (72 + widthSpace), 15. + rank*(72. + 15.), 72., 72.);
        [imageView addTarget:self action:@selector(showBigImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageView setImage:image forState:UIControlStateNormal];
        imageView.tag = kImageViewsTag + index;
        [self addSubview:imageView];

        VOCircleProgressView *progressView = [VOCircleProgressView new];
        progressView.frame = imageView.bounds;
        progressView.progress = 0;
        progressView.hidden = image.isStartLoading ? YES : NO;
        progressView.tag = kProgressViewTag + index;
        progressView.isError = image.isError;
        progressView.userInteractionEnabled = NO;
        [imageView addSubview:progressView];
    }
    
    //add image
    _addImage.frame = CGRectMake(15. + imageSet.count % 4 * (72 + widthSpace), 15. + imageSet.count/4*(72. + 15.), 72., 72.);
    _addImage.hidden = imageSet.count == 9 ? YES : NO;
    
    //place holder
    _placeHolderImage.font = [UIFont systemFontOfSize:17.];
    _placeHolderImage.textColor = [UIColor hex:@"B2B1C0"];
    _placeHolderImage.text = @"拍照/上传照片(最多9张)";
    _placeHolderImage.hidden = imageSet.count ? YES : NO;
    _placeHolderImage.frame = CGRectMake(_addImage.right + 10., self.height/2 - 22./2, 184., 22.);
}
-(void)setInfo:(NSDictionary *)info
{
    _info = info;
    [self uploadImage];
}
#pragma mark - addImage
- (void)addImage
{    
    if (self.addImageBlock) {
        self.addImageBlock();
    }
}

#pragma mark - 查看大图
- (void)showBigImage:(UIButton *)button
{
    NSInteger index = button.tag - kImageViewsTag;
    NSMutableArray *imageSet = [self.info safeObjectForKey:@"images"];
    VOServiceCustomImage *image = [imageSet safeObjectAtIndex:index];
    if (image.isStartLoading || image.isError)
    {
        if (self.selectedImageBlock) {
            self.selectedImageBlock(index);
        }
    }
}
#pragma mark - 上传图片
- (void)uploadImage
{
    NSMutableArray *imageSet = [self.info safeObjectForKey:@"images"];
    for (VOServiceCustomImage *image in imageSet)
    {
        if (!image.isStartLoading)
        {
            NSInteger index = [imageSet indexOfObject:image];
            [self uploadImageWithIndex:index];
        }
    }
}

#pragma mark - 上传图片
- (void)uploadImageWithIndex:(NSInteger) index
{
    NSMutableArray *imageSet = [self.info safeObjectForKey:@"images"];
    VOServiceCustomImage *image = [imageSet safeObjectAtIndex:index];
    NSData *data = UIImageJPEGRepresentation(image, .9);
    
    NSString *fileName = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *day = [formatter stringFromDate:[NSDate date]];
    fileName = [NSString stringWithFormat:@"%@.%@",day,@"jpg"];
    
    VOLoginResponseModel *model = [[VOLoginManager shared] getLoginInfo];
    NSDictionary *params = @{
                             @"projectId" : model.user.currentProject.projectId,
                             @"size" : [NSString stringWithFormat:@"%ld",(unsigned long)[data length]],
                             @"sourceName" : fileName,
                             @"uploadType" : @"10",
                             };
    [VONetworking postWithUrl:@"/v1.0.0/api/oss/token" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response)
     {
         VOMineUploadTokenModel *tokenModel = [[VOMineUploadTokenModel alloc] initWithJSONDictionary:response];
         [self uploadWithImage:image Model:tokenModel fileData:data Index:index];
     } failBlock:^(NSError *error)
    {
        image.isStartLoading = NO;
        image.isError = YES;
        image.error = error;
        [self isFinishedAllUpLoad];
     }];
}

- (void)uploadWithImage:(VOServiceCustomImage *)image Model:(VOMineUploadTokenModel *)tokenModel fileData:(NSData *)data Index:(NSInteger)index
{
    [VONetworking uploadFileWithUrl:tokenModel.host
                     OSSAccessKeyId:tokenModel.accessId
                           callback:tokenModel.callback
                             expire:tokenModel.expire
                                key:tokenModel.key
                             policy:tokenModel.policy
                          signature:tokenModel.signature
                               file:data
                           progress:^(NSProgress *uploadProgress) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   UIButton *button = [self viewWithTag:index + kImageViewsTag];
                                   VOCircleProgressView *progressView = [button viewWithTag:index + kProgressViewTag];
                                   progressView.progress = uploadProgress.fractionCompleted;
                               });
                           }
                       successBlock:^(id response)
     {
         image.isStartLoading = YES;
         image.isError = NO;
         [self.uploadImages replaceObjectAtIndex:index withObject:[response safeObjectForKey:@"attachmentId"]];
         [self isFinishedAllUpLoad];
     } failBlock:^(NSError *error) {
         image.isStartLoading = NO;
         image.isError = YES;
         image.error = error;
         [self isFinishedAllUpLoad];
     }];
}

#pragma mark -验证图片上传完成否
- (void)isFinishedAllUpLoad
{
    BOOL isFinished = NO;
    NSMutableArray *imageSet = [self.info safeObjectForKey:@"images"];
    for (VOServiceCustomImage *image in imageSet)
    {
        if (image.isStartLoading || image.isError)
        {
            isFinished = YES;
        }else
        {
            isFinished = NO;
            break;
        }
    }
    if (isFinished)
    {
            dispatch_after(.65, dispatch_get_main_queue(), ^{
                if (self.imagesBlock) {
                    self.imagesBlock(self.uploadImages);
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                }
            });
    }
}
@end


@interface VOApplyServiceDescriptionTableViewCell()<UITextViewDelegate>
{
    VOPlaceholderTextView *_textInput;
}
@end

@implementation VOApplyServiceDescriptionTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _initSubViews];
    }
    return self;
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    _textInput = [VOPlaceholderTextView new];
    _textInput.autocorrectionType = UITextAutocorrectionTypeNo;
    _textInput.spellCheckingType = UITextSpellCheckingTypeNo;
    _textInput.backgroundColor = [UIColor whiteColor];
    _textInput.placeholder = @"请输入您的建议或投诉（1000字以内）";
    _textInput.font = [UIFont systemFontOfSize:17.];
    _textInput.delegate = self;
    [self addSubview:_textInput];
}

+ (CGFloat)getCellHeight:(NSDictionary *)info
{
    return 200.;
}
#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    _textInput.frame = CGRectMake(0, 0, self.width, 200);
    _textInput.text = [self.info safeObjectForKey:@"value"];
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self.info setObject:textView.text forKey:@"value"];
    if (self.textBlock) {
        self.textBlock(textView.text);
    }
}
@end
