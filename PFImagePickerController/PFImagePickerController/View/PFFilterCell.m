//
//  PFFilterCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/26.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFFilterCell.h"
#import "PFFilterTool.h"

@interface PFFilterCell()
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (strong, nonatomic)UIImage *image;
@property (weak, nonatomic)UIView *selectedView;

@end

@implementation PFFilterCell
- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *backView = [[UIView alloc] init];
    backView.layer.borderColor = [UIColor redColor].CGColor;
    backView.layer.borderWidth = 2;
    [self.contentView addSubview:backView];
    _selectedView = backView;
    _selectedView.hidden = YES;
    _poster.backgroundColor = [UIColor lightGrayColor];
}
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath andFilter:(NSString *)filter andImage:(UIImage *)image{
    static NSString *identifier = @"PFFilterCell";
    self = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    _poster.image = nil;
    self.filter = filter;
    self.image = image;
    [self render];
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    _selectedView.frame = self.bounds;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _selectedView.hidden = !selected;
}
- (void)render {
    if (self.image && self.filter) {
        [PFFilterTool filterOperationWithImage:_image andFilter:_filter andDisplayView:_poster andIdetifier:_filter];
    }
}
@end
