//
//  PFPaintView.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/21.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, PFPaintViewState) {
    paintViewStateBeginTouch = 0,
    paintViewStateBeginMove,
    paintViewStateEndTouch,
};
@class PFPaintView;
@protocol PFPaintViewDelegate <NSObject>

@optional

//开始画
- (void)PFPaintView:(PFPaintView *)paintView beginToPaint:(PFPaintViewState)state;

//结束和正在绘画的状态
- (void)PFPaintView:(PFPaintView *)paintView changeToPaint:(PFPaintViewState)state;
- (void)PFPaintView:(PFPaintView *)paintView beginToHiddenOrShow:(BOOL)hidden;

@end
@interface PFPaintView : UIView <CALayerDelegate>
-(void)clearAction;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)UIColor *lineColor;
- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, weak)id <PFPaintViewDelegate> delegate;
@property (nonatomic,copy)NSString *infoText;
@end
