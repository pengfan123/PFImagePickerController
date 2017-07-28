//
//  PFInputView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/27.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFInputView.h"
#import "PFColorSelectionBar.h"

@implementation PFInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 60);
        [self setupUI];
        [self addObserver];
    }
    return self;
}
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    UITextField *inputFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.5)];
    inputFiled.backgroundColor = [UIColor clearColor];
    inputFiled.borderStyle = UITextBorderStyleNone;
    [self addSubview:inputFiled];
    _inputField = inputFiled;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inputFiled.frame) - 0.5, self.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), 50, self.frame.size.height * 0.5)];
    [sureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self addSubview:sureBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, CGRectGetMaxY(line.frame), 50, self.frame.size.height * 0.5)];
    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self addSubview:cancelBtn];
    
}
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _inputField.textColor =  _textColor;
}

- (void)sureAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(inputText:withInputView:)]) {
            [self.delegate inputText:_inputField.text withInputView:self];
    }
    [self.inputField resignFirstResponder];
}
- (void)cancelAction:(UIButton *)sender {
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(cancelWithInputView:)]) {
        [self.delegate cancelWithInputView:self];
    }
}
-(void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSLog(@"notification-------%@",notification.userInfo);
    NSDictionary *info = notification.userInfo;
    CGRect beginRect = [info[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect endRect = [info[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    double duration = [info[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    NSUInteger animationOption = [info[@"UIKeyboardAnimationCurveUserInfoKey"] unsignedLongValue];
    if (endRect.origin.y < beginRect.origin.y) {//键盘弹出
        _colorBar.hidden = NO;
        self.hidden = NO;
        CGRect frame1= CGRectMake(0, endRect.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        CGRect frame2 = CGRectMake(0, CGRectGetMinY(frame1) - _colorBar.frame.size.height, _colorBar.frame.size.width, _colorBar.frame.size.height);
        [UIView animateWithDuration:duration delay:0 options:animationOption animations:^{
            self.frame = frame1;
            _colorBar.frame = frame2;
        } completion:nil];
    }
    else {
       
        CGRect frame1= CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, self.frame.size.height);
        CGRect frame2 = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - _colorBar.frame.size.height - 49, _colorBar.frame.size.width, _colorBar.frame.size.height);
        [UIView animateWithDuration:duration delay:0 options:animationOption animations:^{
            self.frame = frame1;
            _colorBar.frame = frame2;
        } completion:^(BOOL finished) {
            _colorBar.hidden = YES;
            self.hidden = YES;
        }];
    }
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
@end
