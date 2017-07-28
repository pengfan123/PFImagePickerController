//
//  ShowImageCell.h
//  PFImagePickerController
//
//  Created by 彭凡 on 2017/7/6.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssetModel, ShowImageCell;
@protocol ShowImageCellDelegate <NSObject>

@optional
- (void)cell: (ShowImageCell *)cell didSelectItemAtIndex:(NSIndexPath *)indexPath;

@end
@interface ShowImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *poster;
+(instancetype)getCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andDataModel:(AssetModel *)data;
@property (nonatomic,weak)id<ShowImageCellDelegate>delegate;
@property (strong, nonatomic)AssetModel *data;
- (void)renderImageWithFilter:(NSString *)filter;
@end
