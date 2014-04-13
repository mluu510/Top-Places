//
//  PhotoViewController.m
//  Top Places
//
//  Created by Minh Luu on 4/1/14.
//  Copyright (c) 2014 Minh Luu. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.photo[@"title"];
    self.scrollView.delegate = self;
    [self downloadImage];
}

- (void)downloadImage {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Image Download", NULL);
    dispatch_async(downloadQueue, ^{
        [self.spinner startAnimating];
        NSURL *photoURL = [FlickrFetcher URLforPhoto:self.photo format:FlickrPhotoFormatLarge];
        NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIImage *photo = [UIImage imageWithData:photoData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayImage:photo];
            [self.spinner stopAnimating];
        });
    });
}

- (void)displayImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    float ratio = MIN(self.scrollView.bounds.size.width / image.size.width, self.scrollView.bounds.size.height / image.size.height);
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width * ratio, imageView.frame.size.height * ratio);
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = imageView.frame.size;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 1/ratio;
    [self centerScrollViewContent:self.scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView.subviews firstObject];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews firstObject];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)centerScrollViewContent:(UIScrollView *)scrollView {
    UIView *subView = [scrollView.subviews firstObject];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
