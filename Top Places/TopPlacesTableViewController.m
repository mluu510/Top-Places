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

@property (nonatomic, strong) NSDictionary *topPlaces;
@property (nonatomic, strong) NSDictionary *byCountries;

@end

@implementation TopPlacesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *topPlacesURL = [FlickrFetcher URLforTopPlaces];
    NSData *topPlacesData = [NSData dataWithContentsOfURL:topPlacesURL];
    self.topPlaces = [NSJSONSerialization JSONObjectWithData:topPlacesData options:0 error:nil];
//    NSLog(@"%@", self.topPlaces[@"places"][@"place"]);
    
    self.byCountries = [self placesByCountries:self.topPlaces[@"places"][@"place"]];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
//    NSLog(@"%@", byCountries);
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
    return self.byCountries.allKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.byCountries.allKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self.byCountries.allKeys objectAtIndex:section];
    NSArray *places = self.byCountries[country];
    
    return places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Cell" forIndexPath:indexPath];
 
    // Configure the cell...
    NSString *country = [self.byCountries.allKeys objectAtIndex:indexPath.section];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSString *country = [self.byCountries.allKeys objectAtIndex:indexPath.section];
    NSArray *places = self.byCountries[country];
    NSDictionary *selectedPlace = [places objectAtIndex:indexPath.row];
//    NSLog(@"%@", selectedPlace);
    
    SelectedPlaceTableViewController *selectedPlaceTVC = segue.destinationViewController;
    selectedPlaceTVC.place = selectedPlace;
}


@end
