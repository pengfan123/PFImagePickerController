//
//  AlbumsCell.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/16.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "AlbumsCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface AlbumsCell()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (strong,nonatomic)ALAssetsGroup *group;
- (IBAction)click:(UIControl *)sender;

@end
@implementation AlbumsCell
-(instancetype)initWithTableView:(UITableView *)tableView andAssetsGroup:(ALAssetsGroup *)group andDelegate:(id<AlbumsCellDelegate>)delegate{
    static NSString *identifier = @"AlbumsCell";
    self = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"AlbumsCell" owner:nil options:nil] lastObject];
    }
    self.delegate = delegate;
    self.group    = group;
    return self;
}
-(void)setGroup:(ALAssetsGroup *)group{
    _group = group;
    //set image and other info
    _posterView.image = [UIImage imageWithCGImage:_group.posterImage];
    _nameLabel.text   = [_group valueForProperty:ALAssetsGroupPropertyName];
    _countLabel.text  = [NSString stringWithFormat:@"%ld",_group.numberOfAssets];
}
- (IBAction)click:(UIControl *)sender {
    if ([self.delegate respondsToSelector:@selector(AlbumsCell:didSelectOneGroup:)]) {
        [self.delegate AlbumsCell:self didSelectOneGroup:_group];
    }
}
@end
