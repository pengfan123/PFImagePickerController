//
//  PFShowImageController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 2017/7/6.
//  Copyright © 2017年 软件开发部2. All rights reserved.
//

#import "PFShowImageController.h"
#import "PFImagePickerController.h"
#import "PFClipAndRotateController.h"
#import "PFImagePickerTool.h"
#import "ShowImageCell.h"
#import "AssetModel.h"
#import "PFColorSelectionBar.h"
#import "PFPaintView.h"
#import "PFFilterView.h"
#import "PFInputView.h"
#import "AssetModel.h"
#import "PFIndicatorView.h"

#define SPACE 20
@interface PFShowImageController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, ShowImageCellDelegate, PFPaintViewDelegate, PFFilterViewDelegate, PFInputViewDelegate>

@property (nonatomic,strong)PFColorSelectionBar *colorBar;
@property (nonatomic,weak)PFPaintView *drawView;
@property (nonatomic,weak)PFFilterView *filterView;
@property (nonatomic,weak)PFInputView *inputView;
@property (nonatomic,strong)PFIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIToolbar *editBottomBar;
@property (weak, nonatomic) IBOutlet UIToolbar *editTopBar;


//bottomBar
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *originBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
- (IBAction)editAction:(UIButton *)sender;
- (IBAction)originAction:(UIButton *)sender;
- (IBAction)sureAction:(UIButton *)sender;


//topBar
@property (weak, nonatomic) IBOutlet UIButton *indexBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
- (IBAction)selectAction:(id)sender;
- (IBAction)back:(id)sender;

//editBottomBar
@property (weak, nonatomic) IBOutlet UIButton *drawBtn;
@property (weak, nonatomic) IBOutlet UIButton *editSureBtn;

- (IBAction)drawAction:(UIButton *)sender; //标注
- (IBAction)clipAction:(UIButton *)sender; //裁剪,旋转
- (IBAction)fontAction:(UIButton *)sender; //写字
- (IBAction)filterAction:(id)sender;       //调用滤镜
- (IBAction)editSureAction:(id)sender;

//EditTopBar
- (IBAction)editBackAction:(UIButton *)sender; //编辑状态返回正常状态
- (IBAction)saveAction:(id)sender;             //保存修改的图
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;


//property
@property(nonatomic,assign)BOOL editing; //判断是否正处于编辑状态
@property(nonatomic,assign)BOOL showBar; //是否展示顶部的按钮

@property(nonatomic,weak)UICollectionView *collectionView;
@end

