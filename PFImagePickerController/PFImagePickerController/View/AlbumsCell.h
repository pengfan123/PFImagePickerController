//
//  AlbumsCell.h
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAssetCollection;
@class AlbumsCell;
@protocol AlbumsCellDelegate <NSObject>
@optional
/**
 *  点击某一行触发的
 *
 *  @param cell  点击的Cell
 *  @param group 当前cell持有的ALAssetsGroup对象
 */
-(void)AlbumsCell:(AlbumsCell *)cell didSelectOneCollection:(PHAssetCollection *)collection;
@end
@interface AlbumsCell : UITableViewCell
/**代理*/
@property(nonatomic,weak)id<AlbumsCellDelegate>delegate;
/**
 *  初始化方法
 *
 *  @param tableView 用于重用
 *  @param collection     PHAssetCollection对象,获取当前相册下的一些信息
 *  @param delegate  代理
 *
 *  @return 返回一个AlbumsCell对象
 */
-(instancetype)initWithTableView:(UITableView *)tableView andAssetsCollection:(PHAssetCollection *)collection andDelegate:(id<AlbumsCellDelegate>)delegate;
@end
