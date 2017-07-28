//
//  PFFilterView.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/26.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFFilterView.h"
#import "PFFilterCell.h"
#import "PFImagePickerTool.h"
#import "AssetModel.h"
#import "PFFilterTool.h"
@interface PFFilterView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *selectionView;
@property (nonatomic,strong) NSArray *filters;
@property (nonatomic,strong)UIImage *originImage;
@property (nonatomic,weak)UIButton *sureBtn;
@property (nonatomic,weak)UIButton *cancelBtn;
@property (nonatomic,copy)NSString *filter;

@end
@implementation PFFilterView {
    PFFilterCell *currentCell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 10;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _selectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height * 2 / 3) collectionViewLayout:flowLayout];
    _selectionView.delegate = self;
    _selectionView.dataSource = self;
    [_selectionView registerNib:[UINib nibWithNibName:@"PFFilterCell" bundle:nil] forCellWithReuseIdentifier:@"PFFilterCell"];
    [self addSubview:_selectionView];
    _selectionView.backgroundColor = [UIColor clearColor];
    self.filters = [PFFilterTool getFilters];
    [_selectionView reloadData];
    
    //add button
    _cancelBtn = [self getButtonWithFrame:CGRectMake(0, CGRectGetMaxY(_selectionView.frame), width * 0.2, height * 1  / 3) andSelector:@selector(cancelBtnOnClick:) andTitle:@"取消"];
                                        
    _sureBtn = [self getButtonWithFrame:CGRectMake(width * 0.8, CGRectGetMaxY(_selectionView.frame), width * 0.2,  height * 1  / 3) andSelector:@selector(sureBtnOnClick:) andTitle:@"确定"];
    
}

//点击取消按钮
- (void)cancelBtnOnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickCancelWithFilterView:)]) {
        [self.delegate clickCancelWithFilterView:self];
    }
}

//点击确定按钮
- (void)sureBtnOnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickSureWithFilterView:andFilter:)]) {
        [self.delegate clickSureWithFilterView:self andFilter:self.filter];
    }
}
- (UIButton *)getButtonWithFrame:(CGRect)frame andSelector:(SEL)selector andTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return btn;
}
- (void)setData:(AssetModel *)data {
    _data = data;
    [PFImagePickerTool requestImageWithAsset:_data.asset targetSize:CGSizeMake(80, 80) completionHandler:^(UIImage *image, NSString *filePath, BOOL succees) {
        self.originImage = image;
        [self.selectionView reloadData];
    }];
}
#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _filters.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filter = nil;
    if (indexPath.item < _filters.count) {
        filter = _filters[indexPath.item];
    }
    PFFilterCell *cell = [[PFFilterCell alloc] initWithCollectionView:collectionView andIndexPath:indexPath andFilter:filter andImage:_originImage];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFFilterCell *cell = (PFFilterCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.filter = cell.filter;
    if (currentCell != cell) {
         cell.selected = YES;
        if ([self.delegate respondsToSelector:@selector(clickOneWithFilterView:andFilter:)]) {
            [self.delegate clickOneWithFilterView:self andFilter:self.filter];
        }
    }
    currentCell = cell;
    
}
@end
