//
//  UICustomRecognizer.h
//  自定义手势
//
//  Created by 软件开发部2 on 2017/7/17.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICustomRecognizer : UIPanGestureRecognizer
@property (nonatomic,assign)CGFloat range; /* default is 10 */
@property (nonatomic, readonly, assign)CGRect finalRect; //经过计算最后的矩形
@end
