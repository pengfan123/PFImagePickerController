//
//  PFSelectView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/7/14.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFSelectView.h"
#import "PFSelectViewCell.h"
#import "EditALAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define HEIGHT 100
#define SPACE 10
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface PFSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
/*
 arr---------(
 CIColorCrossPolynomial,
 CIColorCube,
 CIColorCubeWithColorSpace,
 CIColorInvert,
 CIColorMap,
 CIColorMonochrome,
 CIColorPosterize,
 CIFalseColor,
 CIMaskToAlpha,
 CIMaximumComponent,
 CIMinimumComponent,
 CIPhotoEffectChrome,
 CIPhotoEffectFade,
 CIPhotoEffectInstant,
 CIPhotoEffectMono,
 CIPhotoEffectNoir,
 CIPhotoEffectProcess,
 CIPhotoEffectTonal,
 CIPhotoEffectTransfer,
 CISepiaTone,
 CIVignette,
 CIVignetteEffect
 */
#pragma mark - property
@property(nonatomic,strong)NSArray *dataArr;
@end
@implementation PFSelectView
#pragma mark - lazy loading 
#warning  add as many filterNames as you want
-(NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSArray arrayWithObjects:@"CIColorMonochrome",@"CIVignetteEffect",@"CIPhotoEffectChrome",@"CIVignette",@"CISepiaTone",@"CIPhotoEffectFade",@"CIFalseColor",@"CILinearToSRGBToneCurve",@"CIVibrance",@"CIColorPolynomial",@"CISRGBToneCurveToLinear",@"CITemperatureAndTint",@"CICircularScreen",@"CICMYKHalftone",@"CIDotScreen",nil];
    }
    return _dataArr;
}
#pragma mark - life cycle
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(90, 90);
    CGRect suitableFrame = CGRectMake(0,SCREEN_HEIGHT,SCREEN_WIDTH, HEIGHT);
    if (self = [super initWithFrame:suitableFrame collectionViewLayout:flowLayout]) {
        [self registerClass:[PFSelectViewCell class] forCellWithReuseIdentifier:@"PFSelectViewCell"];
        self.backgroundColor = [UIColor whiteColor];
        self.dataSource = self;
        self.delegate =  self;
    }
    return self;
}
#pragma mark - private method
-(void)setAsset:(ALAsset *)asset{
    _asset = asset;
    [self reloadData];
}
-(void)show{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -HEIGHT);
    }];
}
-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSections{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filter = nil;
    if (indexPath.row < self.dataArr.count) {
        filter = self.dataArr[indexPath.row];
    }
    EditALAssetModel *dataModel = [[EditALAssetModel alloc] init];
    dataModel.filterName = filter;
    dataModel.asset = self.asset;
    PFSelectViewCell *cell = [[PFSelectViewCell alloc] initWithCollectionView:collectionView andIndexPath:indexPath andDataModel:dataModel];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PFSelectViewCell *cell = (PFSelectViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.del respondsToSelector:@selector(PFSelectView:didSelectWithDataModel:)]) {
        [self.del PFSelectView:self didSelectWithDataModel:cell.dataModel];
    }
}
@end
