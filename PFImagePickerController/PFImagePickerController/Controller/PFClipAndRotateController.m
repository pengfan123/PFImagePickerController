//
//  PFClipAndRotateController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFClipAndRotateController.h"
#import "PFImagePickerController.h"
#import "PFRotateAndClipView.h"
#import "PFIndicatorView.h"

#define SPACE 20
@interface PFClipAndRotateController ()
@property (strong, nonatomic)PFRotateAndClipView *editView;
@property (weak, nonatomic) IBOutlet UIButton *restoreBtn;
@property (strong, nonatomic)PFIndicatorView *indicatorView;

#pragma mark - IBAction
- (IBAction)cancelAction:(UIButton *)sender;
- (IBAction)restoreAction:(UIButton *)sender;
- (IBAction)rotateAction:(UIButton *)sender;
- (IBAction)clipAction:(UIButton *)sender;

@end

@implementation PFClipAndRotateController

- (void)viewDidLoad {
    [super viewDidLoad];
    _indicatorView = [PFIndicatorView getIndicatorView];
}

- (void)show {
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:self];
    
    _editView = [PFRotateAndClipView getViewWithImage:_originalImage];
    __weak typeof(self)WeakSelf = self;
    _editView.editBlock = ^(BOOL enabled) {
        WeakSelf.restoreBtn.enabled = enabled;
    };
    
    [_editView showInView:self.view];

    
}
- (void)dismiss {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - IBAction
- (IBAction)cancelAction:(UIButton *)sender {
    [self dismiss];
}

- (IBAction)restoreAction:(UIButton *)sender {
    [_editView restore];
}

- (IBAction)rotateAction:(id)sender {
    [_editView rotate];
}

- (IBAction)clipAction:(UIButton *)sender {
    [_indicatorView show];
    [_editView clipActionWithHandler:^(UIImage *result, PFRotateAndClipView *editView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_indicatorView hide];
             [self dismiss];
             [_pickerController pfImagePickerControllerDidClipImage:result];
        });
       
    }];
}
@end