@implementation PFShowImageController
#pragma mark - override method
- (void)setEditing:(BOOL)editing {
    _editing = editing;
    _collectionView.userInteractionEnabled = !_editing;
    [self exeuteFadeAnimatioWithBlock:^{ //根据编辑状态来调整视图
        _topBar.hidden = _editing;
        _bottomBar.hidden = _editing;
        _editTopBar.hidden = !_topBar.hidden;
        _editBottomBar.hidden = _editTopBar.hidden;
    }];
}
//展示或者隐藏底部编辑工具栏
- (void)setShowBar:(BOOL)showBar {
    _showBar = showBar;
    if (!_editing) {
        [self exeuteFadeAnimatioWithBlock:^{
            _topBar.hidden = !_showBar;
            _bottomBar.hidden = _topBar.hidden;
        }];
    }
    else {
        [self exeuteFadeAnimatioWithBlock:^{
            _editTopBar.hidden = !_showBar;
            _editBottomBar.hidden = _editTopBar.hidden;
        }];
    }
    
}
- (void)exeuteFadeAnimatioWithBlock:(void(^)())animation {
    CATransition *transition = [[CATransition alloc] init];
    transition.type = kCATransitionFade;
    transition.duration = 0.3;
    animation();
    [self.view.layer addAnimation:transition forKey:nil];
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [_indexBtn setTitle:[NSString stringWithFormat:@"%ld/%ld",_currentIndex + 1, _datas.count] forState:UIControlStateNormal];
    AssetModel *model = nil;
    if (_currentIndex < _datas.count) {
        model = _datas[_currentIndex];
    }
    _selectBtn.selected = model.isSelected;
    if (_selectBtn.selected) {
         [_selectBtn setTitle:[NSString stringWithFormat:@"%ld",[PFImagePickerTool selectedCount]] forState:UIControlStateSelected];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [_drawView removeFromSuperview];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
#pragma mark - life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _saveBtn.hidden = YES;
    [self setupUI];
}
- (void)setupUI {
    self.editing = NO;
    PFPaintView *painView = [[PFPaintView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview: painView];
    _drawView = painView;
    _drawView.hidden = YES;
    _drawView.delegate = self;
    
    
    _colorBar = [[PFColorSelectionBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49 - 50, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.view addSubview:_colorBar];
    __weak typeof (self)weakSelf = self;
    _colorBar.operationBlock = ^(BOOL restore, UIColor *selectecColor) {
        if (!restore) {//清空绘画
            weakSelf.drawView.lineColor = selectecColor;
        }
        else {//选择颜色
            [weakSelf.drawView clearAction];
        }
    };
    
    //filterView
    PFFilterView *filterView = [[PFFilterView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 160, [UIScreen mainScreen].bounds.size.width, 160)];
    [self.view addSubview:filterView];
    _filterView = filterView;
    _filterView.hidden = YES;
    _filterView.delegate = self;
    
    //inputView
    PFInputView *inputView = [[PFInputView alloc] initWithFrame:CGRectZero];
    inputView.colorBar = _colorBar;
    inputView.delegate = self;
    [self.view addSubview:inputView];
    _inputView = inputView;
    
    //indicatorView
    _indicatorView = [PFIndicatorView getIndicatorView];
   
    //add collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    
    UICollectionView *collect = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    collect.delegate = self;
    collect.dataSource = self;
    collect.pagingEnabled = YES;
    collect.bounces = NO;
    collect.showsVerticalScrollIndicator = NO;
    collect.showsHorizontalScrollIndicator = NO;
    [collect registerNib:[UINib nibWithNibName:@"ShowImageCell" bundle:nil] forCellWithReuseIdentifier:@"ShowImageCell"];
    [self.view insertSubview:collect atIndex:0];
    _collectionView = collect;
    
    [self initialization];
    
}
- (void)initialization {
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];
    self.currentIndex = _currentIndex;//更新页面展示的序列信息
    if (_currentIndex < self.datas.count) {
        _filterView.data = self.datas[_currentIndex];
    }
    _showBar = YES;
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetModel *model = nil;
    if (indexPath.item < _datas.count) {
        model = _datas[indexPath.item];
    }
    ShowImageCell *cell =  [ShowImageCell getCellWithCollectionView:collectionView andIndexPath:indexPath andDataModel:model];
    cell.delegate = self;
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    _originBtn.selected = [self currentCell].data.original;
    if (_currentIndex < _datas.count) {
         _filterView.data = self.datas[_currentIndex];
    }
   
}
#pragma mark - ShowImageCellDelegate
- (void)cell:(ShowImageCell *)cell didSelectItemAtIndex:(NSIndexPath *)indexPath {
    self.showBar = !self.showBar;
}

#pragma mark - IBAction

- (IBAction)editSureAction:(id)sender {
    if (_drawView.hidden) {//用原来的图
        [_imagePickerController pfImagePickerControllerDidClipImage:[self currentCell].poster.image];
    }
    else {
        [self saveOperation];
    }
}

- (IBAction)drawAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_colorBar showOrHide:!sender.selected];
    self.drawView.image = [self currentCell].poster.image;
    self.drawView.hidden = !sender.selected;
  
}

- (IBAction)clipAction:(UIButton *)sender {
     [self hideColorBar];
        PFClipAndRotateController *vc = [[PFClipAndRotateController alloc] init];
        vc.originalImage = [self currentCell].poster.image;
        vc.pickerController = _imagePickerController;
        [vc show];
}
- (void)hideColorBar {
    _drawBtn.selected = YES;
    [self drawAction:_drawBtn];
}
//获取当前显示的cell
- (ShowImageCell *)currentCell {
    return  (ShowImageCell *)[_collectionView.visibleCells firstObject];
}
- (IBAction)fontAction:(UIButton *)sender {
    _drawBtn.selected = YES;
    [self drawAction:_drawBtn];
    _drawView.hidden = NO;
    [_inputView.inputField becomeFirstResponder];
}

