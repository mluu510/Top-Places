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

@end

@implementation SelectedPlaceTableViewController

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
    
//    NSLog(@"%@", self.place);
    self.title = [[self.place[@"_content"] componentsSeparatedByString:@", "] firstObject];
    
    NSString *placeId = self.place[@"place_id"];
    NSURL *placeURL = [FlickrFetcher URLforPhotosInPlace:placeId maxResults:50];
    
    NSData *photosData = [NSData dataWithContentsOfURL:placeURL];
    NSDictionary *photosDictionary = [NSJSONSerialization JSONObjectWithData:photosData options:0 error:nil];
    self.photos = photosDictionary[@"photos"][@"photo"];
//    NSLog(@"%@", self.photos);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
//        NSLog(@"Moved photo to the top");
    }
    if (history.count>20) {
        [history removeLastObject];
    }
    [defaults setObject:history forKey:@"history"];
    [defaults synchronize];
}

@end
