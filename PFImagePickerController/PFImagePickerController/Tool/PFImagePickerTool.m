//
//  PFImagePickerTool.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFImagePickerTool.h"
#import "AssetModel.h"
#import <CommonCrypto/CommonDigest.h>
#define CACHE_PATH  @"PFImagePickeController"
NSString * const PhotosChangeNotification = @"PFImagePickerToolUpdate";

@interface PFImagePickerTool()
//过滤的条件(图片,视频或者两者都包含)
@property(nonatomic,assign)PHAssetMediaType filter;
@property(nonatomic,assign)NSUInteger minumCount;
@property(nonatomic,assign)NSUInteger maxCount;
@property(nonatomic,strong)NSArray *collections;
@end
static int MAX = 20;
static NSMutableDictionary *selectedDic; //用于存放选定的模型
static NSMutableDictionary *imageDic;    //缓存加载的图片
static NSMutableDictionary *cacheDic;    //用于缓存模型
static PHPhotoLibrary *library;          //library对象
static PFImagePickerTool *shareTool;     //单例对象
static PHAssetCollection *yourCollection;//以你app名字命名的collection
static NSString *bundleName;
static NSMutableArray *tasks;
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
    [super initialize];
    //initialization
    selectedDic  = [NSMutableDictionary new];
    cacheDic     = [NSMutableDictionary new];
    imageDic     = [NSMutableDictionary new];
    tasks        = [NSMutableArray new];
    library      = [PHPhotoLibrary sharedPhotoLibrary];
    shareTool    = [[self alloc] init];
    bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleNameKey];
    shareTool.filter = PHAssetMediaTypeUnknown;
    shareTool.minumCount = 0;
    shareTool.maxCount   = 10;
    //regist observer
    [library registerChangeObserver:shareTool];
    //check authorization
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ( status == PHAuthorizationStatusAuthorized)
            {
                NSLog(@"成功授权!");
            }
            
        }];
    }
    [shareTool addObserver];
    
}
#pragma mark - static method
//设置资源的类型
+ (void)setFilterType:(PHAssetMediaType)type {
    shareTool.filter = type;
}
//获取已经选择的资源的数量
+ (NSInteger)selectedCount {
    return selectedDic.count;
}
//设置最大的可选数量
+ (void)setMaxCount:(NSUInteger)maxCount {
    shareTool.maxCount = maxCount;
}
//设置最小的可选数量
+ (void)setMinumCount:(NSUInteger)minumCount {
    shareTool.minumCount = minumCount;
}
//获取已选模型
+ (NSArray *)getSelectedAssetsArr {
    return [selectedDic allValues];
}
//清除缓存数据
+ (void)restoreAction {
    [selectedDic removeAllObjects];
    [cacheDic removeAllObjects];
    shareTool.minumCount = 0;
    shareTool.maxCount   = 10;
    shareTool.filter = PHAssetMediaTypeUnknown;
}
//判断是否可选(如果超过了最大可选数量就不可选)
+ (BOOL)canSelect {
    if (selectedDic.allValues.count > shareTool.maxCount) {
        return NO;
    }else{
        return YES;
    }
}

//检查选择的模型的个数是否符合大于minumCount并且小于maxCount
+(BOOL)checkSelectionStatus {
    BOOL status = NO;
    NSUInteger count = [selectedDic allValues].count;
    if (count >= shareTool.minumCount && count <= shareTool.maxCount) {
        status = YES;
    }
    return status;
}
//添加操作block(任务)
+ (void)addOperation:(operationBlock)operation {
    [shareTool addOperation:operation];
}
//遍历获取所有资源集合
+ (void)fetchCollectionsWithCompletion:(enumrationBlock)finish {
    [shareTool fetchCollectionWithCompletion:finish];
}
//获取集合下的资源
+(void)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish {
    [shareTool fetchAssetsWithAssetCollection:collection andCompletion:finish withCache:YES];
}
//针对于刷新数据的,可能图库资源发生改变,这时候要及时刷新展示的数据
+ (void)reloadAssetsWithCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish {
    [shareTool reloadAssetsWithCollection:collection andCompletion:finish];
}
// 操作模型(删除非选的,添加选择的)
+ (BOOL)storeSelectedOrUnselectedModel:(AssetModel *)model
{
    if (!model) {
        return NO;
    }
    if (model.isSelected) {
        NSString *key = model.asset.localIdentifier;
        [selectedDic setObject:model forKey:key];
        if (![self canSelect]) {
            [selectedDic removeObjectForKey:key];
            model.isSelected = NO;
            return NO;
        }
        return YES;
    }else{
        [selectedDic removeObjectForKey:model.asset.localIdentifier];
        return NO;
    }
    
}

