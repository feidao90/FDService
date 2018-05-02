//
//  VOServicePhoneViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServicePhoneViewController.h"
#import "UIResultMessageView.h"

#import "VOPlaceholderTextView.h"
#import "VOLoginManager.h"

@interface VOServicePhoneViewController ()<UITextViewDelegate>
{
    VOPlaceholderTextView *_textView;
}
@end

@implementation VOServicePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"手机号码";
    
    //right item
    [self createRightItemWithTitle:@"保存" target:self action:@selector(rightItemAction)];
    [self disEnableRightItem:YES];
    
    //_initSubViews
    [self _initSubViews];
}

#pragma mark - rightItemAction
- (void)rightItemAction
{
    //缓存
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_textView.text, @"value", [[VOLoginManager shared] getUserId], @"key", nil];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kServiceContactsPhoneKey];
    if (self.completeBlock) {
        self.completeBlock(_textView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20., SCREEN_WIDTH, 36.)];
    [self addLineWithSuperView:backView isTop:YES];
    [self addLineWithSuperView:backView isTop:NO];
    [self.view addSubview:backView];
    
    _textView = [[VOPlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36.)];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.spellCheckingType = UITextSpellCheckingTypeNo;
    _textView.keyboardType = UIKeyboardTypeNumberPad;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = self.phoneNum.length ? @"" :  @"手机号码";
    _textView.text = self.phoneNum;
    _textView.font = [UIFont systemFontOfSize:17.];
    _textView.delegate = self;
    [_textView becomeFirstResponder];
    [backView addSubview:_textView];
}

//添加边框
- (void)addLineWithSuperView:(UIView *)superView isTop:(BOOL)isTop
{
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(superView.left, isTop ? superView.top : superView.bottom, superView.width, 1.);
    borderLayer.position= CGPointMake(superView.left + superView.width/2, isTop ? 0 : (superView.height + 1));
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(superView.left, isTop ? superView.top : superView.bottom)];
    [path addLineToPoint:CGPointMake(superView.width, isTop ? superView.top : superView.bottom)];
    
    borderLayer.path = path.CGPath;
    borderLayer.lineWidth=1.;
    borderLayer.lineDashPattern= nil;
    borderLayer.fillColor= [UIColor clearColor].CGColor;
    borderLayer.strokeColor= [UIColor hex:@"000000" alpha:8/255.].CGColor;
    [superView.layer addSublayer:borderLayer];
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location >= 20) {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"文字超过字数限制"];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:self.phoneNum])
    {
        [self disEnableRightItem:YES];
    }else
    {
        [self disEnableRightItem:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
