//
//  VOServiceOfPropertyViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/23.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOServiceOfPropertyViewController.h"
#import "VOServicePropertyCollectionViewCell.h"

#import "VOPropertyListModel.h"
#import "VONetworking+Session.h"

#import "VOLoginManager.h"
#import "UIResultMessageView.h"

#import "VOApplyForServiceViewController.h"

@interface VOServiceOfPropertyViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *collectionView;
    NSMutableArray *_listData;
    
    VOPropertyListModel *_listModel;
}
@end

@implementation VOServiceOfPropertyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"物业服务";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor hex:@"45536F"];
    
    //_initSubViews
    [self _initSubViews];
    
    //loadWebData
    [self loadWebData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
}
#pragma mark - 联系客服
- (void)connectService
{
    if (_listModel.telephones.count > 1)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"选择客服电话" preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSString *telephone in _listModel.telephones) {
            NSInteger index = [_listModel.telephones safeIndexOfObject:telephone];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:[_listModel.telephones safeObjectAtIndex:index] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[_listModel.telephones safeObjectAtIndex:index] ]]];
            }];
            [alertVC addAction:firstAction];
        }
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:cancleAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }else
    {
        NSString *phone = [_listModel.telephones safeObjectAtIndex:0];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]];
    }

}

#pragma mark -
- (void)_initSubViews
{
    //data source
    _listData = [NSMutableArray array];
    //flowout
    CGFloat offsetY = Height_NavBar;
    CGFloat spacewidth = (SCREEN_WIDTH - 24.*2 - 15)/2;
    UICollectionViewFlowLayout*flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(spacewidth,168);
    flowLayout.minimumLineSpacing = 15.;
    flowLayout.minimumInteritemSpacing = 15.;
    
    collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(24.,0,SCREEN_WIDTH - 24.*2,self.view.frame.size.height - offsetY)collectionViewLayout:flowLayout];
    collectionView.delegate=self;
    collectionView.dataSource=self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.bounces = NO;
    [self.view addSubview:collectionView];
    [collectionView registerClass:[VOServicePropertyCollectionViewCell class] forCellWithReuseIdentifier:@"reuse"];
}

- (void)loadWebData
{
    VOLoginResponseModel *model = [[VOLoginManager shared] getLoginInfo];
    NSString *url = [NSString stringWithFormat:@"/v1.0.0/api/project/%@/upkeep/info",model.user.currentProject.projectId];
    [VONetworking getWithUrl:url refreshRequest:NO cache:NO params:nil needSession:NO successBlock:^(id response) {
        _listModel = [[VOPropertyListModel alloc] initWithJSONDictionary:response];
        if (_listModel.telephones.count) {
            //right item
            [self createRightItemWithTitle:@"联系客服" target:self action:@selector(connectService)];
        }
        [_listData addObjectsFromArray:_listModel.types];
        [collectionView reloadData];
    } failBlock:^(NSError *error) {
        if (error.code != -9999)    // -9999为无网络码
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listData.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    VOServicePropertyCollectionViewCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    cell.model = [_listData safeObjectAtIndex:indexPath.row];
    cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
    cell.layer.cornerRadius = 2.;
    cell.layer.masksToBounds = YES;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(16, 0, 0, 0);//分别为上、左、下、右
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VOApplyForServiceViewController *applyVC = [[VOApplyForServiceViewController alloc] init];
    applyVC.model = [_listData safeObjectAtIndex:indexPath.row];
    [self.navigationController pushViewController:applyVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
