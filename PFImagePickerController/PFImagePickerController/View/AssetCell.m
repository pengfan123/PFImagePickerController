//
//  AssetCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "AssetCell.h"
#import "PFImagePickerController.h"
#import "PFImagePickerTool.h"
#import "ALAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface AssetCell()
@property(nonatomic,strong)ALAssetModel *dataModel;                //数据模型
@property (weak, nonatomic) IBOutlet UIImageView *assetView;       //展示图片的视图
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;          //选择按钮
@property (weak, nonatomic)id<AssetCellDelegate>delegate;          //代理对象
@property (strong,nonatomic)UITapGestureRecognizer *tapRecognizer; //手势对象
@property (weak, nonatomic) IBOutlet UIImageView *styleView;
//点击选择按钮
- (IBAction)selectAct:(UIButton *)sender;

@end
@implementation AssetCell
-(void)awakeFromNib{
    [self.selectBtn setImage:[PFImagePickerTool loadImageWithName:@"unselected"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[PFImagePickerTool loadImageWithName:@"selected"] forState:UIControlStateSelected];
    [self.styleView setImage:[PFImagePickerTool loadImageWithName:@"media"]];
}
-(instancetype)initWithCollectionView:(UICollectionView *)collectionView andDataModel:(ALAssetModel *)dataModel andIndexPath:(NSIndexPath *)indexPath andDelegate:(id<AssetCellDelegate>)delegate{
    self = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    _assetView.userInteractionEnabled = YES;
    if (!self.tapRecognizer) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [self.assetView addGestureRecognizer:tap];
        self.tapRecognizer = tap;
    }
    self.delegate  = delegate;
    self.dataModel = dataModel;
    return self;
}
-(void)setDataModel:(ALAssetModel *)dataModel{
    _dataModel = dataModel;
    _assetView.image = [UIImage imageWithCGImage:dataModel.asset.thumbnail];
    _selectBtn.selected = _dataModel.isSelected;
    if (_dataModel.type == PictureStyle) {
        _styleView.hidden = YES;
    }else{
        _styleView.hidden = NO;
    }
}
- (IBAction)selectAct:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(AssetCell:didSelectWithDataModel:andButton:)]) {
       _selectBtn.selected = [self.delegate AssetCell:self didSelectWithDataModel:_dataModel andButton:_selectBtn];
    }
}
//进入编辑界面
-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    if ([self.delegate respondsToSelector:@selector(AssetCell:didClickWithDataModel:)]) {
        [self.delegate AssetCell:self didClickWithDataModel:_dataModel];
    }
}
@end
