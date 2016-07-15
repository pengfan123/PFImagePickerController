//
//  PFSelectViewCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/7/14.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFSelectViewCell.h"
#import "EditALAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface PFSelectViewCell()

#pragma mark - property

@property(nonatomic,weak)UIImageView *posterView;
@end
@implementation PFSelectViewCell
#pragma mark - lazy loading
-(UIImageView *)posterView{
    if (_posterView == nil) {
        UIImageView *posterView = [[UIImageView alloc] initWithFrame:self.bounds];
        posterView.userInteractionEnabled = YES;
        [self.contentView addSubview:posterView];
        _posterView = posterView;
        
    }
    return _posterView;
}
#pragma mark - life cycle
-(instancetype)initWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andDataModel:(EditALAssetModel *)dataModel{
    static NSString *identifier = @"PFSelectViewCell";
    self = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"PFSelectViewCell" owner:nil options:nil] lastObject];
    }
    self.dataModel = dataModel;
    return self;
}

#pragma mark - private method
-(void)setDataModel:(EditALAssetModel *)dataModel{
    _dataModel = dataModel;
    if (_dataModel == nil) {
        return;
    }
    
    if (_dataModel.editedImage == nil) {
        self.posterView.image = [UIImage imageWithCGImage:_dataModel.asset.thumbnail];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CIFilter *filter = [CIFilter filterWithName:_dataModel.filterName];
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            NSDictionary *options = @{kCIContextWorkingColorSpace:[NSNull null]};
            CIContext *context = [CIContext contextWithEAGLContext:eaglContext options:options];
            [filter setValue:[CIImage imageWithCGImage:_dataModel.asset.thumbnail] forKey:kCIInputImageKey];
            CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
            CGImageRef resultImage = [context createCGImage:outputImage fromRect:outputImage.extent];
            _dataModel.editedImage = [UIImage imageWithCGImage:resultImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                 self.posterView.image = _dataModel.editedImage;
            });
        });
       
    }else{
        self.posterView.image = _dataModel.editedImage;
    }
}

@end
