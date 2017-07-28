//
//  AlbumsCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "AlbumsCell.h"
#import "PFImagePickerTool.h"
#import <Photos/Photos.h>
@interface AlbumsCell()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (strong,nonatomic)PHAssetCollection *collection;
- (IBAction)click:(UIControl *)sender;

@end
@implementation AlbumsCell
-(instancetype)initWithTableView:(UITableView *)tableView andAssetsCollection:(PHAssetCollection *)collection andDelegate:(id<AlbumsCellDelegate>)delegate{
    static NSString *identifier = @"AlbumsCell";
    self = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"AlbumsCell" owner:nil options:nil] lastObject];
    }
    self.delegate   = delegate;
    self.collection = collection;
    self.posterView.image = [PFImagePickerTool loadImageWithName:@"placeholder"];
    return self;

}
-(void)setCollection:(PHAssetCollection *)collection{
    _collection = collection;
    _countLabel.text = @"正在获取资源数量";
    [PFImagePickerTool requestPosterForAssetsCollection:collection completionHandler:^(UIImage *result, NSString *filePath, BOOL succees) {
        if (result) {
            _posterView.image = result;
        }
    }];
    _nameLabel.text = collection.localizedTitle;
    [PFImagePickerTool requestCountOfAssetsInCollection:collection completionHandler:^(NSUInteger count, BOOL result) {
        if (result) {
           _countLabel.text = [NSString stringWithFormat:@"%lu",count];
        }
        else{
            _countLabel.text = @"0";
        }
    }];
}

- (IBAction)click:(UIControl *)sender {
    if ([self.delegate respondsToSelector:@selector(AlbumsCell:didSelectOneCollection:)]) {
        [self.delegate AlbumsCell:self didSelectOneCollection:_collection];
    }
}
@end
