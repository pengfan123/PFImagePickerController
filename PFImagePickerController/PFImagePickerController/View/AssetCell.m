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
#import "AssetModel.h"
#import <Photos/Photos.h>
@interface AssetCell()
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,strong)AssetModel *dataModel;                //数据模型
@property (weak, nonatomic) IBOutlet UIImageView *assetView;       //展示图片的视图
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;          //选择按钮
@property (weak, nonatomic)id<AssetCellDelegate>delegate;          //代理对象
@property (strong,nonatomic)UITapGestureRecognizer *tapRecognizer; //手势对象
@property (weak, nonatomic) IBOutlet UIImageView *styleView;
@property (strong, nonatomic)NSIndexPath *indexPath;
//点击选择按钮
- (IBAction)selectAct:(UIButton *)sender;

@end
@implementation AssetCell
-(void)awakeFromNib{
    [super awakeFromNib];
    [self.selectBtn setImage:[PFImagePickerTool loadImageWithName:@"unselected"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[PFImagePickerTool loadImageWithName:@"selected"] forState:UIControlStateSelected];
    [self.styleView setImage:[PFImagePickerTool loadImageWithName:@"media"]];
}
-(instancetype)initWithCollectionView:(UICollectionView *)collectionView andDataModel:(AssetModel *)dataModel andIndexPath:(NSIndexPath *)indexPath andDelegate:(id<AssetCellDelegate>)delegate{
    self = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    _assetView.userInteractionEnabled = YES;
    if (!self.tapRecognizer) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [self.assetView addGestureRecognizer:tap];
        self.tapRecognizer = tap;
    }
    self.indexPath = indexPath;
    self.assetView.image = [PFImagePickerTool loadImageWithName:@"big_placeholder"];
    self.delegate  = delegate;
    self.dataModel = dataModel;
    return self;

}
-(void)setDataModel:(AssetModel *)dataModel{
    _assetView.image = nil;
    _dataModel = dataModel;
    _filePath = nil;
    if (_dataModel.mediaType == PHAssetMediaTypeImage) {
        _styleView.hidden = YES;
    }else{
        _styleView.hidden = NO;
    }
    _selectBtn.selected = dataModel.isSelected;
    [PFImagePickerTool addOperation:^{
        [PFImagePickerTool requestImageWithAsset:dataModel.asset targetSize:CGSizeMake(100, 100) completionHandler:^(UIImage *image, NSString *filePath, BOOL succees) {
            if (image) {
                _filePath = filePath;
                CATransition *transition = [[CATransition alloc] init];
                transition.type = kCATransitionFade;
                transition.duration = 0.5;
                _assetView.image = image;
                [_assetView.layer addAnimation:transition forKey:nil];
            }
            
        }];
    }];
   
}

- (IBAction)selectAct:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(AssetCell:didSelectWithDataModel:andButton:)]) {
       _selectBtn.selected = [self.delegate AssetCell:self didSelectWithDataModel:_dataModel andButton:_selectBtn];
    }
}
//进入编辑界面
-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    if ([self.delegate respondsToSelector:@selector(AssetCell:didClickWithDataModel: andOriginalImagePath: andIndex:)]) {
        [self.delegate AssetCell:self didClickWithDataModel:_dataModel andOriginalImagePath:_filePath andIndex:_indexPath.row];
    }
}
@end
