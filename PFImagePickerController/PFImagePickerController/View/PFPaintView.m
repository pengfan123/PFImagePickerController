//
//  PFPaintView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/21.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFPaintView.h"
@interface PFPaintView()
//记录当前的点
@property(nonatomic,strong)NSMutableArray *pointArr;
@property (nonatomic,strong)UIImageView *poster;
@property(nonatomic,assign)CGMutablePathRef ref;
@property (nonatomic,strong)UILabel *textLabel;

@end
@implementation PFPaintView

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
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setInfoText:(NSString *)infoText {
    _infoText = infoText;
    _textLabel.text = _infoText;
    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
}
- (void)textLabelHandlePanGesture:(UIPanGestureRecognizer *)recognizer {
    CGRect frame = _textLabel.frame;
    CGPoint translattion = [recognizer translationInView:recognizer.view];
    CGPoint center = _textLabel.center;
    center.x  += translattion.x;
    center.y  += translattion.y;
    _textLabel.center = center;
    
    if (!CGRectContainsRect(self.bounds, _textLabel.frame)) {//超出边界不做响应
        _textLabel.frame = frame;
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}
- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    _textLabel.textColor = _lineColor;
    [self setNeedsDisplay];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(_textLabel.frame, point)) {
        return _textLabel;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}
-(void)setup{
    _poster = [[UIImageView alloc] initWithFrame:self.bounds];
    _poster.contentMode = UIViewContentModeScaleAspectFit;
    //[self addSubview:_poster];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    
    _lineColor = [UIColor orangeColor];
    
    //add label
    _textLabel =  [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:20];
    _textLabel.textColor = _lineColor;
    [self addSubview:_textLabel];
    
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelHandlePanGesture:)];
    [_textLabel addGestureRecognizer:panGesture2];
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
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(PFPaintView:beginToPaint:)]) {
            [self.delegate PFPaintView:self beginToPaint:paintViewStateBeginTouch];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(PFPaintView:changeToPaint:)]) {
            [self.delegate PFPaintView:self changeToPaint:paintViewStateBeginMove];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(PFPaintView:changeToPaint:)]) {
            [self.delegate PFPaintView:self changeToPaint:paintViewStateEndTouch];
        }
    }
}
-(void)clearAction{
    CFRelease(_ref);
    _ref = NULL;
    [_pointArr removeAllObjects];
    [self setNeedsDisplay];
}
-(void)dealloc{
    CFRelease(_ref);
    [_pointArr removeAllObjects];
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [_image drawInRect:rect];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 5);
    CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
    CGContextAddPath(ctx, self.ref);
    CGContextStrokePath(ctx);
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if ([self.delegate respondsToSelector:@selector(PFPaintView:beginToHiddenOrShow:)]) {
        [self.delegate PFPaintView:self beginToHiddenOrShow:hidden];
    }
}
- (void)setImage:(UIImage *)image {
    _image = image;
    _poster.image = _image;
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 98);
    self.frame =  [self getSuitFrameWithMaxSize:size];
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    _poster.frame = self.bounds;
    [self setNeedsDisplay];
}
- (CGRect)getSuitFrameWithMaxSize:(CGSize)maxSize {
    if (_poster.image.size.width == 0 || _poster.image.size.height == 0) {
        return CGRectZero;
    }
    CGFloat pixelWid = _poster.image.size.width;
    CGFloat pixelHei = _poster.image.size.height;
    
    CGFloat suitwid = maxSize.width;
    CGFloat suitHei = maxSize.height;
    
    CGRect suit = CGRectZero;
    if (suitwid * pixelHei / pixelWid < suitHei) {
        suit = CGRectMake(0, 0, suitwid, suitwid * pixelHei / pixelWid);
    }
    else {
        suit = CGRectMake(0, 0, suitHei * pixelWid / pixelHei, suitHei);
    }
    suit = CGRectMake(0, 0, suit.size.width, suit.size.height);
    return suit;
    
}

@end
