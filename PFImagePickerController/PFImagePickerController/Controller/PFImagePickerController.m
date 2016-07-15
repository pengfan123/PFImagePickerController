//
//  PFImagePickerController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFImagePickerController.h"
#import "PFImagePickerTool.h"
#import "PFAlbumsController.h"
@interface PFImagePickerController ()

@end

@implementation PFImagePickerController
#pragma mark - life cycle
-(instancetype)init{
    if (self = [super init]) {
        [self setupViewController];
    }
    return self;
}
-(void)setupViewController{
    PFAlbumsController *albumsController = [[PFAlbumsController alloc] init];
    albumsController.imagePickerController = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:albumsController];
    [self addChildViewController:navi];
    navi.view.frame = self.view.bounds;
    [self.view addSubview:navi.view];
    [navi didMoveToParentViewController:self];
}
#pragma mark - extern method
//介绍选择
-(void)pfImagePickerControllerDidFinishPickImage{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(PFImagePickerController:didFinshSelectedWithAssets:)]) {
            NSArray *dataArr = [PFImagePickerTool getSelectedAssetsArr];
            [self.delegate PFImagePickerController:self didFinshSelectedWithAssets:dataArr];
            [PFImagePickerTool clearAction];
        }
    }];
}
//取消选择
-(void)pfImagePickerControllerDidCancelPickImage{
    [self dismissViewControllerAnimated:YES completion:^{
        [PFImagePickerTool clearAction];
        if ([self.delegate respondsToSelector:@selector(PFImagePickerControllerDidCancel:)]) {
            [self.delegate PFImagePickerControllerDidCancel:self];
        }
        
    }];
}
@end
