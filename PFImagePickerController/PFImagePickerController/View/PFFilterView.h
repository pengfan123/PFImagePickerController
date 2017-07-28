//
//  PFFilterView.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/26.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssetModel, PFFilterView;
@protocol PFFilterViewDelegate <NSObject>
@optional
- (void)clickCancelWithFilterView:(PFFilterView *)filterView;

- (void)clickSureWithFilterView:(PFFilterView *)filterView andFilter:(NSString *)filter;

- (void)clickOneWithFilterView:(PFFilterView *)filterView andFilter:(NSString *)filter;

@end
//用于处理滤镜选择的视图
@interface PFFilterView : UIView
@property(nonatomic,strong)AssetModel *data;
@property (nonatomic,weak) id<PFFilterViewDelegate>delegate;
@end
