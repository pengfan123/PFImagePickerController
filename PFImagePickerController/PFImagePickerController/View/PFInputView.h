//
//  PFInputView.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/27.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFColorSelectionBar, PFInputView;
@protocol PFInputViewDelegate <NSObject>

@optional
- (void)inputText:(NSString *)text withInputView:(PFInputView *)inputView;
- (void)cancelWithInputView:(PFInputView *)input;
@end
@interface PFInputView : UIView
@property (nonatomic,readonly)UITextField *inputField;
@property (nonatomic,weak)PFColorSelectionBar *colorBar;
@property (nonatomic,strong)UIColor *textColor; //文字颜色
@property (nonatomic,weak)id <PFInputViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
@end
