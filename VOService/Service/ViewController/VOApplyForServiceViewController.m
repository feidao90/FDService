//
//  VOApplyForServiceViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOApplyForServiceViewController.h"
#import "VOApplyServiceTableViewCell.h"

#import "VOContactsViewController.h"
#import "VOServicePhoneViewController.h"

#import "TZImagePickerController.h"
#import "VONetworking+Session.h"

#import "VOMineUploadTokenModel.h"
#import "UIResultMessageView.h"

#import "VOServiceCustomImage.h"
#import "UIResultMessageView.h"

#import "VOLoginManager.h"
#import "VOMineAllServiceListViewController.h"

@interface VOApplyForServiceViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UITableView *_listView;
    NSMutableArray *_listData;
    
    UIImagePickerController *_imagePickerController;
    NSMutableArray *_uploadImages;
    
    NSString *_contentString;
}
@end

@implementation VOApplyForServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"申请物业服务";
    //right item
    [self createRightItemWithTitle:@"提交" target:self action:@selector(rightItemAction)];
    [self disEnableRightItem:YES];
    
    //_initSubViews
    [self _initSubViews];
    
    //_initdata
    [self _initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //监听当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - rightItemAction
- (void)rightItemAction
{
    NSString *contract = [[[_listData safeObjectAtIndex:1] safeObjectAtIndex:0] safeObjectForKey:@"value"];
    NSString *phone = [[[_listData safeObjectAtIndex:1] safeObjectAtIndex:1] safeObjectForKey:@"value"];
    for (NSInteger i = _uploadImages.count - 1; i >= 0; i --) {
        NSNumber *imageId = [_uploadImages safeObjectAtIndex:i];
        if (![imageId integerValue]) {
            [_uploadImages removeObject:imageId];
        }
    }
    
    VOLoginResponseModel *model =  [[VOLoginManager shared] getLoginInfo];
    NSDictionary *params = @{
                             @"contract" : contract,
                             @"mobilePhone" : phone,
                             @"description" : _contentString,
                             @"images" : [_uploadImages componentsJoinedByString:@","],
                             @"projectUpkeepTypeId" : self.model.projectUpkeepTypeId
                             };
    NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/project/%@/upkeep/record",model.user.currentProject.projectId];
    [VONetworking postWithUrl:url refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"申请物业服务成功"];

        //返回上层页面
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            VOMineAllServiceListViewController *serviceVC = [[VOMineAllServiceListViewController  alloc] init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            
            [[VOLoginManager shared] refreshLoginfo:nil];
        });
    } failBlock:^(NSError *error) {
        if (error.code != -9999)    // -9999为无网络码
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

#pragma mark - 键盘呼出&收起
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    CGFloat offsetY = 64.;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    _listView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY - height);
    _listView.contentOffset = CGPointMake(0, height);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘的高度
    CGFloat offsetY = 64.;
    _listView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY);
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat offsetY = 64.;
    //list View
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY) style:UITableViewStyleGrouped];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.bounces = NO;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.sectionHeaderHeight = 20;
    _listView.sectionFooterHeight = 0;
    [self.view addSubview:_listView];
    
    //添加手势
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [_listView addGestureRecognizer:tableViewGesture];
    
    //footer view
    UIView *footerView = [UIView new];
    footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
    footerView.backgroundColor = [UIColor clearColor];
    _listView.tableFooterView = footerView;
}

- (void)commentTableViewTouchInSide{
    [self.view endEditing:YES];
}