void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
   operationBlock task = tasks.firstObject;
    if (task) {
        task();
        [tasks removeObject:task];
    }
}
//保留编辑的图片
+ (void)captureImage:(UIImage *)image handler:(void (^)(BOOL))completion {
    __block void (^handler)(BOOL) = [completion copy];
    [self excuteOnMainThreadWithOperation:^{
        [self requestAppCollectionWithHandler:^(PHAssetCollection *collection, bool success) {
            if (success) {
                
                [library performChanges:^{
                    PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    PHAssetCollectionChangeRequest *collectionChange = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    [collectionChange addAssets:@[request.placeholderForCreatedAsset]];
                    
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    [self excuteOnMainThreadWithOperation:^{
                        handler(success);
                        handler = nil;
                    }];
                    
                }];
            }
            else {
                [self excuteOnMainThreadWithOperation:^{
                    handler(NO);
                    handler = nil;
                }];
            }
        }];
        
    }];
}
//保存编辑过的View到指定的集合
+ (void)captureImageWithView:(UIView *)view andWriteToCollection:(PHAssetCollection *)collection withFinishBlock:(void (^)(NSError *, BOOL))completion {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self excuteOnGlobalThreadWithOperation:^{
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
        [library performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            
            PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            PHObjectPlaceholder *holder = [request placeholderForCreatedAsset];
            
            [collectionRequest addAssets:@[holder]];
            UIGraphicsEndImageContext();
            
        } completionHandler:^(BOOL success, NSError * _Nullable error)
         {
             completion(error,success);
         }];
        
    }];
    UIGraphicsEndImageContext();
}
//保留编辑的View
+ (void)captureImageWithView:(UIView *)view withFinishBlock:(void (^)(BOOL, UIImage *))completion {
    __block void (^handler)(BOOL, UIImage *) = [completion copy];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self requestAppCollectionWithHandler:^(PHAssetCollection *collection, bool success) {
        if (success) {
            
            [library performChanges:^{
                PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                PHAssetCollectionChangeRequest *collectionChange = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [collectionChange addAssets:@[request.placeholderForCreatedAsset]];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                [self excuteOnMainThreadWithOperation:^{
                    handler(success, image);
                    handler = nil;
                }];
                
            }];
        }
        else {
            [self excuteOnMainThreadWithOperation:^{
                handler(NO, image);
                handler = nil;
            }];
        }
    }];
    UIGraphicsEndImageContext();
}
//获取集合中资源的数量
+(void)requestCountOfAssetsInCollection:(PHAssetCollection *)collection completionHandler:(void (^)(NSUInteger, bool))completion {
    [shareTool requestCountOfAssetsInCollection:collection completionHandler:completion];
}
//获取准确尺寸的图片(会根据尺寸来裁剪)
+ (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size completionHandler:(void (^)(UIImage *, NSString *, BOOL))handler {
    [shareTool requestImageWithAsset:asset targetSize:size completionHandler:handler];
}
//快速获取图片(同步,不是原图)
+ (void)requestFastImageWithAsset:(PHAsset *)asset Handler:(void (^)(UIImage *, NSString *, BOOL))handler{
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth * 0.3, asset.pixelHeight * 0.3) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSLog(@"currentThread-------%@",[NSThread currentThread]);
        NSLog(@"size------%@",NSStringFromCGSize(result.size));
        NSString *uti = info[@"PHImageFileUTIKey"];
        handler(result, uti,YES);
    }];
}
//获取原图
+(void)requestImageWithAsset:(PHAsset *)asset completionHandler:(void (^)(UIImage *, NSString *, BOOL, NSString *))handler{
    [shareTool requestImageWithAsset:asset completionHandler:handler];
}
//获取集合的封面图片
+(void)requestPosterForAssetsCollection:(PHAssetCollection *)collection completionHandler:(void (^)(UIImage *, NSString *, BOOL))completion {
    [shareTool requestPosterForAssetsCollection:collection completionHandler:completion];
}
//选择完了之后遍历获取图片
+ (void)enumToGetImage:(NSArray<AssetModel *> *)models andHandler:(void (^)(BOOL *, NSUInteger, UIImage *, NSString *))completion {
    __block BOOL stop = NO;
    for (NSUInteger index = 0; index < models.count; index ++) {
        if (!stop) {
            AssetModel *model = models[index];
            if (!model.original) {//如果不是原图就请求低质量的图片
                [self requestFastImageWithAsset:model.asset Handler:^(UIImage *image, NSString *UTI, BOOL succees) {
                    if (succees) {
                        completion(&stop, index, image,UTI);
                    }
                }];
            }
            else {//请求原图
                [self requestImageWithAsset:model.asset completionHandler:^(UIImage *image, NSString *filePath, BOOL succees, NSString *UTI) {
                    if (succees) {
                        completion(&stop,index,image,UTI);
                    }
                }];
            }
            
        }
        else{
            break;
        }
    }
}
//在线程上执行操作
+ (void)excuteOperation:(void(^)())operation onQueue:(dispatch_queue_t)queue {
    if (queue == NULL) {
        return;
    }
    __block void(^handler)() = [operation copy];
    dispatch_async(queue, ^{
        handler();
        handler = nil;
    });
}
//在主队列上执行操作
+ (void)excuteOnMainThreadWithOperation:(void(^)())operation {
    [self excuteOperation:operation onQueue:dispatch_get_main_queue()];
}
//在全局队列上执行操作
+ (void)excuteOnGlobalThreadWithOperation:(void(^)())operation {
    [self excuteOperation:operation onQueue:dispatch_get_main_queue()];
}
//获取对应当前APP的资源集合(以应用的名字来命名的,如果没有就会创建一个)
+ (void)requestAppCollectionWithHandler:(void(^)(PHAssetCollection *, bool))completion{
    __block void(^handler)(PHAssetCollection *, bool) = [completion copy];
    if (yourCollection != nil) {
        handler(yourCollection,YES);
        handler = nil;
        return;
    }
    else {
        [shareTool.collections enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localizedTitle isEqualToString:bundleName]) {
                
                yourCollection = obj;
                [self excuteOnMainThreadWithOperation:^{
                    if (handler) {
                        handler(yourCollection,YES);
                        handler = nil;
                    }
                }];
                return ;
                *stop = YES;
            }
        }];
        //遍历完,如果没有就创建一个
        NSError *error = nil;
        __block NSString *identifier = nil;
        [library performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:bundleName];
            identifier = request.placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error];
        
        //返回处理结果
        if (error == nil && identifier != nil) {
            PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil];
            yourCollection = result.firstObject;
            if (handler) {
                handler(yourCollection,YES);
                handler = nil;
            }
            
        } else {
            if (handler) {
                handler(nil,NO);
                handler = nil;
            }
        }
    }
}
//获取唯一的标识符(MD5加密)
+ (NSString *)MD5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - dynamic method
- (void)addObserver {
    CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)shareTool,
        &CFRetain,
        &CFRelease,
        NULL
    };
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, YES, 0, &callBack, &context);
    CFRunLoopAddObserver(runloopRef, observerRef, kCFRunLoopCommonModes);
    CFRelease(observerRef);
}

