//
//  ALAssetModel.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "ALAssetModel.h"

@implementation ALAssetModel
-(void)setTypeString:(NSString *)typeString{
    _typeString = typeString;
    if ([_typeString isEqualToString:ALAssetTypePhoto]) {
        self.type = PictureStyle;
    }else{
        self.type = MovieStyle;
    }
}
@end
