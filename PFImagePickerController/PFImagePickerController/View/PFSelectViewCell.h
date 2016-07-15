//
//  PFSelectViewCell.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/7/14.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditALAssetModel;
@interface PFSelectViewCell : UICollectionViewCell
@property(nonatomic,strong)EditALAssetModel *dataModel;
-(instancetype)initWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andDataModel:(EditALAssetModel *)dataModel;

@end
