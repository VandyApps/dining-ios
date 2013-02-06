//
//  VMDMenuTableViewController.m
//  Dining
//
//  Created by Oliver Dormody on 11/12/12.
//  Copyright (c) 2012 VandyMobile. All rights reserved.
//

#import "VMDMenuTableViewController.h"
#import "VMDItem.h"

#import "TFHpple.h"

@interface VMDMenuTableViewController ()

@end

@implementation VMDMenuTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self downloadAndParseMenuForDate:[NSDate date]];
}

- (void)downloadAndParseMenuForDate:(NSDate *)date {
    [self parseHppleMenu:
     [self downloadMenuForDateComponents:
      [self componentsFromCurrentDate:date]]];
}

- (NSDateComponents *)componentsFromCurrentDate:(NSDate *)today {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian components:(NSDayCalendarUnit
                           | NSMonthCalendarUnit
                           | NSYearCalendarUnit) fromDate:today];
}

- (TFHpple *)downloadMenuForDateComponents:(NSDateComponents *)components {
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    return [self downloadMenuForMonth:month Day:day Year:year];
}

- (TFHpple *)downloadMenuForMonth:(NSInteger)month Day:(NSInteger)day Year:(NSInteger)year {
    // Grab the data from the web for today's menu
    NSData  * data      = [NSData dataWithContentsOfURL:
                           [NSURL URLWithString:
                            [NSString stringWithFormat:
                             @"http://vanderbilt.mymenumanager.net/menu.php?date=%d,%d,%d&location=-1",
                             month, day, year]]];
    
    // Transform data into HTML parseable document
    return [[TFHpple alloc] initWithHTMLData:data];
}

- (void)parseHppleMenu:(TFHpple *)doc {
    // Perform various searches on tags
    NSArray * locations  = [doc searchWithXPathQuery:@"//td [@class='location_title']"];
    NSArray * subheaders = [doc searchWithXPathQuery:@"//td [@class='displaytext'] [@valign='bottom']"];
    NSArray * mealPeriods = [doc searchWithXPathQuery:@"//td [@class='displaytext'] [@valign='top']"];
    NSArray * menus = [doc searchWithXPathQuery:@"//table [@width='100%'] [@border='0'] [@cellpadding='0'] [@cellspacing='0'] [@class='text']"];
    
    // For each location element
    for (TFHppleElement *location in locations) {
        // Get the index of that element
        int index = [locations indexOfObject:location];
        
        // Grab the subheader and meal period
        TFHppleElement *subHeader = [subheaders objectAtIndex:index];
        TFHppleElement *meal = [mealPeriods objectAtIndex:index];
        
        // Display that in the log
        NSLog(@"%@ - %@ (%@)", [location text], [subHeader text], [meal text]);
        
        // Grab the menu list
        TFHppleElement *menu = [[[menus objectAtIndex:index]
                                 firstChild]
                                firstChild];
        menu = [menu.children objectAtIndex:1];
        
        // Grab each item in that menu, place them in an array
        NSArray *menuItems = [menu childrenWithTagName:@"li"];
        
        // For each of those items, display it neatly
        for (TFHppleElement *menuItem in menuItems) {
            NSLog(@"   * %@", menuItem.text);
        }
    }
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

    return self.menu.mealPeriods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self mealItemsForTableViewSection:section].count;
}

- (NSArray *)mealItemsForTableViewSection:(NSInteger)section {
    NSString *mealKey;
    
    if (section == 0) {
        mealKey = @"Breakfast";
    } else if (section == 1) {
        mealKey = @"Lunch";
    } else if (section == 2) {
        mealKey = @"Dinner";
    } else if (section == 3) {
        mealKey = @"Fourthmeal";
    }
    
    return [self.menu.mealPeriods objectForKey:mealKey];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VMDMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VMDMenuCell"];
    }
    //[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    NSArray *items = [self mealItemsForTableViewSection:indexPath.section];
    NSArray *mainItems = [items lastObject];
    VMDItem *anItem = [mainItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = anItem.name;
    cell.detailTextLabel.text = anItem.category;
    
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
