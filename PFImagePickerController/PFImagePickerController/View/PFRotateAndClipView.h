//
//  PFRotateAndClipView.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFRotateAndClipView;
@interface PFRotateAndClipView : UIView
@property (strong, nonatomic)UIImage *originalImage;//原始图片
@property (copy, nonatomic)void (^editBlock)(BOOL enabled); //通知控制器来修改还原按钮的enabled
+ (instancetype)getViewWithImage:(UIImage*)image;
- (void)showInView: (UIView *)view;
- (void)restore;
- (void)clipActionWithHandler:(void(^)(UIImage *result, PFRotateAndClipView *editView))completion;
- (void)rotate;
@end