- (IBAction)filterAction:(id)sender {
    [self hideColorBar];
    _filterView.hidden = !_filterView.hidden;
}

- (IBAction)back:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)editAction:(id)sender {
    self.editing = !self.isEditing;
   
}

- (IBAction)originAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self currentCell].data.original = sender.selected;
}

- (IBAction)sureAction:(UIButton *)sender {
    //已经选择好
    [_imagePickerController pfImagePickerControllerDidFinishPickImage];
}
- (IBAction)selectAction:(id)sender {
     UIButton *btn = (UIButton *)sender;
    AssetModel *model = [self currentCell].data;
    model.isSelected = !model.isSelected;
    model.isSelected = [PFImagePickerTool storeSelectedOrUnselectedModel:model];
    btn.selected = model.isSelected;
    if (btn.selected) {
        [_selectBtn setTitle:[NSString stringWithFormat:@"%ld",[PFImagePickerTool selectedCount]] forState:UIControlStateSelected];
    }
}
- (IBAction)editBackAction:(UIButton *)sender {
    [self hideColorBar];
    self.editing = NO;
   
}

- (IBAction)saveAction:(id)sender {
    if (!_drawView.hidden ) {
        [self saveOperation];
    }
}
- (void)saveOperation {
    [_indicatorView show];
    [PFImagePickerTool captureImageWithView:_drawView withFinishBlock:^(BOOL success, UIImage *result) {
        if (success) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_indicatorView hide];
                [_imagePickerController pfImagePickerControllerDidClipImage:result];
            });
        }
        else {
            [_indicatorView hide];
            NSLog(@"保存失败----");
        }
       
        
    }];
}
- (void)hideOrDisplayAllToolBar:(BOOL)show {
    _topBar.hidden = show;
    _editTopBar.hidden = show;
    _bottomBar.hidden = show;
    _editBottomBar.hidden = show;
}
#pragma mark - PFPaintViewDelegate
- (void)PFPaintView:(PFPaintView *)paintView changeToPaint:(PFPaintViewState)state {
    if (state == paintViewStateEndTouch) {
        [self exeuteFadeAnimatioWithBlock:^{
            self.colorBar.hidden = NO;
        }];
    }
   
}
- (void)PFPaintView:(PFPaintView *)paintView beginToPaint:(PFPaintViewState)state {
    [self exeuteFadeAnimatioWithBlock:^{
        self.colorBar.hidden = YES;
    }];
}
- (void)PFPaintView:(PFPaintView *)paintView beginToHiddenOrShow:(BOOL)hidden {
    _saveBtn.hidden = hidden;
}
#pragma mark - PFFilterViewDelegate
- (void)clickCancelWithFilterView:(PFFilterView *)filterView {
    _filterView.hidden = YES;
}
- (void)clickSureWithFilterView:(PFFilterView *)filterView andFilter:(NSString *)filter {
     _filterView.hidden = YES;
    [_indicatorView show];
    [PFImagePickerTool captureImage:[self currentCell].poster.image handler:^(BOOL result) {
        if (result) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_indicatorView hide];
                [_imagePickerController pfImagePickerControllerDidClipImage:[self currentCell].poster.image];
            });
        }
        else {
             [_indicatorView hide];
        }
       
    }];
}
- (void)clickOneWithFilterView:(PFFilterView *)filterView andFilter:(NSString *)filter {
    [[self currentCell] renderImageWithFilter:filter];
}

#pragma mark - PFInputViewDelegate
- (void)inputText:(NSString *)text withInputView:(PFInputView *)inputView {
    _drawView.infoText = text;
}
- (void)cancelWithInputView:(PFInputView *)input {
    _drawView.hidden = YES;
    _drawView.infoText = nil;
}
@end
