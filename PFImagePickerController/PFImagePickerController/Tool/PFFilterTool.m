//
//  PFFilterTool.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/21.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFFilterTool.h"
#import "PFFilterOperation.h"
static  CIContext *context;
static  NSOperationQueue *queue;
static NSMutableDictionary *operationDic;
static NSArray *filters;

@implementation PFFilterTool
+ (void)load {
    [super load];
    filters =  [NSArray arrayWithObjects:@"CIColorMonochrome",@"CIVignette",@"CISepiaTone",@"CIPhotoEffectFade",@"CIFalseColor",@"CILinearToSRGBToneCurve",@"CIVibrance",@"CIColorPolynomial",@"CISRGBToneCurveToLinear",@"CITemperatureAndTint",@"CICircularScreen",@"CICMYKHalftone",@"CIDotScreen",nil];
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{kCIContextWorkingColorSpace : [NSNull null]};
    context = [CIContext contextWithEAGLContext:eaglContext options:options];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3;
    operationDic = [NSMutableDictionary new];
}
+ (UIImage *)renderWithRawImage:(UIImage *)rawImage andFilter:(NSString *)filter {
    return nil;
}
+ (void)cancelRender {
    [queue cancelAllOperations];
}
+ (void)filterOperationWithImage:(UIImage *)image andFilter:(NSString *)filter andDisplayView:(UIImageView *)view andIdetifier:(NSString *)identifier{
    PFFilterOperation *operation = operationDic[identifier];
    if (operation == nil || view != operation.imageView) {
        [operation cancel];
        operation = [PFFilterOperation blockOperationWithBlock:^{
            CIFilter *filterObj = [CIFilter filterWithName:filter];
            [filterObj setValue:[CIImage imageWithCGImage:image.CGImage] forKey:kCIInputImageKey];
            CIImage *outputImage = [filterObj valueForKey:kCIOutputImageKey];
            CGImageRef resultImage = [context createCGImage:outputImage fromRect:outputImage.extent];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultImage) {
                    view.image = [UIImage imageWithCGImage:resultImage];
                }
                [operationDic removeObjectForKey:identifier];
            });
        }];
        operation.imageView =  view;
        [operationDic setObject:operation forKey:identifier];
        [queue addOperation:operation];
        
    }
}
+ (NSArray *)getFilters {
    return filters;
}
@end
