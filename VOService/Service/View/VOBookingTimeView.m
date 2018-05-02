//
//  VOBookingTimeView.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/30.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOBookingTimeView.h"
#import "VODiagonalView.h"

#import "VOBookingToastView.h"
#import "VOBookingScrollView.h"

@interface VOBookingTimeView()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    VOBookingScrollView *_bookingScrollView;
    VODiagonalView *_diagonalView;
    
    UIView *lineView;
}

@property (nonatomic,strong) VOBookingToastView *toastView;
@end

@implementation VOBookingTimeView
-(instancetype)init
{
    if (self = [super init]) {
        [self _initSubViews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.cancelsTouchesInView = YES;
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}
#pragma mark - getter method
-(VOBookingToastView *)toastView
{
    if (!_toastView) {
        _toastView = [[VOBookingToastView alloc] init];
        _toastView.frame = CGRectMake(0, 24., (SCREEN_WIDTH/11), 56);
    }
    return _toastView;
}
#pragma mark - _initSubViews
- (void)_initSubViews
{    
    _bookingScrollView = [[VOBookingScrollView alloc] init];
    _bookingScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80.);
    _bookingScrollView.bounces = NO;
    _bookingScrollView.showsVerticalScrollIndicator = NO;
    _bookingScrollView.showsHorizontalScrollIndicator = NO;
    _bookingScrollView.delaysContentTouches = NO;
    _bookingScrollView.canCancelContentTouches = YES;
    _bookingScrollView.contentSize = CGSizeMake((SCREEN_WIDTH/11)*2*24, 80.);
    _bookingScrollView.delegate = self;
    _bookingScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bookingScrollView];
    
    
    //分割线
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _bookingScrollView.bottom - 1, _bookingScrollView.contentSize.width, 1)];
    lineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
    [_bookingScrollView addSubview:lineView];

    //时间段
    for (NSInteger i = 0; i < 24; i ++) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(i*(SCREEN_WIDTH/11)*2, 0, (SCREEN_WIDTH/11)*2, 24.)];
        topView.backgroundColor = [UIColor hex:@"E1E2EB" alpha:.5];
        [_bookingScrollView addSubview:topView];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:10.];
        titleLabel.frame = CGRectMake(5., 5., topView.width - 5*2, 14.);
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = [NSString stringWithFormat:@"%ld:00",(long)i];
        [topView addSubview:titleLabel];
        
        UIView *lineView = [UIView new];
        lineView.frame =  CGRectMake(0, 0, 1, topView.height);
        lineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
        [topView addSubview:lineView];
    }
    
    for (NSInteger i = 0; i < 24*2; i ++)
    {
        UIView *lineView = [UIView new];
        lineView.frame =  CGRectMake(i*(SCREEN_WIDTH/11), 24., 1, 55.);
        lineView.backgroundColor = [UIColor hex:@"B2B1C0" alpha:.5];
        [_bookingScrollView addSubview:lineView];
    }
    //不可选视图
    _diagonalView = [VODiagonalView new];
    _diagonalView.backgroundColor = [UIColor hex:@"F0F1F7"];
    _diagonalView.userInteractionEnabled = NO;
    [_bookingScrollView addSubview:_diagonalView];
    
    //toast
    __weak typeof(self) weakSelf = self;
    self.toastView.movingBlock = ^(CGFloat offsetX) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.model.viewModel.frame.origin.x < 0) {
            return ;
        }
        if ((strongSelf.model.viewModel.frame.origin.x + strongSelf.model.viewModel.frame.size.width) > (SCREEN_WIDTH/11)*48) {
            strongSelf.model.bottomModel.nextEnable = NO;
            return ;
        }
        strongSelf.model.bottomModel.nextEnable = YES;
        strongSelf.toastView.center = CGPointMake(strongSelf.toastView.center.x + offsetX, strongSelf.toastView.center.y);
        strongSelf.model.viewModel.frame = strongSelf.toastView.frame;
        if (strongSelf.toastView.left  < _diagonalView.right || [strongSelf isContainerUnselectRegion]) {
            strongSelf.model.bottomModel.nextTitle = @"时段不可用";
            strongSelf.model.bottomModel.rightEnable = NO;
            strongSelf.model.viewModel.isUnavailable = YES;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"FF5A60" alpha:.6];
        }else
        {
            strongSelf.model.bottomModel.rightEnable = YES;
            strongSelf.model.viewModel.isUnavailable = NO;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"5A99DD" alpha:.6];
            strongSelf.model.bottomModel.nextTitle = @"下一步";
        }
    };
    self.toastView.endBlock = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGFloat percent = strongSelf.toastView.left /(SCREEN_WIDTH/11);
        NSInteger index = (NSInteger)roundf(percent);
        NSInteger lastIndex =(NSInteger)roundf(strongSelf.toastView.right/(SCREEN_WIDTH/11));
        if (lastIndex < 48) {
            strongSelf.model.bottomModel.nextEnable = YES;
        }else
        {
            strongSelf.model.bottomModel.nextEnable = NO;
        }
        strongSelf.toastView.frame = CGRectMake(index * (SCREEN_WIDTH/11), strongSelf.toastView.top, strongSelf.toastView.width, strongSelf.toastView.height);
        strongSelf.model.viewModel.frame = strongSelf.toastView.frame;
        strongSelf.model.bottomModel.title = [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.toastView.left/(SCREEN_WIDTH/11))];
        if (strongSelf.toastView.left  < _diagonalView.right || [strongSelf isContainerUnselectRegion]) {
            strongSelf.model.bottomModel.nextTitle = @"时段不可用";
            strongSelf.model.bottomModel.rightEnable = NO;
            strongSelf.model.viewModel.isUnavailable = YES;            
        }else
        {
            strongSelf.model.bottomModel.nextTitle = @"下一步";
            strongSelf.model.bottomModel.rightEnable = YES;
            strongSelf.model.viewModel.isUnavailable = NO;
        }
        if (strongSelf.refreshBlock)
        {
            strongSelf.refreshBlock();
        }
    };
    self.toastView.widthBlock = ^(CGFloat offsetX) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.toastView.width + offsetX > (SCREEN_WIDTH/11)) {
                strongSelf.toastView.width += offsetX;
        }else
        {
            strongSelf.toastView.width = (SCREEN_WIDTH/11);
        }
        if (strongSelf.toastView.left  < _diagonalView.right || [strongSelf isContainerUnselectRegion]) {
            strongSelf.model.bottomModel.nextTitle = @"时段不可用";
            strongSelf.model.bottomModel.rightEnable = NO;
            strongSelf.model.viewModel.isUnavailable = YES;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"FF5A60" alpha:.6];
        }else
        {
            strongSelf.model.bottomModel.nextTitle = @"下一步";
            strongSelf.model.bottomModel.rightEnable = YES;
            strongSelf.model.viewModel.isUnavailable = NO;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"5A99DD" alpha:.6];
        }
    };
    self.toastView.endWidthBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGFloat percent = strongSelf.toastView.width /(SCREEN_WIDTH/11);
        NSInteger index = (NSInteger)roundf(percent);
        strongSelf.toastView.width = index*(SCREEN_WIDTH/11);
        strongSelf.model.viewModel.frame = strongSelf.toastView.frame;
        if (index < 2) {
            strongSelf.model.bottomModel.leftEnable = NO;
        }else
        {
            strongSelf.model.bottomModel.leftEnable = YES;
        }
        strongSelf.model.bottomModel.title = [strongSelf dateStringFromIndex:(NSInteger)roundf(strongSelf.toastView.left/(SCREEN_WIDTH/11))];
        if (strongSelf.toastView.left  < _diagonalView.right || [strongSelf isContainerUnselectRegion]) {
            strongSelf.model.bottomModel.nextTitle = @"时段不可用";
            strongSelf.model.bottomModel.rightEnable = NO;
            strongSelf.model.viewModel.isUnavailable = YES;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"FF5A60" alpha:.6];
        }else
        {
            strongSelf.model.bottomModel.nextTitle = @"下一步";
            strongSelf.model.bottomModel.rightEnable = YES;
            strongSelf.model.viewModel.isUnavailable = NO;
            strongSelf.toastView.backgroundColor = [UIColor hex:@"5A99DD" alpha:.6];
        }
        if (strongSelf.refreshBlock)
        {
            strongSelf.refreshBlock();
        }
    };
    [_bookingScrollView addSubview:self.toastView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //已预订时间
    CGFloat offsetX = [self caculateTime];
    NSMutableArray *resultArray = [NSMutableArray array];
    [self indexFromString:[NSMutableString stringWithString:self.model.bookingStatus] setArray:resultArray];
    for (NSNumber *index in resultArray)
    {
        NSInteger indexVale = [index integerValue];
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor hex:@"D1D2DC"];
        view.frame = CGRectMake((SCREEN_WIDTH/11) * indexVale, self.toastView.top, SCREEN_WIDTH/11, _bookingScrollView.height - 24.);
        view.userInteractionEnabled = NO;
        [_bookingScrollView addSubview:view];
    }
    
    
    //不可选视图
    _diagonalView.frame = CGRectMake(0., 24., offsetX*(SCREEN_WIDTH/11)*2, 55.);
    
    self.toastView.hidden = self.model.viewModel.isHidden;
    self.toastView.backgroundColor = self.model.viewModel.isUnavailable  ? [UIColor hex:@"FF5A60" alpha:.6] : [UIColor hex:@"5A99DD" alpha:.6];
    if (self.model.viewModel.frame.size.width) {
            self.toastView.frame = CGRectMake(self.model.viewModel.frame.origin.x, 24., self.model.viewModel.frame.size.width, self.model.viewModel.frame.size.height);
    }
    [_bookingScrollView bringSubviewToFront:self.toastView];
    
    if (self.model.viewModel.contentOffset.x < 0) {
        [_bookingScrollView setContentOffset:CGPointMake(_bookingScrollView.contentSize.width - offsetX*(SCREEN_WIDTH/11)*2< SCREEN_WIDTH ? _bookingScrollView.contentSize.width - SCREEN_WIDTH : offsetX*(SCREEN_WIDTH/11)*2, 0)];
    }else
    {
        [_bookingScrollView setContentOffset:self.model.viewModel.contentOffset];
    }
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

