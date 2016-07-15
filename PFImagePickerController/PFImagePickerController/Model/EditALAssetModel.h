//
//  EditALAssetModel.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/7/14.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ALAsset;
@interface EditALAssetModel : NSObject
/**
 *  alasset对象
 */
@property(nonatomic,strong)ALAsset *asset;
/**
 *  滤镜名称
 */
@property(nonatomic,copy)NSString *filterName;
/**
 *  编辑好的图片
 */
@property(nonatomic,strong)UIImage *editedImage;
@end
