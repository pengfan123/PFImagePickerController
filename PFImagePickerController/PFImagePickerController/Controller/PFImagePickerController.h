//
//  PFImagePickerController.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFImagePickerController;
@protocol PFImagePickerControllerDelegate <NSObject>
@optional
/**
 *  选完图片
 *
 *  @param imagePickerController PFImagePickerController对象
 *  @param assets                asset模型数组
 */
-(void)PFImagePickerController:(PFImagePickerController *)imagePickerController didFinshSelectedWithAssets:(NSArray *)assets;
/**
 *  获取图片失败
 *
 *  @param imagePickerController PFImagePickerController对象
 *  @param error                 错误
 */
-(void)PFImagePickerController:(PFImagePickerController *)imagePickerController didFailedWithError:(NSError *)error;
/**
 *  取消选择图片
 *
 *  @param imagePickerController PFImagePickerController对象
 */
-(void)PFImagePickerControllerDidCancel:(PFImagePickerController *)imagePickerController;


@end
@interface PFImagePickerController : UIViewController
@property(nonatomic,weak)id<PFImagePickerControllerDelegate>delegate;
//完成多选
-(void)pfImagePickerControllerDidFinishPickImage;
//取消多选
-(void)pfImagePickerControllerDidCancelPickImage;
@end
