//
//  PFColorSelectionBar.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/20.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFColorSelectionBar : UIView
- (instancetype)initWithFrame:(CGRect)frame;
- (void)showOrHide:(BOOL)isShow;
@property (nonatomic,copy)void(^operationBlock)(BOOL restore, UIColor *selectecColor);
@end
