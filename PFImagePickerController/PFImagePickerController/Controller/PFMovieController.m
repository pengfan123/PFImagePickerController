//
//  PFMovieController.m
//  PFImagePickerController
//
//  Created by 软件开发部2 on 16/5/20.
//  Copyright © 2016年 软件开发部2. All rights reserved.
//

#import "PFMovieController.h"
#import <AssetsLibrary/AssetsLibrary.h>
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
    NSURLRequest *request = [NSURLRequest requestWithURL:self.asset.defaultRepresentation.url];
    [_movieView loadRequest:request];
}
#pragma mark - UIWebViewDelegate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error--------%@",error.localizedDescription);
}
@end
