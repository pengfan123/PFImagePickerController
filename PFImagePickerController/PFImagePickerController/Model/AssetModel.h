//
//  AssetModel.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/6/1.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PhotosTypes.h>
@class PHAsset, PHCollection;

@interface AssetModel : NSObject
/**
 *  数据模型
 */
@property(nonatomic,strong)PHAsset *asset;
/**
 *  判断是否选定
 */
@property(nonatomic,assign)BOOL isSelected;
/**
 *  媒体类型
 */
@property(nonatomic,assign)PHAssetMediaType mediaType;
/**
 *  所属集合
 */
@property(nonatomic,strong)PHCollection *collection;
/**
 *  所属集合
 */
@property(nonatomic,assign)long long fileSize;

/**
 * 是否为原图
 */
@property(nonatomic,assign)BOOL original;
@end
