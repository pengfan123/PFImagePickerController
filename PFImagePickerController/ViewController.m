//
//  ViewController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "ViewController.h"
#import "PFImagePickerController.h"
@interface ViewController ()<PFImagePickerControllerDelegate>

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
    NSLog(@"assets------%@",assets);
}
@end
