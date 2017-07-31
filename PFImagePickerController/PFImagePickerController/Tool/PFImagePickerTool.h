//
//  PFImagePickerTool.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class PHAsset, PHAssetCollection, AssetModel;

typedef void(^enumrationBlock)(NSError *error,NSArray *dataArr);
typedef void(^operationBlock)();

@interface PFImagePickerTool : NSObject<NSCopying,PHPhotoLibraryChangeObserver>

extern  NSString *  const PhotosChangeNotification;
extern  NSString *  const PhotosDidEndSelectNotification;

/**
 *  设置筛选的条件
 *  discussion: default is PHAssetMediaTypeImage
 *
 *  @param type 类型
 */
+ (void)setFilterType:(PHAssetMediaType)type;
/**
 *  返回当前选择的数量
 *
 */

+ (NSInteger)selectedCount;
/**
 *  设置最多选择的图片的数量
 *
 *  @param maxCount 最大数量  default is 10
 */
+(void)setMaxCount:(NSUInteger)maxCount;
/**
 *  设置最少选择图片的数量
 *
 *  @param minumCount 最小数量 default is 0
 */
+(void)setMinumCount:(NSUInteger)minumCount;
/**
 *  返回已选择的图库
 *
 *  @return 返回assets对象的数组
 */
+(NSArray *)getSelectedAssetsArr;
/**
 *  清除缓存数据
 */
+ (void)restoreAction;
/**
 *  判断是否能选定
 *
 *  @return 返回BOOL类型数值,指定是否能够操作(如果已经达到maxCount就不能操作)
 */
+(BOOL)canSelect;
/**
 *  检查选择的模型的个数是否符合大于minumCount并且小于maxCount
 *
 *  @return 如果符合条件返回YES,否则返回NO
 */
+(BOOL)checkSelectionStatus;
/**
 *  添加操作block(任务)
 *
 *  @param operation 操作
 *
 */
+ (void)addOperation:(operationBlock) operation;

/**
 *  遍历获取所有资源集合
 *
 *  @param finish 完成时调用的block
 * 
 */
+ (void)fetchCollectionsWithCompletion:(enumrationBlock)finish;

/**
 *  获取对应group下的assets
 *
 *  @param collection PHAssetCollection对象
 */
+(void)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish ;
/**
 *  针对于刷新数据的,可能图库资源发生改变,这时候要及时刷新展示的数据
 *
 *  @param collection  所属的PHAssetCollection
 *  @param finish 结束时调用的block
 */
+ (void)reloadAssetsWithCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish;
/**
 *  操作模型(删除非选的,添加选择的)
 *
 *  @param model 模型
 */
+ (BOOL)storeSelectedOrUnselectedModel:(AssetModel *)model;

/**
 *  保留编辑的图片
 *
 *  @param image 编辑过的图片
 *
 */
+ (void)captureImage:(UIImage *)image handler:(void (^)(BOOL result))completion;
/**
 *  保留编辑的View
 *
 *  @param view
 *
 */
+ (void)captureImageWithView:(UIView *)view andWriteToCollection:(PHAssetCollection *)collection withFinishBlock:(void (^)(NSError *, BOOL))completion;
/**
 *  保留编辑的View(保存到以你自己app名字命名的相册中)
 *
 *  @param view
 *
 */
+ (void)captureImageWithView:(UIView *)view withFinishBlock:(void (^)(BOOL success, UIImage *result))completion;
/**
 *  获取集合中资源的数量
 *
 *  @param collection 集合
 *  @param completion 结束操作
 *
 */
+ (void)requestCountOfAssetsInCollection:(PHAssetCollection *)collection completionHandler:(void(^)(NSUInteger count, BOOL result))completion;

/**
 *  获取准确尺寸的图片(会根据尺寸来裁剪)
 *
 *  @param asset 资源
 *  @param size  尺寸
 *  @param handler 结束操作
 *
 */
+ (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size completionHandler:(void(^)(UIImage *image, NSString *filePath, BOOL succees))handler;
/**
 *  快速获取原图(同步)
 *
 *  @param asset 资源
 *  @param handler 结束操作
 *
 */
+ (void)requestFastImageWithAsset:(PHAsset *)asset Handler:(void(^)(UIImage *image, NSString *UTI, BOOL succees))handler;
/**
 *  获取原图
 *
 *  @param asset 资源
 *  @param handler 结束操作
 *
 */
+ (void)requestImageWithAsset:(PHAsset *)asset completionHandler:(void(^)(UIImage *image, NSString *filePath, BOOL succees, NSString *UTI))handler;
/**
 *  获取集合的封面图片
 *
 *  @param collection 资源集合
 *  @param completion 结束操作
 *
 */
+ (void)requestPosterForAssetsCollection:(PHAssetCollection *)collection completionHandler:(void(^)(UIImage *result, NSString *filePath, BOOL succees))completion;
/**
 *  选择完了之后遍历获取图片
 *
 *  @param models 模型数组
 *  @param completion 结束操作
 *
 */
+ (void)enumToGetImage:(NSArray <AssetModel *> *)models andHandler:(void(^)(BOOL *stop, NSUInteger index, UIImage *result, NSString *UTI))completion;
@end
