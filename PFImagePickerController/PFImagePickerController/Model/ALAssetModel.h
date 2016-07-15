//
//  ALAssetModel.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class ALAssetModel;
typedef NS_ENUM(NSUInteger, MediaType) {
    PictureStyle,//图片类型
    MovieStyle   //影片类型
};
@interface ALAssetModel : NSObject
/**
 *  数据模型
 */
@property(nonatomic,strong)ALAsset *asset;
/**
 *  判断是否选定
 */
@property(nonatomic,assign)BOOL isSelected;
/**
 *  媒体类型
 */
@property(nonatomic,assign)MediaType type;
/**
 *  原始类型
 */
@property(nonatomic,assign)NSString *typeString;

@end
