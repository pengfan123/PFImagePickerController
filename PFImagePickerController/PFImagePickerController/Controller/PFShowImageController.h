//
//  PFShowImageController.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/6.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFImagePickerController;
@interface PFShowImageController : UIViewController
@property(nonatomic,strong)NSArray *datas; //存放模型数据
@property(nonatomic,assign)NSInteger currentIndex; //当前显示的模型的序列
@property(nonatomic,weak)PFImagePickerController *imagePickerController;
@end
