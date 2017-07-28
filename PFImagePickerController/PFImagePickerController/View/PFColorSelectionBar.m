//
//  PFColorSelectionBar.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/20.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFColorSelectionBar.h"
#import "PFColorCell.h"

@interface PFColorSelectionBar()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong)NSArray *colors;
@end
@implementation PFColorSelectionBar

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupUI];
        self.hidden = YES;
    }
    return self;
}

- (void)showOrHide:(BOOL)isShow {
    CATransition *transion = [[CATransition alloc] init];
    transion.type = kCATransitionFade;
    transion.duration = 0.3;
    self.hidden = isShow;
    [self.layer addAnimation:transion forKey:nil];
}
- (void)initialization {
    self.colors = @[[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor]];
}
- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumInteritemSpacing = 50;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowlayout.itemSize = CGSizeMake(40, 40);
    UICollectionView *collectview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 0.8, self.frame.size.height) collectionViewLayout:flowlayout];
    [collectview registerNib:[UINib nibWithNibName:@"PFColorCell" bundle:nil] forCellWithReuseIdentifier:@"PFColorCell"];
    collectview.backgroundColor = [UIColor clearColor];
    collectview.showsVerticalScrollIndicator = NO;
    collectview.showsHorizontalScrollIndicator = NO;
    collectview.delegate = self;
    collectview.dataSource = self;
    [self addSubview:collectview];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(collectview.frame), 0, self.frame.size.width - collectview.frame.size.width, self.frame.size.height)];
    [btn setTitle:@"恢复" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.backgroundColor  = [UIColor clearColor];
    [btn addTarget:self action:@selector(restore:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PFColorCell" forIndexPath:indexPath];
    UIColor *color = nil;
    if (indexPath.item < self.colors.count) {
        color = self.colors[indexPath.item];
    }
    cell.color = color;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFColorCell *cell = (PFColorCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.operationBlock) {
        self.operationBlock(NO, cell.color);
    }
}
- (void)restore:(UIButton *)sender {
    if (self.operationBlock) {
        self.operationBlock(YES, nil);
    }
}
@end
