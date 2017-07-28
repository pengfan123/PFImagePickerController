//
//  PFOverlay.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PFOverlay : CALayer
@property (nonatomic,assign)CGFloat thinWid; /*细线的宽度,默认为1*/
@property (nonatomic,assign)CGFloat thickWid;/*细线的宽度,默认为2*/
@property (nonatomic,assign)CGColorRef lineColor;/*线条的颜色,默认为白色*/
@end
