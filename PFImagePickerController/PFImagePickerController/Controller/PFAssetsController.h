//
//  PFAssetsController.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFImagePickerController;
@class PHAssetCollection;
@interface PFAssetsController : UIViewController
@property(nonatomic,weak)PFImagePickerController *imagePickerController;
@property(nonatomic,strong)PHAssetCollection *collection;
@end