- (void)addOperation:(operationBlock) operation {
    [tasks addObject:operation];
    if (tasks.count > MAX) {
        [tasks removeObject:tasks.firstObject];
    }
}
- (NSString *)getFilePathWithFilename:(NSString *)filename {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheDirectory = [path stringByAppendingPathComponent:CACHE_PATH];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = nil;
    if ([manager fileExistsAtPath:cacheDirectory isDirectory:&isDirectory]) { //如果存在这个文件
        if (isDirectory) {
            return [cacheDirectory stringByAppendingPathComponent:filename];
        }
    }
    else {
        if ([manager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            return [cacheDirectory stringByAppendingPathComponent:filename];
        }
    }
    return nil;
}
- (NSString *)getFileNameWithAsset:(PHAsset *)asset andSize:(CGSize)size {
    NSString *md5 = [PFImagePickerTool MD5:[NSString stringWithFormat:@"%@%@",NSStringFromCGSize(size), asset.localIdentifier]];
    return [NSString stringWithFormat:@"%@.png", md5];
}
- (CGSize)caculateSuitSizeWithTargetSize:(CGSize)targetSize {
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat suitWidth = maxWidth;
    CGFloat suitHeight= maxHeight;
    if (suitWidth * targetSize.height / targetSize.width < maxHeight) {
        suitHeight = suitWidth * targetSize.height / targetSize.width;
    }
    else {
        suitWidth = suitHeight * targetSize.width / targetSize.height;
    }
    return CGSizeMake(suitWidth, suitHeight);
}
- (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)size completionHandler:(void (^)(UIImage *, NSString *, BOOL))handler {
    CGSize suitSize = [self caculateSuitSizeWithTargetSize:size];
     NSString *filename = [self getFileNameWithAsset:asset andSize:suitSize]; //根据缓存取出
    __block void (^completion)(UIImage *, NSString *, BOOL) = [handler copy];
    if (asset == nil) {
        [PFImagePickerTool excuteOnMainThreadWithOperation:^{
            completion(nil, nil, NO);
            completion = nil;
        }];
    }
    else {
        UIImage *image = imageDic[filename];
        if (image) {
            [PFImagePickerTool excuteOnMainThreadWithOperation:^{
                completion(image, nil, YES);
                completion = nil;
            }];
            return;
        }
        else {
            [PFImagePickerTool excuteOnGlobalThreadWithOperation:^{
                CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
                CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
                CGRect cropRect = CGRectApplyAffineTransform(square,
                                                             CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                                        1.0 / asset.pixelHeight));
                
               
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.synchronous = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                options.normalizedCropRect = cropRect;
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:suitSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (filename) {
                        if (imageDic.allValues.count > MAX) {
                            [imageDic removeObjectForKey:imageDic.allKeys.firstObject];
                        }
                        [imageDic setObject:result forKey:filename];
                    }
                    [PFImagePickerTool excuteOnMainThreadWithOperation:^{
                        NSString *imagePath = [self filterFilePrefixWithFileURL:info[@"PHImageFileURLKey"]];
                        completion(result, imagePath, YES);
                            completion = nil;
                        
                    }];
                }];
            }];
        }
    }

}

