//
//  UICustomRecognizer.m
//  自定义手势
//
//  Created by 软件开发部2 on 2017/7/17.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "UICustomRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
typedef enum : NSUInteger {
    upLeft = 0,
    upRight,
    downLeft,
    downRight,
    none
} cornerStyle;
@interface UICustomRecognizer()
@property(nonatomic,assign)CGPoint cornerPoint; /* 手指所在的点的对角,确定围成矩形 */
@property (nonatomic,assign)cornerStyle corner;
@end
@implementation UICustomRecognizer
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _finalRect = self.view.bounds;
    [self validateWithTouches:touches.allObjects];
}
- (void)validateWithTouches:(NSArray *)touches {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    //一个手指,一个点击
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
    }
    else {
        for ( UITouch *touch in touches) {
            if (touch.tapCount != 1) {
                self.state = UIGestureRecognizerStateFailed;
                return;
            }
            else {
                CGPoint point = [self locationInView:self.view];
                CGRect rect1 = CGRectMake(0, 0, _range,_range);
                CGRect rect2 = CGRectMake(width - _range, 0, _range, _range);
                CGRect rect3 = CGRectMake(width - _range, height - _range, _range, _range);
                CGRect rect4 = CGRectMake(0, height - _range, _range, _range);
                BOOL flag = YES;
                if (CGRectContainsPoint(rect1, point)) {
                    _cornerPoint = CGPointMake(width,height);
                    _corner = upLeft;
                }
                else if (CGRectContainsPoint(rect2, point)) {
                    _cornerPoint = CGPointMake(0, height);
                    _corner = upRight;
                    
                }
                else if (CGRectContainsPoint(rect3, point)) {
                    _cornerPoint = CGPointMake(0, 0);
                    _corner = downRight;

                }
                else if (CGRectContainsPoint(rect4, point)) {
                    _cornerPoint = CGPointMake(width, 0);
                    _corner = downLeft;

                }
                else {
                    flag = NO;
                    _corner = none;
                }
                self.state = flag ? UIGestureRecognizerStateBegan : UIGestureRecognizerStateFailed ;
            }
        }
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
        //自动内部会自动改变状态为move
    [super touchesMoved:touches withEvent:event];
    CGPoint location = [touch locationInView:self.view];
    CGPoint suit = CGPointMake(MIN(location.x,self.view.frame.size.width), MIN(location.y, self.view.frame.size.height));
    suit.x = suit.x > 0? suit.x : 0;
    suit.y = suit.y > 0? suit.y : 0;
    switch (_corner) {
        case upLeft: //左上角
            _finalRect = CGRectMake(suit.x, suit.y, _cornerPoint.x - suit.x, _cornerPoint.y - suit.y);
            break;
        case upRight: //右上角
             _finalRect = CGRectMake(0, suit.y, suit.x, _cornerPoint.y - suit.y);
            break;
        case downRight: //右下角
            _finalRect = CGRectMake(0, 0, suit.x, suit.y);
            break;
        case downLeft: //左下角
            _finalRect = CGRectMake(suit.x, 0, _cornerPoint.x - suit.x, suit.y);
            break;
        default:
            break;
    }
    self.state = UIGestureRecognizerStateBegan;
 }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
    self.state = UIGestureRecognizerStateRecognized;
    [self reset];
}


- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.range = 50;
        self.cornerPoint = CGPointZero;
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        self.range = 50;
        self.cornerPoint = CGPointZero;
    }
    return self;
}
@end
