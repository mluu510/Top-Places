//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Minh Luu on 4/1/14.
//  Copyright (c) 2014 Minh Luu. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "SelectedPlaceTableViewController.h"

@interface TopPlacesTableViewController ()

@property (nonatomic, strong) NSDictionary *byCountries;
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@end

@implementation TopPlacesTableViewController

- (void)viewDidLoad {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self loadTopPlaces];
    
}

- (void)refresh {
    [self loadTopPlaces];
}


- (void)loadTopPlaces {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Top place download", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *topPlacesURL = [FlickrFetcher URLforTopPlaces];
        NSData *topPlacesData = [NSData dataWithContentsOfURL:topPlacesURL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSDictionary *topPlaces = [NSJSONSerialization JSONObjectWithData:topPlacesData options:0 error:nil];
        
        self.byCountries = [self placesByCountries:[topPlaces valueForKeyPath:FLICKR_RESULTS_PLACES]];
        self.countries = [self.byCountries.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

- (NSDictionary *)placesByCountries:(NSArray *)places
{
    NSMutableDictionary *byCountries = [@{} mutableCopy];
    
    for (NSDictionary *place in places) {
        NSString *content = place[@"_content"];
        NSString *country = [[content componentsSeparatedByString:@","] lastObject];
        
        if (byCountries[country]) {
            NSMutableArray *placesInCountry = byCountries[country];
            [placesInCountry addObject:place];
        } else {
            byCountries[country] = [@[] mutableCopy];
        }
    }
    return  byCountries;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.countries.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self.countries objectAtIndex:section];
    NSArray *places = self.byCountries[country];
    
    return places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Cell" forIndexPath:indexPath];
 
    // Configure the cell...
    NSString *country = [self.countries objectAtIndex:indexPath.section];
    NSDictionary *place = [self.byCountries[country] objectAtIndex:indexPath.row];
    NSArray *contents = [place[@"_content"] componentsSeparatedByString:@", "];
    NSString *title = [contents firstObject];
    NSString *subtitle;
    if (contents.count > 2) {
        subtitle = [[contents subarrayWithRange:NSMakeRange(1, contents.count-2)] componentsJoinedByString:@", "];
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSString *country = [self.countries objectAtIndex:indexPath.section];
    NSArray *places = self.byCountries[country];
    NSDictionary *selectedPlace = [places objectAtIndex:indexPath.row];
//    NSLog(@"%@", selectedPlace);
    
    SelectedPlaceTableViewController *selectedPlaceTVC = segue.destinationViewController;
    selectedPlaceTVC.place = selectedPlace;
}


@end
