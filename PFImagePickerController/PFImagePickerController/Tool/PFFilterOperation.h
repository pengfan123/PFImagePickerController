//
//  PFFilterOperation.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/21.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PFFilterOperation : NSBlockOperation
@property(nonatomic,weak)UIImageView *imageView;
@end
