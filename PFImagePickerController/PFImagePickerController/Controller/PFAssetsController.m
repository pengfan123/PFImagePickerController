//
//  PFAssetsController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFAssetsController.h"
#import "PFImagePickerController.h"
#import "PFEditImageController.h"
#import "PFMovieController.h"
#import "PFImagePickerTool.h"
#import "AssetCell.h"
#import "ALAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
static NSString * const identifier = @"AssetCell";
@interface PFAssetsController ()<UICollectionViewDataSource,UICollectionViewDelegate,AssetCellDelegate>
@property(nonatomic,weak)UICollectionView *assetsView;
@property(nonatomic,strong)NSArray *dataArr;
@end

@implementation PFAssetsController
#pragma mark - lazy loading 
-(NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSArray new];
    }
    return _dataArr;
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registObserver];
    [self setupUI];
    [self loadData];
    [self updateButtonStatus];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsChangeNotification object:nil];
}
#pragma mark - private method
-(void)setupUI{
    //set Title
    self.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //add collectionView
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 3.0;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.headerReferenceSize = CGSizeZero;
    
    UICollectionView *assetsView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    assetsView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    assetsView.backgroundColor = [UIColor whiteColor];
    assetsView.delegate   = self;
    assetsView.dataSource = self;
    [assetsView registerNib:[UINib nibWithNibName:@"AssetCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:assetsView];
    _assetsView = assetsView;
    
    //add rightBarbuttonItem
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
#pragma mark - private method
-(void)doneAction:(id)sender{
    [self.imagePickerController pfImagePickerControllerDidFinishPickImage];
}
-(void)registObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsChangeNotification:) name:ALAssetsChangeNotification object:nil];
}
-(void)assetsChangeNotification:(NSNotification *)info{
    //延时更新,避免刷新失败
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self reloadData];
    });
}
-(void)updateButtonStatus{
    self.navigationItem.rightBarButtonItem.enabled = [PFImagePickerTool checkSelectionStatus];
}
-(void)reloadData{
    [PFImagePickerTool reloadAssetsWithAlbumsGroup:_group andCompletion:^(NSError *error, NSArray *dataArr) {
        if (error) {
        }else{
            //update UI
            self.dataArr = dataArr;
            [_assetsView reloadData];
        }
    }];
}
-(void)loadData{
    [PFImagePickerTool fetchAssetsWithAlbumsGroup:_group andCompletion:^(NSError *error, NSArray *dataArr) {
        if (error) {
        }else{
            //update UI
            self.dataArr = dataArr;
            [_assetsView reloadData];
        }
    }];
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ALAssetModel *model = nil;
    if (indexPath.item < self.dataArr.count) {        
        model = self.dataArr[indexPath.row];
    }
    AssetCell *cell = [[AssetCell alloc] initWithCollectionView:collectionView andDataModel:model andIndexPath:indexPath andDelegate:self];
    return cell;
}
#pragma mark - AssetCellDelegate
//点击选择按钮
-(BOOL)AssetCell:(AssetCell *)cell didSelectWithDataModel:(ALAssetModel *)dataModel andButton:(UIButton *)selectBtn{
    dataModel.isSelected = !dataModel.isSelected;
    dataModel.isSelected = [PFImagePickerTool storeSelectedOrUnselectedModel:dataModel];
    [self updateButtonStatus];
    return dataModel.isSelected;
    
}
//点击item,预留的,跳入编辑界面
-(void)AssetCell:(AssetCell *)cell didClickWithDataModel:(ALAssetModel *)dataModel{
    if (dataModel.type == PictureStyle) {
        PFEditImageController *editController = [[PFEditImageController alloc] init];
        editController.asset = dataModel.asset;
        editController.group = self.group;
        [self.navigationController pushViewController:editController animated:YES];
    }else{
        PFMovieController *movieController = [[PFMovieController alloc] init];
        movieController.asset = dataModel.asset;
        [self.navigationController pushViewController:movieController animated:YES];
    }
    
}
@end
