//
//  PFEditImageController.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/18.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAsset;
@class ALAssetsGroup;
@interface PFEditImageController : UIViewController
@property(nonatomic,strong)ALAsset *asset;
@property(nonatomic,strong)ALAssetsGroup *group;
@end
