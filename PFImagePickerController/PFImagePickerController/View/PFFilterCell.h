//
//  PFFilterCell.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/26.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFFilterCell : UICollectionViewCell

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andFilter:(NSString *)filter andImage:(UIImage *)image;
@property (copy, nonatomic)NSString *filter;
@end
