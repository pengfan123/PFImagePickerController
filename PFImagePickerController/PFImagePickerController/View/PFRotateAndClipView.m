//
//  PFRotateAndClipView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFRotateAndClipView.h"
#import "UICustomRecognizer.h"
#import "PFImagePickerTool.h"
#import "PFOverlay.h"
#define SPACE 10
#define VERTICAL_SPACE  ([UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width) * SPACE
@interface PFRotateAndClipView()
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (strong, nonatomic)PFOverlay *overlay;
@property (assign,nonatomic)CGRect rect;
@property (assign,nonatomic)BOOL hasEdited; //判断是否已经编辑过
@property (assign,nonatomic)int rotateNum;
#define RANGE 20 //定义的手势的正方形方向

@end
@implementation PFRotateAndClipView
- (void)setHasEdited:(BOOL)hasEdited {
    _hasEdited = hasEdited;
    _editBlock(hasEdited);
}
#pragma mark - life cycle
+ (instancetype)getViewWithImage:(UIImage *)image {
    PFRotateAndClipView *view = [[[NSBundle mainBundle] loadNibNamed:@"PFRotateAndClipView" owner:nil options:nil] lastObject];
    view.poster.image = image;
    view.originalImage = image;
    view.rotateNum = 0;
    [view setup];
    return view;
}
- (void)showInView:(UIView *)view {
    CATransition *trasition = [CATransition new];
    trasition.type = kCATransitionFade;
    trasition.duration = 0.5;
    [view addSubview:self];
    [self.layer addAnimation:trasition forKey:nil];
    self.hasEdited = NO;
    
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.frame = [self getSuitFrame];
    
    //添加手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    
    UICustomRecognizer *panGesture = [[UICustomRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    
    //添加layer
    _overlay = [[PFOverlay alloc] init];
    _overlay.backgroundColor = [UIColor clearColor].CGColor;
    [_overlay setNeedsDisplay];
    [self.layer addSublayer:_overlay];
    
    _poster.frame = self.bounds;
    [self updateOverlayWithRect:_poster.frame];
    
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    CGFloat scale = recognizer.scale;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        if ( scale < 1.0 && scale > 0.1) {
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
            CGRect rect = CGRectMake(width * (1 - scale) * 0.5, height * (1 - scale) * 0.5,self.bounds.size.width * scale , self.bounds.size.height * scale );
            [self updateOverlayWithRect:rect];
        }
    }
    else {
        [self updateMask];
    }
    
}

- (void)handlePanGesture:(UICustomRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged || recognizer.state == UIGestureRecognizerStateBegan) {
        [self updateOverlayWithRect:recognizer.finalRect];
    }
    else {
        [self updateMask];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hasEdited = YES;
    [super touchesBegan:touches withEvent:event];
    
}

- (void)updateMask {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_rect];
    CAShapeLayer *layer =  [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    self.poster.layer.mask = layer;
    CGFloat totalWid = 2 * _overlay.thinWid + _overlay.thickWid;
    _overlay.frame = CGRectMake(0, 0, _rect.size.width + totalWid, _rect.size.height + totalWid);
    _overlay.position = CGPointMake(CGRectGetMidX(_rect), CGRectGetMidY(_rect));
    [self setNeedsDisplay];
    [self processImage];
    
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        self.poster.layer.mask = nil;
    }
}
- (void)processImage {
    self.hidden = YES;
    CGFloat scale = self.poster.image.size.width / self.bounds.size.width;
    CGImageRef image = CGImageCreateWithImageInRect(self.poster.image.CGImage, CGRectMake(_rect.origin.x * scale, _rect.origin.y * scale, _rect.size.width * scale, _rect.size.height * scale));
    CGRect frame = [self convertRect:_rect toView:self.superview];
    UIImage *result = [UIImage imageWithCGImage:image];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
    imageView.frame = frame;
    [self.superview addSubview:imageView];
    imageView.frame = frame;
    imageView.transform = CGAffineTransformMakeRotation(M_PI_2 * _rotateNum);
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        imageView.center = CGPointMake(self.superview.frame.size.width * 0.5, self.superview.frame.size.height * 0.5);
        self.frame = imageView.frame;
        self.poster.frame = self.bounds;
        [self updateOverlayWithRect:self.bounds];
    } completion:^(BOOL finished) {
         self.poster.image = imageView.image;
         self.hidden = NO;
         [imageView removeFromSuperview];
         self.userInteractionEnabled = YES;
    }];

}
- (void)updateOverlayWithRect:(CGRect)rect {
    _rect = rect;
    CGFloat totalWid = 2 * _overlay.thinWid + 2 * _overlay.thickWid;
    _overlay.frame = CGRectMake(0, 0, _rect.size.width + totalWid , _rect.size.height + totalWid);
    _overlay.position = CGPointMake(CGRectGetMidX(_rect), CGRectGetMidY(_rect));
    [self setNeedsDisplay];
}
#pragma mark - public method
- (void)restore {
    _rotateNum = 0;
    _poster.image = _originalImage;
    self.transform = CGAffineTransformIdentity;
    self.frame = [self getSuitFrame];
    self.poster.frame = self.bounds;
    [self updateOverlayWithRect:self.bounds];
    [self showInView:self.superview];
}
- (void)clipActionWithHandler:(void (^)(UIImage *, PFRotateAndClipView *))completion {
    self.userInteractionEnabled = NO;
    [PFImagePickerTool captureImage:_poster.image handler:^(BOOL result) {
        if (result) {
            if (completion) {
                completion(_poster.image, self);
            }
        }
        else {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [view show];
        }
    }];

}

- (void)rotate {
    self.hasEdited = YES;
    _rotateNum++;
    _rotateNum = _rotateNum % 4;
    _overlay.hidden = YES;
    CGRect rect = [self getSuitFrame];
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI_2 * _rotateNum);
        self.frame = rect;
        _poster.frame = self.bounds;
        [self updateOverlayWithRect:self.bounds];
        
    } completion:^(BOOL finished) {
        _overlay.hidden = NO;
        self.userInteractionEnabled = YES;
    }];
}
- (CGRect)getSuitFrame {
    CGFloat pixelWid = 0;
    CGFloat pixelHei = 0;
    if (_rotateNum % 2 == 0 ) {
         pixelWid = _poster.image.size.width;
         pixelHei = _poster.image.size.height;
    }
    else {
        pixelWid = _poster.image.size.height;
        pixelHei = _poster.image.size.width;
    }
    
    CGFloat suitwid = [UIScreen mainScreen].bounds.size.width - 2 * SPACE;
    CGFloat suitHei = [UIScreen mainScreen].bounds.size.height - 2 * 49;
    CGRect suit = CGRectZero;
    if (suitwid * pixelHei / pixelWid < suitHei) {
        suit = CGRectMake(0, 0, suitwid, suitwid * pixelHei / pixelWid);
    }
    else {
        suit = CGRectMake(0, 0, suitHei * pixelWid / pixelHei, suitHei);
    }
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - suit.size.width) * 0.5;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - suit.size.height) * 0.5;
    suit = CGRectMake(x, y, suit.size.width, suit.size.height);
    return suit;

}
@end
