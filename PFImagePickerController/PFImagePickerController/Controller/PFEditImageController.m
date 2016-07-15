//
//  PFEditImageController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/18.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFEditImageController.h"
#import "PFImagePickerTool.h"
#import "EditALAssetModel.h"
#import "PFSelectView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import "PFDrawView.h"
@interface PFEditImageController ()<PFSelectViewDelegate>
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic)PFDrawView *draView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property(weak,nonatomic)PFSelectView *selectView;

- (IBAction)backAct:(id)sender;
- (IBAction)restoreAct:(id)sender;
- (IBAction)editAct:(id)sender;
- (IBAction)saveAct:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@end
@implementation PFEditImageController
#pragma mark - lazy loading
-(PFSelectView *)selectView{
    if (_selectView == nil) {
        UICollectionViewFlowLayout *layout = nil;
        PFSelectView *selectView = [[PFSelectView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        selectView.asset = self.asset;
        selectView.del = self;
        [self.view addSubview:selectView];
        _selectView = selectView;
    }
    return _selectView;
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setupUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
#pragma mark - private method
-(void)setupUI{
    self.title = @"编辑";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage]];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor redColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.imageView  = imageView;
    [self updateFrame];
    
    PFDrawView *drawView = [[PFDrawView alloc] initWithFrame:self.imageView.bounds];
    [self.imageView addSubview:drawView];
    _draView = drawView;
   
    //set image and add target
    [self setImage:[PFImagePickerTool loadImageWithName:@"save"] andAction:@selector(saveAct:) forButton:_saveButton];
    [self setImage:[PFImagePickerTool loadImageWithName:@"cancel"] andAction:@selector(restoreAct:) forButton:_cancelButton];
    [self setImage:[PFImagePickerTool loadImageWithName:@"edit"] andAction:@selector(editAct:) forButton:_editButton];
    [self setImage:[PFImagePickerTool loadImageWithName:@"back"] andAction:@selector(backAct:) forButton:_backBtn];
    [_backImageView setImage:[PFImagePickerTool loadImageWithName:@"blur"]];
    
}
-(void)updateFrame{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 50.0;
    CGFloat widScale =  width / self.imageView.frame.size.width;
    CGFloat heiScale = height / self.imageView.frame.size.height;
    if (widScale < heiScale) {
        CGRect finalFrame = CGRectMake(0, 0, width, self.imageView.frame.size.height * widScale);
        self.imageView.frame = finalFrame;
        self.imageView.center = CGPointMake(width * 0.5, height * 0.5);
    }else{
        CGRect finalFrame = CGRectMake(0, 0, self.imageView.frame.size.width * heiScale, height);
        self.imageView.frame = finalFrame;
        self.imageView.center = CGPointMake(width * 0.5, height * 0.5);
    }
}
-(void)setImage:(UIImage *)image andAction:(SEL)selector forButton:(UIButton *)button{
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - IBAction
- (void)backAct:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}
- (void)restoreAct:(id)sender {
    [_draView clearAction];
    self.imageView.image = [UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage];
}

- (void)editAct:(id)sender {
   [_draView clearAction];
   [UIView animateWithDuration:0.3 animations:^{
       _bottomBar.transform = CGAffineTransformMakeTranslation(0, 50);
   } completion:^(BOOL finished) {
       [self.selectView show];
   }];
}
- (void)saveAct:(id)sender {
    [PFImagePickerTool captureImageWithView:self.imageView andWriteToGroup:self.group withFinishBlock:^(NSError *error) {
        NSLog(@"error----------%@",error.localizedDescription);
        if (error) {
            [self showAlertWithMessage:error.localizedDescription andHideAfterDelay:0.8];
            return ;
            
        }
        [self showAlertWithMessage:@"保存成功" andHideAfterDelay:0.8];
        
    }];
}
-(void)showAlertWithMessage:(NSString *)message andHideAfterDelay:(NSTimeInterval)delay{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}
#pragma mark - PFSelectViewDelegate
-(void)PFSelectView:(PFSelectView *)selectView didSelectWithDataModel:(EditALAssetModel *)dataModel{
    [UIView animateWithDuration:0.3 animations:^{
        [self.selectView hide];
    } completion:^(BOOL finished) {
        _bottomBar.transform = CGAffineTransformMakeTranslation(0, 0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CIFilter *filter = [CIFilter filterWithName:dataModel.filterName];
            EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            NSDictionary *options = @{kCIContextWorkingColorSpace:[NSNull null]};
            CIContext *context = [CIContext contextWithEAGLContext:eaglContext options:options];
            [filter setValue:[CIImage imageWithCGImage:dataModel.asset.defaultRepresentation.fullResolutionImage] forKey:kCIInputImageKey];
            CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
            CGImageRef resultImage = [context createCGImage:outputImage fromRect:outputImage.extent];
            dataModel.editedImage = [UIImage imageWithCGImage:resultImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = dataModel.editedImage;
            });
        });

    }];
   
}
@end
