//
//  PFImagePickerTool.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ALAssetModel;
@class ALAssetsGroup;
typedef enum{
    PFImagePickerTypeNone = 0,  //include photos and videos
    PFImagePickerTypePhotos,    //photos
    PFImagePickerTypeVideos     //videos
}mediaType;
typedef void(^enumrationBlock)(NSError *error,NSArray *dataArr);
@interface PFImagePickerTool : NSObject<NSCopying>
/**
 *  判断当前是否可用
 *
 *  @return 返回一个BOOL值(表明当前图库是否可用)
 */
+(BOOL)isAccessible;
/**
 *  遍历获取所有资源
 *
 *  @param finish 完成时调用的block
 * 
 */
+(void)fetchGroupsWithCompletion:(enumrationBlock)finish;
/**
 *  设置筛选的条件,是只展示图片还是视频或者是两者都有
 *  discussion: default is PFImagePickerTypePhotos
 *
 *  @param type 类型
 */
+(void)setFilterType:(mediaType)type;
/**
 *  获取对应group下的assets
 *
 *  @param group ALAssetsGroup对象
 */
+(void)fetchAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish;
/**
 *  针对于刷新数据的,可能图库资源发生改变,这时候要及时刷新展示的数据
 *
 *  @param group  所属的alassetsGroup
 *  @param finish 结束时调用的block
 */
+(void)reloadAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish;
/**
 *  操作模型(删除非选的,添加选择的)
 *
 *  @param model 模型
 */
+(BOOL)storeSelectedOrUnselectedModel:(ALAssetModel *)model;
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
+(void)clearAction;
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
+(UIImage *)loadImageWithName:(NSString *)imageName;
/**
 *  保留编辑的View
 *
 *  @param view
 *
 */
+(void)captureImageWithView:(UIView *)view andWriteToGroup:(ALAssetsGroup *)group withFinishBlock:(void(^)(NSError *error))completion;
extern  NSString * const ALAssetsChangeNotification;
@end
