//
//  PFColorCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/20.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFColorCell.h"

@implementation PFColorCell

- (void)setColor:(UIColor *)color {
    _color = color;
    self.contentView.backgroundColor = _color;
}
@end
