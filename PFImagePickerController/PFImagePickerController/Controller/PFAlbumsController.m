//
//  PFAlbumsController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFAlbumsController.h"
#import "PFAssetsController.h"
#import "PFImagePickerController.h"
#import "AlbumsCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PFImagePickerTool.h"
@interface PFAlbumsController ()<UITableViewDataSource,UITableViewDelegate,AlbumsCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *albumsTable;
@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,strong)PHPhotoLibrary *library;
@end

@implementation PFAlbumsController
#pragma mark - lazy loading 
-(NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSArray new];
    }
    return _dataArr;
}
#pragma mark - life cycle
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self registeObserver];
    [self updateGroups];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PhotosChangeNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem.enabled = [PFImagePickerTool checkSelectionStatus];
}
#pragma mark - private method
-(void)setupUI{
    self.editing = NO;
    self.title = @"相册";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)registeObserver{
    //regist the observer for observing the change of photo library
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumsChangeNotification:) name:PhotosChangeNotification object:nil];
}
-(void)updateGroups{
    [PFImagePickerTool fetchCollectionsWithCompletion:^(NSError *error, NSArray *dataArr) {
        self.dataArr = dataArr;
        [_albumsTable reloadData];
    }];
}
//相册更改
-(void)albumsChangeNotification:(NSNotification *)info{
    //update after a delay to make sure that the main thread can't be blocked
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateGroups];
    });
}
//取消操作
-(void)cancelAction:(id)sender{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
//完成操作
-(void)doneAction:(id)sender{
    [self.imagePickerController pfImagePickerControllerDidFinishPickImage];
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PHAssetCollection *collection = nil;
    if (indexPath.row < self.dataArr.count) {
        collection = self.dataArr[indexPath.row];
    }
    AlbumsCell *cell = [[AlbumsCell alloc] initWithTableView:tableView andAssetsCollection:collection andDelegate:self];
    return cell;
}
#pragma mark - AlbumsCellDelegate
-(void)AlbumsCell:(AlbumsCell *)cell didSelectOneCollection:(PHAssetCollection *)collection{
    PFAssetsController *controller = [[PFAssetsController alloc] init];
    controller.collection = collection;
    controller.imagePickerController = self.imagePickerController;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
