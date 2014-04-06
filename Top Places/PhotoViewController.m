//
//  PhotoViewController.m
//  Top Places
//
//  Created by Minh Luu on 4/1/14.
//  Copyright (c) 2014 Minh Luu. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.photo[@"title"];
    [self downloadImage];
}

- (void)downloadImage {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Image Download", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *photoURL = [FlickrFetcher URLforPhoto:self.photo format:FlickrPhotoFormatLarge];
        NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIImage *photo = [UIImage imageWithData:photoData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoImageView.image = photo;
            [self.spinner stopAnimating];
        });
    });
}

@end
