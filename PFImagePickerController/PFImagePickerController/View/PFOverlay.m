//
//  PFOverlay.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/10.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFOverlay.h"
#import <UIKit/UIKit.h>
@implementation PFOverlay
-(instancetype)init {
    if (self = [super init]) {
        self.thinWid = 1;
        self.thickWid = 5;
        self.lineColor = [UIColor whiteColor].CGColor;
    }
    return self;
}
- (void)setThinWid:(CGFloat)thinWid {
    _thinWid = thinWid;
    [self setNeedsDisplay];
}
- (void)setThickWid:(CGFloat)thickWid {
    _thickWid = thickWid;
    [self setNeedsDisplay];
}
- (void)setLineColor:(CGColorRef)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}
- (void)drawInContext:(CGContextRef)ctx {
    CGRect bounds = self.bounds;
    CGFloat totalWidth = _thinWid + _thickWid;
    //先画大的矩形
    CGRect fullRect = CGRectMake(_thickWid + 0.5 * _thinWid,_thickWid + 0.5 * _thinWid, bounds.size.width - 2 * totalWidth + _thinWid , bounds.size.height - 2 * totalWidth + _thinWid);
    CGFloat perWid = (bounds.size.width - 2 * totalWidth - _thinWid) / 3;
    CGFloat perHei = (bounds.size.height - 2 * totalWidth - _thinWid) / 3;
    
    CGFloat x1 = totalWidth + perWid + 0.5 * _thinWid;
    CGFloat x2 = x1 + _thinWid + perWid +  _thinWid;
    CGFloat y1 = totalWidth + perHei +  0.5 * _thinWid;
    CGFloat y2 = y1 + _thinWid + perHei + _thinWid;
    
    
    //开始画线 纵向的线
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:fullRect];
    [path moveToPoint:CGPointMake(x1, totalWidth)];
    [path addLineToPoint:CGPointMake(x1, bounds.size.height - totalWidth)];
    [path moveToPoint:CGPointMake(x2, totalWidth)];
    [path addLineToPoint:CGPointMake(x2, bounds.size.height - totalWidth)];
    
    //横向的线条
    [path moveToPoint:CGPointMake(totalWidth, y1)];
    [path addLineToPoint:CGPointMake(bounds.size.width - _thickWid, y1)];
    [path moveToPoint:CGPointMake(totalWidth, y2)];
    [path addLineToPoint:CGPointMake(bounds.size.width - _thickWid, y2)];
    
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetStrokeColorWithColor(ctx, _lineColor);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(0.5 * _thickWid, 10)];
    [path1 addLineToPoint:CGPointMake(0.5 * _thickWid, 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(_thickWid + 10, 0.5 * _thickWid)];
    
    [path1 moveToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid - 10, 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid, 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid, 0.5 * _thickWid + 10)];
    
    [path1 moveToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid, bounds.size.height - 0.5 * _thickWid - 10)];
    [path1 addLineToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid, bounds.size.height - 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(bounds.size.width - 0.5 * _thickWid - 10, bounds.size.height - 0.5 * _thickWid)];
    
    [path1 moveToPoint:CGPointMake(0.5 * _thickWid + 10, bounds.size.height - 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(0.5 * _thickWid,  bounds.size.height - 0.5 * _thickWid)];
    [path1 addLineToPoint:CGPointMake(0.5 * _thickWid,  bounds.size.height - 0.5 * _thickWid - 10)];
    
    CGContextAddPath(ctx, path1.CGPath);
    CGContextSetLineWidth(ctx, _thickWid);
    CGContextSetStrokeColorWithColor(ctx,_lineColor);
    CGContextStrokePath(ctx);
}
@end
