//
//  ViewController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "ViewController.h"
#import "PFImagePickerController.h"
#import "PFImagePickerTool.h"
@interface ViewController ()<PFImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *poster;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    PFImagePickerController *imagePicekerController = [[PFImagePickerController alloc] init];
    imagePicekerController.delegate = self;
    [self presentViewController:imagePicekerController animated:YES completion:nil];
}
-(void)PFImagePickerController:(PFImagePickerController *)imagePickerController didFinshSelectedWithAssets:(NSArray *)assets{
    [PFImagePickerTool enumToGetImage:assets andHandler:^(BOOL *stop, NSUInteger index, UIImage *result, NSString *UTI) {
         NSLog(@"index-----%lu",index);
    }];
}
-(void)PFImagePickerControllerDidClip:(PFImagePickerController *)imagePickerController andResultImage:(UIImage *)result {
    _poster.image = result;
    NSLog(@"result-----");
    
}
@end
