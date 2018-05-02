//
//  VOContactsViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOContactsViewController.h"
#import "VOPlaceholderTextView.h"

#import "UIResultMessageView.h"
#import "VOLoginManager.h"

@interface VOContactsViewController ()<UITextViewDelegate>
{
    VOPlaceholderTextView *_textView;
}
@end

@implementation VOContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"联系人";
    
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
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:_textView.text,@"value", [[VOLoginManager shared] getUserId], @"key", nil];
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:kServiceContactsNameKey];
    
    if (self.completeBlock) {
        self.completeBlock(_textView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    UIView *backView = [UIView new];
    backView.frame = CGRectMake(0, 20., SCREEN_WIDTH, 200.);
    [self addLineWithSuperView:backView isTop:YES];
    [self addLineWithSuperView:backView isTop:NO];
    [self.view addSubview:backView];
    
    _textView = [[VOPlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200.)];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.spellCheckingType = UITextSpellCheckingTypeNo;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = self.contactName.length ? @"" :  @"联系人";
    _textView.text = self.contactName;
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
    if ([textView.text isEqualToString:self.contactName])
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