#pragma mark - _initData
- (void)_initData
{
    _listData = [NSMutableArray array];
    _uploadImages = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i <9; i ++)
    {
        [_uploadImages safeAddObject:@""];
    }
    
    //服务类型
    NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.model.name,@"title",
                             self.model.comment,@"value",
                             kServiceApplyTypeInfo,@"type",
                             [NSNumber numberWithBool:NO], @"edit",
                             nil];
    [_listData safeAddObject:@[tempDic]];
    
    //联系人&&手机号
    VOLoginResponseModel *userInfo = [[VOLoginManager shared] getLoginInfo];
    NSMutableArray *secArray = [NSMutableArray array];
    NSString *name = @"";
    if ([userInfo.user.type integerValue] == 1)
    {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kServiceContactsNameKey];
        if ([[dic safeObjectForKey:@"key"] isEqualToString:[[VOLoginManager shared] getUserId]]) {
               name = [dic safeObjectForKey:@"value"];
        }
    }else if ([userInfo.user.type integerValue] == 2)
    {
        name = userInfo.user.name;
    }
    
    [secArray safeAddObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"title" : @"联系人",
                                                                            @"value" : name.length ? name : @"",
                                                                            @"type" : kServiceApplyContactsInfo,
                                                                            @"hasArrow" : [[[VOLoginManager shared] getUserType] integerValue] == 1 ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO],
                                                                            @"edit" : [NSNumber numberWithBool:YES]
                                                                            }]];
    
    NSString *phone = @"";
    if ([userInfo.user.type integerValue] == 1)
    {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kServiceContactsPhoneKey];
        if ([[dic safeObjectForKey:@"key"] isEqualToString:[[VOLoginManager shared] getUserId]]) {
            phone = [dic safeObjectForKey:@"value"];
        }
    }else if ([userInfo.user.type integerValue] == 2)
    {
        phone = userInfo.user.mobilePhone;
    }
    [secArray safeAddObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"title" : @"手机号",
                                                                            @"value" : phone.length ?  phone : @"",
                                                                            @"type" : kServiceApplyPhoneInfo,
                                                                            @"hasArrow" : [[[VOLoginManager shared] getUserType] integerValue] == 1 ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO],
                                                                            @"edit" : [NSNumber numberWithBool:YES]
                                                                            }]];
    [_listData safeAddObject:secArray];
    //上传照片
    [_listData safeAddObject:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                               @"type" : kServiceApplyUploadImageInfo,
                                                                               @"images" : [NSMutableArray array]
                                                                               }]]];
    //问题描述
    [_listData safeAddObject:@[[NSMutableDictionary dictionaryWithDictionary:@{
                                                                               @"type" : kServiceApplyDescriptionInfo,
                                                                               @"value" : @""
                                                                               }]]];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _listData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_listData safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSArray *tempArray = [_listData safeObjectAtIndex:indexPath.section];
    switch (indexPath.section) {
        case 0:
        case 1:
        {
            VOApplyServiceTableViewCell *cell = [[VOApplyServiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = [[[tempArray safeObjectAtIndex:indexPath.row] safeObjectForKey:@"hasArrow"] boolValue] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.info = [tempArray safeObjectAtIndex:indexPath.row];
            return cell;
        }
            break;
        case 2:
        {
            VOApplyServiceUploadImageTableViewCell *cell = [[VOApplyServiceUploadImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = [[[tempArray safeObjectAtIndex:indexPath.row] safeObjectForKey:@"hasArrow"] boolValue] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.info = [tempArray safeObjectAtIndex:indexPath.row];
            cell.uploadImages = _uploadImages;
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            cell.addImageBlock = ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakCell) strongCell = weakCell;
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (!strongSelf-> _imagePickerController) {
                        strongSelf-> _imagePickerController = [[UIImagePickerController alloc] init];
                        strongSelf-> _imagePickerController.delegate = self;
                        strongSelf-> _imagePickerController.allowsEditing = NO;
                        strongSelf-> _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    }
                    [strongSelf.navigationController presentViewController:strongSelf-> _imagePickerController animated:YES completion:nil];
                }];
                [alertVC addAction:firstAction];
                
                UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {                   
                    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 -  [[strongCell.info safeObjectForKey:@"images"] count] delegate:nil];
                    imagePickerVc.naviBgColor = [UIColor hex:@"45536F"];
                    imagePickerVc.oKButtonTitleColorNormal = [UIColor hex:@"58A5F7"];
                    imagePickerVc.oKButtonTitleColorDisabled = [UIColor hex:@"58A5F7" alpha:.5];
                    imagePickerVc.photoNumberIconImageName = @"Oval";
                    imagePickerVc.photoSelImageName = @"no.2";
                    imagePickerVc.photoOriginSelImageName = @"photesel";
                    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                        NSMutableArray *array = [strongCell.info safeObjectForKey:@"images"];
                        for (UIImage *image in photos) {
                            VOServiceCustomImage *customImage = [[VOServiceCustomImage alloc] initWithCGImage:image.CGImage];
                            [array safeAddObject:customImage];
                        }
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }];
                    [strongSelf.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
                }];
                [alertVC addAction:secondAction];
                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVC addAction:cancleAction];
                [strongSelf presentViewController:alertVC animated:YES completion:nil];
            };
            cell.selectedImageBlock = ^(NSInteger index) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakCell) strongCell = weakCell;
                NSMutableDictionary *tempDic = [tempArray  safeObjectAtIndex:0];
                NSMutableArray *imagesSet = [tempDic safeObjectForKey:@"images"];
                VOServiceCustomImage *image = [imagesSet safeObjectAtIndex:index];
                if (image.isError)
                {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"上传失败" message:[NSString stringWithFormat:@"操作失败，%@",  [image.error.userInfo safeObjectForKey:@"messageCN"]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [imagesSet removeObjectAtIndex:index];
                        [_uploadImages replaceObjectAtIndex:index withObject:@""];
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [strongSelf confirmRightItemStatus];
                    }];
                    [alertVC addAction:firstAction];
                    
                    UIAlertAction *secAction = [UIAlertAction actionWithTitle:@"重新上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [strongCell uploadImageWithIndex:index];
                    }];
                    [alertVC addAction:secAction];
                    [strongSelf presentViewController:alertVC animated:YES completion:nil];
                }else if (image.isStartLoading)
                {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"删除文件" message:@"您确定删除该文件吗？" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [imagesSet removeObjectAtIndex:index];
                        [strongSelf->_uploadImages replaceObjectAtIndex:index withObject:@""];                        
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [strongSelf confirmRightItemStatus];
                    }];
                    [alertVC addAction:firstAction];
                    
                    UIAlertAction *secAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertVC addAction:secAction];
                    [strongSelf presentViewController:alertVC animated:YES completion:nil];
                }
            };
            cell.imagesBlock = ^(NSMutableArray *array) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf-> _uploadImages = array;
                //修改right item status
                [strongSelf confirmRightItemStatus];
            };
            return cell;
        }
            break;
        case 3:
        {
            VOApplyServiceDescriptionTableViewCell *cell = [[VOApplyServiceDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = [[[tempArray safeObjectAtIndex:indexPath.row] safeObjectForKey:@"hasArrow"] boolValue] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.info = [tempArray safeObjectAtIndex:indexPath.row];
            __weak typeof(self) weakSelf = self;
            cell.textBlock = ^(NSString *content) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf-> _contentString = content;
                //修改right item status
                [strongSelf confirmRightItemStatus];
            };
            return cell;
        }
            break;
        default:
            break;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [[_listData safeObjectAtIndex:indexPath.section] safeObjectAtIndex:indexPath.row];
    switch (indexPath.section) {
        case 0:
        case 1:
        {
            return [VOApplyServiceTableViewCell getCellHeight:info];
        }
            break;
        case 2:
        {
            return [VOApplyServiceUploadImageTableViewCell getCellHeight:info];
        }
            break;
        case 3:
        {
            return [VOApplyServiceDescriptionTableViewCell getCellHeight:info];
        }
            break;
            
        default:
            break;
    }
    return 40.;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //收起键盘
    [self.view endEditing:YES];
    
    __block NSMutableDictionary *info = [[_listData safeObjectAtIndex:indexPath.section] safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    if ([[info safeObjectForKey:@"type"] isEqualToString:kServiceApplyContactsInfo])
    {
        VOLoginResponseModel *userInfo = [[VOLoginManager shared] getLoginInfo];
        if ([userInfo.user.type integerValue] == 2)
        {
            return;
        }
        VOContactsViewController *VC = [[VOContactsViewController alloc] init];
        VC.contactName = [info safeObjectForKey:@"value"];
        VC.completeBlock = ^(NSString *text) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [info safeSetObject:text forKey:@"value"];
            [strongSelf->_listView reloadData];
        };
        [self.navigationController pushViewController:VC animated:YES];
    }else if ( [[info safeObjectForKey:@"type"] isEqualToString:kServiceApplyPhoneInfo])
    {
        VOLoginResponseModel *userInfo = [[VOLoginManager shared] getLoginInfo];
        if ([userInfo.user.type integerValue] == 2)
        {
            return;
        }
        VOServicePhoneViewController *VC = [[VOServicePhoneViewController alloc] init];
        VC.phoneNum = [info safeObjectForKey:@"value"];
        VC.completeBlock = ^(NSString *text) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [info safeSetObject:text forKey:@"value"];
            [strongSelf->_listView reloadData];
        };
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - right item status
- (void)confirmRightItemStatus
{
    //联系人&手机号
    NSMutableDictionary *contactName = [[_listData safeObjectAtIndex:1] safeObjectAtIndex:0];
    NSMutableDictionary *phoneNum = [[_listData safeObjectAtIndex:1] safeObjectAtIndex:1];
    //图片
    NSMutableDictionary *imagesDic = [[_listData safeObjectAtIndex:2] safeObjectAtIndex:0];
    NSMutableArray *imagesArray = [imagesDic safeObjectForKey:@"images"];
    BOOL isFinished = YES;
    for (VOServiceCustomImage *image in imagesArray)
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
    //评价内容
    
    if ([[contactName safeObjectForKey:@"value"] length] && [[phoneNum safeObjectForKey:@"value"] length] && isFinished && _contentString.length)
    {
        [self disEnableRightItem:NO];
    }else
    {
        [self disEnableRightItem:YES];
    }
}

#pragma mark- 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *imageDataSource = [[_listData objectAtIndex:2] safeObjectAtIndex:0];
    NSMutableArray *array = [imageDataSource safeObjectForKey:@"images"];
    VOServiceCustomImage *tempImage = (VOServiceCustomImage *)image;
    [array safeAddObject:tempImage];
}

//选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *imageDataSource = [[_listData objectAtIndex:2] safeObjectAtIndex:0];
    NSMutableArray *array = [imageDataSource safeObjectForKey:@"images"];
    image = [self imageCompressFitSizeScale:image targetSize:CGSizeMake(756, 1008)];
    VOServiceCustomImage *tempImage = [[VOServiceCustomImage alloc] initWithCGImage:image.CGImage];
    [array safeAddObject:tempImage];
    
    [_listView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

//按比例缩放,size 是你要把图显示到 多大区域
- (UIImage *) imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