- (BOOL)isContainerUnselectRegion
{
    BOOL hasRegion = NO;
    NSMutableArray *resultArray = [NSMutableArray array];
    [self indexFromString:[NSMutableString stringWithString:self.model.bookingStatus] setArray:resultArray];
    NSInteger startIndex = roundf(self.toastView.left/(SCREEN_WIDTH/11));
    NSInteger endIndex = roundf(self.toastView.right/(SCREEN_WIDTH/11));
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _bookingScrollView) {
        self.model.viewModel.contentOffset = scrollView.contentOffset;
    }
}

#pragma mark - tap
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[VOBookingTimeView class]]) {        
        CGPoint point = [tap locationInView:_bookingScrollView];
        NSInteger index = point.x/(SCREEN_WIDTH/11);
        if ((index + self.toastView.width/(SCREEN_WIDTH/11)) > 48) {
            self.toastView.frame = CGRectMake((SCREEN_WIDTH/11) * index, self.toastView.top, (48 - index)*(SCREEN_WIDTH/11), 56);
        }else
        {
            self.toastView.frame = CGRectMake((SCREEN_WIDTH/11) * index, self.toastView.top, self.toastView.width, 56);
        }
        if (self.toastView.right/(SCREEN_WIDTH/11) >= 48) {
            self.model.bottomModel.nextEnable = NO;
        }else
        {
            self.model.bottomModel.nextEnable = YES;
        }
        self.model.bottomModel.title = [self dateStringFromIndex:index];
        self.model.viewModel.isHidden = NO;
        self.toastView.hidden = self.model.viewModel.isHidden;
        self.model.viewModel.frame = self.toastView.frame;
        if (self.toastView.left  < _diagonalView.right || [self isContainerUnselectRegion]) {
            self.model.bottomModel.nextTitle = @"时段不可用";
            self.model.bottomModel.rightEnable = NO;
            self.model.viewModel.isUnavailable = YES;
        }else
        {
            self.model.bottomModel.nextTitle = @"下一步";
            self.model.bottomModel.rightEnable = YES;
            self.model.viewModel.isUnavailable = NO;
        }
        if (self.refreshBlock)
        {
            self.refreshBlock();
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[VOBookingToastView class]]){
        return NO;
    }
    return YES;
}

#pragma mark - index to time
- (NSString *)dateStringFromIndex:(NSInteger )index
{
    NSString *resultString = nil;
    NSInteger widthIndex = self.toastView.width/(SCREEN_WIDTH/11);
    NSInteger startHour = index/2;
    NSInteger startmin = index%2*30;
    
    NSInteger endHour = (index + widthIndex)/2;
    NSInteger endmin = (index + widthIndex)%2*30;
    
    resultString = [NSString stringWithFormat:@"%ld:%.2ld   至   %ld:%.2ld",(long)startHour,startmin,endHour,endmin];
    return resultString;
}
@end
