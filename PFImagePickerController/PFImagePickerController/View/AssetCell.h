//
//  AssetCell.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssetModel;
@class AssetCell;
@protocol AssetCellDelegate <NSObject>
@optional
/**
 *  点击某个Cell
 *
 *  @param cell      cell对象
 *  @param dataModel 数据模型
 */
-(void)AssetCell:(AssetCell *)cell didClickWithDataModel:(AssetModel *)dataModel andOriginalImagePath:(NSString *) imagePath andIndex:(NSInteger)index;
/**
 *  交给controller去判断是否能被选定
 *
 *  @param cell      AssetCell对象
 *  @param dataModel 数据模型
 *  @param selectBtn 选定按钮
 *
 *  @return 返回的是一个BOOL值 指示这个按钮是否可以被选定
 */
-(BOOL)AssetCell:(AssetCell *)cell didSelectWithDataModel:(AssetModel *)dataModel andButton:(UIButton *)selectBtn;
@end
@interface AssetCell : UICollectionViewCell
-(instancetype)initWithCollectionView:(UICollectionView *)collectionView andDataModel:(AssetModel *)dataModel andIndexPath:(NSIndexPath *)indexPath andDelegate:(id<AssetCellDelegate>)delegate;
- (void)updateIndex;
@end