- (void)saveDataWithImage:(UIImage *)image andFilename:(NSString *)fileName {
    
}
- (void)requestCountOfAssetsInCollection:(PHAssetCollection *)collection completionHandler:(void (^)(NSUInteger, bool))completion {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.includeHiddenAssets = YES;
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (result) {
            completion(result.count, YES);
        }
        else {
            completion(0, NO);
        }
}
- (NSString *)filterFilePrefixWithFileURL: (NSURL *)url {
    NSString *path = url.absoluteString;
    NSString *prefix = @"file://";
    if ([path hasPrefix:prefix]) {
        path = [path stringByReplacingOccurrencesOfString:prefix withString:@""];
    }
    return path;
}
- (NSString *)getPosterPathWithIdentifier:(NSString *)identifier {
    NSDictionary *dic = [cacheDic objectForKey:identifier];
    return [self filterFilePrefixWithFileURL:dic[@"PHImageFileURLKey"]];
}
- (NSString *)getUTIWithIdentifier:(NSString *)identifier {
    NSDictionary *dic = [cacheDic objectForKey:identifier];
    return  dic[@"PHImageFileUTIKey"];
}
- (void)requestImageWithAsset:(PHAsset *)asset completionHandler:(void (^)(UIImage *, NSString *, BOOL, NSString *))completion {
    if (asset == nil) {
        [PFImagePickerTool excuteOnMainThreadWithOperation:^{
            completion(nil, nil, NO,nil);
        }];
    }
    else {
        //根据路径来取出图片,之前已经请求过这个图片,保存了这个图片的路径
        NSString *path = [self getPosterPathWithIdentifier:asset.localIdentifier];
        NSString *UTI = [self getUTIWithIdentifier:asset.localIdentifier];
        NSString *prefix = @"file://";
        if ([path hasPrefix:prefix]) {
            path = [path substringFromIndex:prefix.length];
        }
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        if (image) {
            [PFImagePickerTool excuteOnMainThreadWithOperation:^{
                 completion(image, path, YES,UTI);
            }];
            return;

        }
        else {
            [PFImagePickerTool excuteOnGlobalThreadWithOperation:^{
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.synchronous = YES;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                
                [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    NSString *imagePath = [self filterFilePrefixWithFileURL:info[@"PHImageFileURLKey"]];
                    [PFImagePickerTool excuteOnMainThreadWithOperation:^{
                        if (info) {
                            [cacheDic setObject:info forKey:asset.localIdentifier];
                        }
                        completion(image,imagePath, YES, dataUTI);
                    }];
                }];

            }];
        }
    }
}
- (void)requestPosterForAssetsCollection:(PHAssetCollection *)collection completionHandler:(void (^)(UIImage *, NSString *, BOOL))completion {
    if (collection == nil) {
        [PFImagePickerTool excuteOnMainThreadWithOperation:^{
            completion(nil,nil,NO);
        }];
    }
    else {
        
        //request from cache
        NSString *posterPath = [self getPosterPathWithIdentifier:collection.localIdentifier];
        if (posterPath != nil) {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:posterPath];
            [PFImagePickerTool excuteOnMainThreadWithOperation:^{
              completion(image,posterPath, YES);
            }];
            return;
        }
        else {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            
            options.includeHiddenAssets = YES;
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            [result enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == 0) {
                    * stop = YES;
                    [PFImagePickerTool excuteOnGlobalThreadWithOperation:^{
                        PHImageRequestOptions *options = [PHImageRequestOptions new];
                        options.synchronous = YES;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                        
                        [[PHCachingImageManager defaultManager] requestImageDataForAsset:obj options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            NSString *imagePath = [self filterFilePrefixWithFileURL:info[@"PHImageFileURLKey"]];
                            [PFImagePickerTool excuteOnMainThreadWithOperation:^{
                                if (info) {
                                    [cacheDic setObject:info forKey:obj.localIdentifier];
                                }
                                completion(image, imagePath, YES);
                            }];
                        }];
                    }];
                }
            }];
      }
    }
}
- (void)fetchCollectionWithCompletion:(enumrationBlock)finish {
    
    PHFetchResult *assetsFetchResults = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    __block NSMutableArray *dataArr = [NSMutableArray new];
    __block enumrationBlock completion = finish;
    
    [assetsFetchResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *one = (PHAssetCollection *)obj;
            if ([one.localizedTitle isEqualToString:bundleName]) {
                yourCollection = one;
            }
        
            PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
            [dataArr addObject:assetCollection];
            
        }
        
    }];
    PHFetchResult *assetsFetchResults2 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [assetsFetchResults2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *one = (PHAssetCollection *)obj;
            if ([one.localizedTitle isEqualToString:bundleName]) {
                yourCollection = one;
            }

            PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
            [dataArr addObject:assetCollection];
            if (idx == assetsFetchResults2.count - 1 && completion != nil) {
                shareTool.collections = dataArr;
                completion(nil,dataArr);
                completion = nil;
            }
        }
        
    }];

}
- (void)fetchAssetsWithAssetCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish withCache:(BOOL)usingCache{
   
    if (!collection) {
        finish(nil,nil);
        return;
    }
    
    __block enumrationBlock completion = finish;
    
    if (usingCache) {//使用cache
    NSArray *cacheArr = [self fetchCachedDataWithCollection:collection];
    
    if (cacheArr && completion != nil) {
            completion(nil,cacheArr);
            completion = nil;
        return;
    }
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.includeHiddenAssets = YES;
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    __block NSMutableArray *dataArr = [NSMutableArray new];
    
    [result enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj && (obj.mediaType == self.filter || self.filter == PHAssetMediaTypeUnknown)) {
            AssetModel *model = nil;
            model = [selectedDic objectForKey:obj.localIdentifier];
            model.isSelected = YES;
            if (!model) {
                model = [[AssetModel alloc] init];
                model.asset = obj;
                model.collection = collection;
                model.mediaType = obj.mediaType;
                model.isSelected = NO;
            }
            [dataArr addObject:model];
        }
        
        if (idx == result.count - 1 && completion != nil) {
            
            NSString *key = [NSString stringWithFormat:@"%@%lu",collection.localIdentifier,(unsigned long)self.filter];
            cacheDic[key] = dataArr;
            completion(nil,dataArr);
        }
    }];
}
- (NSArray *)fetchCachedDataWithCollection:(PHAssetCollection *)colletion {
    NSArray *dataArr = [NSMutableArray new];
    dataArr = [cacheDic objectForKey: [NSString stringWithFormat:@"%@%lu",colletion.localIdentifier,(unsigned long)self.filter]];
    if (dataArr.count == 0 || dataArr == nil) {//there has no cached data
        return nil;
    }
    return dataArr;

}
- (void)removeCacheDataWithCollection:(PHAssetCollection *)collection {
    //移除
    [cacheDic removeObjectForKey: [NSString stringWithFormat:@"%@%lu",collection.localIdentifier,(unsigned long)self.filter]];

}
- (void)reloadAssetsWithCollection:(PHAssetCollection *)collection andCompletion:(enumrationBlock)finish {
    [shareTool fetchAssetsWithAssetCollection:collection andCompletion:finish withCache:NO];
}

#pragma mark - about notification
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [PFImagePickerTool excuteOnMainThreadWithOperation:^{
        for (PHAssetCollection *collection  in self.collections) {//遍历,查看是哪个相册变化了
            if ([changeInstance changeDetailsForObject:collection]) {
                [shareTool reloadAssetsWithCollection:collection andCompletion:nil];
                [shareTool removeCacheDataWithCollection:collection];
            }
        }

    }];
    [shareTool postChangeNotification];
}
-(void)postChangeNotification
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotosChangeNotification object:nil];
}
-(void)dealloc
{
    [library unregisterChangeObserver:shareTool];
}
@end
