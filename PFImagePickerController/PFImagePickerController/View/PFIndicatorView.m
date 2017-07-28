//
//  PFIndicatorView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/28.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFIndicatorView.h"

@implementation PFIndicatorView
+ (instancetype)getIndicatorView {
    PFIndicatorView *indicatorView = [[PFIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    indicatorView.backgroundColor = [UIColor clearColor];
    [indicatorView setupUI];
    return indicatorView;
}

- (void)setupUI {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:effect];
    view.frame = CGRectMake((self.frame.size.width - 100) * 0.5, (self.frame.size.height - 100) * 0.5, 100, 100);
    [self addSubview:view];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    [view.contentView addSubview:indicator];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    indicator.center = CGPointMake(view.contentView.frame.size.width * 0.5, view.contentView.frame.size.height * 0.5);
}
- (void)show {
    self.hidden = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
- (void)hide {
    self.hidden = YES;
}
@end
