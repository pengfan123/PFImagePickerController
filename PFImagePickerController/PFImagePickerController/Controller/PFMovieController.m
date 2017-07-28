//
//  PFMovieController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/20.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFMovieController.h"
#import <Photos/Photos.h>
@interface PFMovieController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *movieView;
@end
@implementation PFMovieController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRequest];
}
#pragma mark - private method
-(void)loadRequest{
    PHVideoRequestOptions *options2 = [[PHVideoRequestOptions alloc] init];
    options2.deliveryMode=PHVideoRequestOptionsDeliveryModeAutomatic;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:options2 resultHandler:^(AVAsset*_Nullable asset,
                                                                                                    AVAudioMix*_Nullable audioMix,NSDictionary*_Nullable info) {
        
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [_movieView loadRequest:[NSURLRequest requestWithURL:((AVURLAsset *)asset).URL]];
            });
        }
    }];
}
#pragma mark - UIWebViewDelegate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error--------%@",error.localizedDescription);
}
-(void)dealloc{
    [_movieView stopLoading];
}
@end
