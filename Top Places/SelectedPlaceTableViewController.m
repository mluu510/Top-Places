//
//  SelectedPlaceTableViewController.m
//  Top Places
//
//  Created by Minh Luu on 4/1/14.
//  Copyright (c) 2014 Minh Luu. All rights reserved.
//

#import "SelectedPlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface SelectedPlaceTableViewController ()

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation SelectedPlaceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [[self.place[@"_content"] componentsSeparatedByString:@", "] firstObject];
    [self downloadPlace];
}

- (void)downloadPlace {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Place Download", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSString *placeId = self.place[@"place_id"];
        NSURL *placeURL = [FlickrFetcher URLforPhotosInPlace:placeId maxResults:50];
        
        NSData *photosData = [NSData dataWithContentsOfURL:placeURL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSDictionary *photosDictionary = [NSJSONSerialization JSONObjectWithData:photosData options:0 error:nil];
        self.photos = [photosDictionary valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo Cell" forIndexPath:indexPath];
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = photo[@"title"];
    cell.detailTextLabel.text = photo[@"ownername"];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    PhotoViewController *photoVC = segue.destinationViewController;
    photoVC.photo = photo;
    
    // Save into recently viewd photos
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *history = [[defaults objectForKey:@"history"] mutableCopy];
    if (!history) {
        history = [@[] mutableCopy];
    }
    if (![history containsObject:photo]) {
        [history insertObject:photo atIndex:0];
    } else {
        [history removeObject:photo];
        [history insertObject:photo atIndex:0];
    }
    if (history.count>20) {
        [history removeLastObject];
    }
    [defaults setObject:history forKey:@"history"];
    [defaults synchronize];
}

@end
