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
/**
 *  遍历获取所有资源
 *
 *  @param finish 完成时调用的block
 * 
 */
+ (void)fetchCollectionsWithCompletion:(enumrationBlock)finish;
/**
 *  设置筛选的条件
 *  discussion: default is PHAssetMediaTypeImage
 *
 *  @param type 类型
 */
+ (void)setFilterType:(PHAssetMediaType)type;
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
 *  返回模板颜色
 *
 *  @return 返回一个平铺的颜色
 */
+(UIColor *)shadowColor;
/**
 *  根据图片的名字在bundle中加载图片
 *
 *  @param imageName 图片名称
 *
 *  @return UIImage对象
 */
+ (UIImage *)loadImageWithName:(NSString *)imageName;

/**
 *  保留编辑的View
 *
 *  @param view
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

//获取相册中的资源的数量
+ (void)requestCountOfAssetsInCollection:(PHAssetCollection *)collection completionHandler:(void(^)(NSUInteger count, BOOL result))completion;

//获取准确尺寸的图片(会根据尺寸来裁剪)
+ (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size completionHandler:(void(^)(UIImage *image, NSString *filePath, BOOL succees))handler;

//快速获取图片
+ (void)requestFastImageWithAsset:(PHAsset *)asset Handler:(void(^)(UIImage *image, NSString *UTI, BOOL succees))handler;

//根据Asset取得图片(原图)
+ (void)requestImageWithAsset:(PHAsset *)asset completionHandler:(void(^)(UIImage *image, NSString *filePath, BOOL succees))handler;

//根据collection获取相册的封面
+ (void)requestPosterForAssetsCollection:(PHAssetCollection *)collection completionHandler:(void(^)(UIImage *result, NSString *filePath, BOOL succees))completion;
+ (void)addOperation:(operationBlock) operation;

+ (void)enumToGetImage:(NSArray <AssetModel *> *)models andHandler:(void(^)(BOOL *stop, NSUInteger index, UIImage *result, NSString *UTI))completion;
extern  NSString *  const PhotosChangeNotification;
extern  NSString *  const PhotosDidEndSelectNotification;
@end
