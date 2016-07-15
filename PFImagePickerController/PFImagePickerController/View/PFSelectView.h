//
//  PFSelectView.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/7/14.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAsset;
@class EditALAssetModel;
@class PFSelectView;
@protocol PFSelectViewDelegate<UICollectionViewDelegate>

@optional
-(void)PFSelectView:(PFSelectView *)selectView didSelectWithDataModel:(EditALAssetModel *)dataModel;

@end

@interface PFSelectView : UICollectionView
@property(nonatomic,weak)id<PFSelectViewDelegate>del;
-(void)show;
-(void)hide;
@property(nonatomic,strong)ALAsset *asset;
@end
