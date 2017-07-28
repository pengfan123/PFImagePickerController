//
//  ShowImageCell.m
//  PFImagePickerController
//
//  Created by 彭凡 on 2017/7/6.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "ShowImageCell.h"
#import "AssetModel.h"
#import "PFImagePickerTool.h"
#import "PFFilterTool.h"
@interface ShowImageCell()<UIScrollViewDelegate>



@property (nonatomic,strong)NSIndexPath *indexPath;
@property (strong,nonatomic)UITapGestureRecognizer *recognizer;
@property (nonatomic,strong)UIImage *originalImage;
@end
@implementation ShowImageCell

#pragma mark - life cycle
+ (instancetype)getCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andDataModel:(AssetModel *)data {
    ShowImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.data = data;
    if (!cell.recognizer) {
        cell.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(tapAction:)];
        cell.recognizer.numberOfTouchesRequired = 1;
        cell.recognizer.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:cell.recognizer];
    }
    return cell;
}

- (void)setData:(AssetModel *)data {
    _data = data;
    [PFImagePickerTool requestImageWithAsset:data.asset completionHandler:^(UIImage *image, NSString *filePath, BOOL succees) {
        _poster.image = image;
        _originalImage  = image;

    }];
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return  _poster;
}
- (void)renderImageWithFilter:(NSString *)filter {
    [PFFilterTool filterOperationWithImage:_originalImage andFilter:filter andDisplayView:_poster andIdetifier:[NSString stringWithFormat:@"%@%@",_data.asset.localIdentifier, filter]];
}
- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(cell:didSelectItemAtIndex:)]) {
        [self.delegate cell:self didSelectItemAtIndex:_indexPath];
    }
}
- (void)dealloc {
    _originalImage = nil;
}
@end
