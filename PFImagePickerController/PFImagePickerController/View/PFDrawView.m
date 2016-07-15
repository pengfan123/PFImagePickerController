//
//  PFDrawView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/18.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFDrawView.h"
#import "PFImagePickerTool.h"
@interface PFDrawView()
@property(nonatomic,assign)CGMutablePathRef ref;
//记录当前的点
@property(nonatomic,strong)NSMutableArray *pointArr;
@end
@implementation PFDrawView
#pragma mark - lazy loading 
-(NSMutableArray *)pointArr{
    if (_pointArr == nil) {
        _pointArr = [NSMutableArray new];
    }
    return _pointArr;
}
-(CGMutablePathRef)ref{
    if (_ref == NULL) {
        _ref = CGPathCreateMutable();
    }
    return _ref;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setup];
        
    }
    return self;
}
-(void)setup{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
}
-(void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:recognizer.view];
    [self.pointArr addObject:[NSValue valueWithCGPoint:point]];
    if (self.pointArr.count == 1) {
        CGPathMoveToPoint(self.ref, NULL, point.x, point.y);
    }else{
        CGPathAddLineToPoint(self.ref, NULL, point.x, point.y);
    }
    [self setNeedsDisplay];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.pointArr removeAllObjects];
    }
}
-(void)clearAction{
    CFRelease(_ref);
    _ref = NULL;
    [_pointArr removeAllObjects];
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 10);
    CGContextSetStrokeColorWithColor(ctx, [PFImagePickerTool shadowColor].CGColor);
    CGContextAddPath(ctx, self.ref);
    CGContextStrokePath(ctx);
}
-(void)dealloc{
    CFRelease(_ref);
    [_pointArr removeAllObjects];
}
@end
