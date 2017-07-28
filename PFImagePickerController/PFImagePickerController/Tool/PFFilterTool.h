//
//  PFFilterTool.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/21.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
@interface PFFilterTool : NSObject
+ (UIImage *)renderWithRawImage:(UIImage *)rawImage andFilter:(NSString *)filter;
+ (void)cancelRender;
+ (void)filterOperationWithImage:(UIImage *)image andFilter:(NSString *)filter andDisplayView:(UIImageView *)view andIdetifier:(NSString *)identifier;
+ (NSArray *)getFilters;

@end
