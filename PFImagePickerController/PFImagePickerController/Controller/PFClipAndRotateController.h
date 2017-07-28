//
//  PFClipAndRotateController.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFImagePickerController;
@interface PFClipAndRotateController : UIViewController
@property (nonatomic,strong)UIImage *originalImage; //初始的图片
@property (nonatomic,weak)PFImagePickerController *pickerController;
- (void)show; //展示
@end
