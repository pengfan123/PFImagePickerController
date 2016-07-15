//
//  PFImagePickerTool.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFImagePickerTool.h"
#import "ALAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
NSString * const ALAssetsChangeNotification = @"PFImagePickerToolUpdate";
@interface PFImagePickerTool()
//过滤的条件(图片,视频或者两者都包含)
@property(nonatomic,assign)mediaType filter;
@property(nonatomic,assign)NSUInteger minumCount;
@property(nonatomic,assign)NSUInteger maxCount;
@end
static NSMutableDictionary *selectedDic;      //用于存放选定的模型
static NSMutableDictionary *cacheDic;    //用于缓存模型
static ALAssetsLibrary *library;         //library对象
static PFImagePickerTool *shareTool;     //单例对象
@implementation PFImagePickerTool
#pragma mark - singleton
+(instancetype)sharedTool{
    return [[self alloc] init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    if(shareTool == nil){//防止多次加锁
        @synchronized(self) {
            if (shareTool == nil) {//防止重复创建
                shareTool = [super allocWithZone:zone];
            }
        }
        
    }
    return shareTool;
}
-(id)copyWithZone:(NSZone *)zone
{
    return shareTool;
}
#pragma mark - initialize
+(void)initialize
{
    //initialize the dictionary
    selectedDic = [NSMutableDictionary new];
    cacheDic    = [NSMutableDictionary new];
    library     = [[ALAssetsLibrary alloc] init];
    shareTool   = [[self alloc] init];
    shareTool.filter = PFImagePickerTypePhotos;
    shareTool.minumCount = 0;
    shareTool.maxCount   = 10;
    //regist observer
    [[NSNotificationCenter defaultCenter] addObserver:shareTool selector:@selector(alassetsLibraryChangeNotification:) name:ALAssetsLibraryChangedNotification object:nil];
    
}
#pragma mark - static method
+(BOOL)isAccessible
{
   return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]&&[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}
+(UIColor *)shadowColor
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PFImagePickerController" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [bundle pathForResource:@"shadow" ofType:@"png"];
    return [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:imagePath]];
}
+(void)setFilterType:(mediaType)type
{
    PFImagePickerTool *tool = [self sharedTool];
    tool.filter = type;
}
+(void)setMaxCount:(NSUInteger)maxCount
{
    PFImagePickerTool *tool = [self sharedTool];
    tool.maxCount = maxCount;
}
+(void)setMinumCount:(NSUInteger)minumCount
{
    PFImagePickerTool *tool = [self sharedTool];
    tool.minumCount = minumCount;
}
+(BOOL)checkSelectionStatus
{
    BOOL status = NO;
    PFImagePickerTool *tool = [self sharedTool];
    NSUInteger count = [selectedDic allValues].count;
    if (count >= tool.minumCount && count <= tool.maxCount) {
        status = YES;
    }
    return status;
}
+(void)fetchGroupsWithCompletion:(enumrationBlock)finish
{
    [[self sharedTool] fetchGroupsWithCompletion:finish];
}
+(void)fetchAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish{
    [[self sharedTool] fetchAssetsWithAlbumsGroup:group andCompletion:finish];
}
+(void)reloadAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish{
    [[self sharedTool] reloadAssetsWithAlbumsGroup:group andCompletion:finish];
}
+(BOOL)storeSelectedOrUnselectedModel:(ALAssetModel *)model
{
    if (!model) {
        return NO;
    }
    if (model.isSelected) {
        [selectedDic setObject:model forKey:model.asset.defaultRepresentation.url.absoluteString];
        if (![self canSelect]) {
            [selectedDic removeObjectForKey:model.asset.defaultRepresentation.url.absoluteString];
            model.isSelected = NO;
            return NO;
        }
        return YES;
    }else{
        [selectedDic removeObjectForKey:model.asset.defaultRepresentation.url.absoluteString];
        return NO;
    }
   
}
+(BOOL)canSelect
{
    if (selectedDic.allValues.count > shareTool.maxCount) {
        return NO;
    }else{
        return YES;
    }
}
+(NSArray *)getSelectedAssetsArr
{
    NSMutableArray *dataArr = [NSMutableArray new];
    NSArray *arr = [selectedDic allValues];
    for (ALAssetModel *oneModel in arr) {
        [dataArr addObject:oneModel.asset];
    }
    return [NSArray arrayWithArray:dataArr];
}
+(void)clearAction{
    [selectedDic removeAllObjects];
    [cacheDic removeAllObjects];
    shareTool.minumCount = 0;
    shareTool.maxCount   = 10;
    shareTool.filter = PFImagePickerTypePhotos;
}
+(UIImage *)loadImageWithName:(NSString *)imageName
{
    if (!imageName) {
        return nil;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PFImagePickerController" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
#pragma mark -  dynamic method
-(void)fetchGroupsWithCompletion:(enumrationBlock)finish
{
    enumrationBlock completion = [finish copy];
    __block NSMutableArray *dataArr = [NSMutableArray new];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll|ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [dataArr addObject:group];
        }else{
            if (completion) {
                NSArray *array = [NSArray arrayWithArray:dataArr];
                completion(nil,array);
            }
        }
    } failureBlock:^(NSError *error) {
        if (completion) {
            NSArray *array = [NSArray arrayWithArray:dataArr];
            completion(error,array);
        }
    }];
    
}
-(void)fetchAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish{
    if (!group) {
        return;
    }
   __block enumrationBlock completion = [finish copy];
    //before fetch data ,check if there has cached data
    NSArray *cacheArr = [self fetchCachedDataWithGroup:group];
    if (cacheArr) {
        if (completion) {
            completion(nil,cacheArr);
            return;
        }
    }
    ALAssetsFilter *filter = nil;
    switch (self.filter) {
        case PFImagePickerTypeNone:
            filter = [ALAssetsFilter allAssets];
            break;
        case PFImagePickerTypePhotos:
            filter = [ALAssetsFilter allPhotos];
            break;
        case PFImagePickerTypeVideos:
            filter = [ALAssetsFilter allVideos];
            break;
        default:
            break;
    }
     __block NSInteger count = 0;
     __block NSMutableArray *dataArr = [NSMutableArray new];
    [group setAssetsFilter:filter];
    void(^checkCount)() = ^(){
        if (count == group.numberOfAssets) {
            if (completion) {
                NSArray *array = [NSArray arrayWithArray:dataArr];
                NSURL *url = [group valueForProperty:ALAssetsGroupPropertyURL];
                cacheDic[url.absoluteString] = array;//store the data
                completion(nil,array);
                completion = nil;
            }
        }
    };
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        @autoreleasepool {
        if (result) {
                  ALAssetModel *model = nil;
                  model = [selectedDic objectForKey:result.defaultRepresentation.url.absoluteString];
            
            if (!model) {
                  model = [[ALAssetModel alloc] init];
                  model.asset = result;
                  model.typeString = [result valueForProperty:ALAssetPropertyType];
                
            }
                  [dataArr addObject:model];
                  count++;
        }else{
            checkCount();
            *stop = YES;
            
          }
            
        }
    }];
}
-(void)reloadAssetsWithAlbumsGroup:(ALAssetsGroup *)group andCompletion:(enumrationBlock)finish{
    if (!group) {
        return;
    }
    __block enumrationBlock completion = [finish copy];
    ALAssetsFilter *filter = nil;
    switch (self.filter) {
        case PFImagePickerTypeNone:
            filter = [ALAssetsFilter allAssets];
            break;
        case PFImagePickerTypePhotos:
            filter = [ALAssetsFilter allPhotos];
            break;
        case PFImagePickerTypeVideos:
            filter = [ALAssetsFilter allVideos];
            break;
        default:
            break;
    }
    __block NSInteger count = 0;
    __block NSMutableArray *dataArr = [NSMutableArray new];
    [group setAssetsFilter:filter];
    void(^checkCount)() = ^(){
        if (count == group.numberOfAssets) {
            if (completion) {
                NSArray *array = [NSArray arrayWithArray:dataArr];
                NSURL *url = [group valueForProperty:ALAssetsGroupPropertyURL];
                cacheDic[url.absoluteString] = array;//store the data
                completion(nil,array);
                completion = nil;
            }
        }
    };
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        @autoreleasepool {
            if (result) {
                ALAssetModel *model = nil;
                model = [selectedDic objectForKey:result.defaultRepresentation.url.absoluteString];
                
                if (!model) {
                    model = [[ALAssetModel alloc] init];
                    model.asset = result;
                    model.typeString = [result valueForProperty:ALAssetPropertyType];
                    
                }
                [dataArr addObject:model];
                count++;
            }else{
                checkCount();
                *stop = YES;
                
            }
            
        }
    }];

}
-(NSArray *)fetchCachedDataWithGroup:(ALAssetsGroup *)group
{
    NSArray *dataArr = [NSMutableArray new];
    NSURL *url = [group valueForProperty:ALAssetsGroupPropertyURL];
    dataArr = [cacheDic objectForKey:url.absoluteString];
    if (dataArr.count == 0 || dataArr == nil) {//there has no cached data
        return nil;
    }
    return dataArr;
}
+(void)captureImageWithView:(UIView *)view andWriteToGroup:(ALAssetsGroup *)group withFinishBlock:(void (^)(NSError *))completion{
    void(^returnBlock)(NSError *error) = [completion copy];
    __block NSError *resultError = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [view.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {    //写入错误
                resultError = error;
            }
            else{
                [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        BOOL result = [group addAsset:asset];
                        NSLog(@"写入的结果---------%d",result);
                    }
                } failureBlock:^(NSError *error) {
                    
                    resultError = error;
                }];

                
            }
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
              returnBlock(resultError);
        });
    });
    
}
#pragma mark - about notification
-(void)alassetsLibraryChangeNotification:(NSNotification *)info
{
    NSDictionary *infoDic = info.userInfo;
    NSSet *set = [infoDic objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
    
    for (NSURL *updateGroupURL in set) {
        
       __block ALAssetsGroup *resultGroup = nil;
        
        [library groupForURL:updateGroupURL resultBlock:^(ALAssetsGroup *group) {
            
            resultGroup = group;
            
        } failureBlock:^(NSError *error) {
            
        }];
        
        [cacheDic removeObjectForKey:updateGroupURL.absoluteString];
        [self fetchAssetsWithAlbumsGroup:resultGroup andCompletion:nil];
        
    }
    [self postChangeNotification];
}
-(void)postChangeNotification
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:ALAssetsChangeNotification object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}
@end
