//
//  AlcoholSubTypesTableViewController.m
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholSubTypesTableViewController.h"
#import "AlcoholSubType.h"
#import "BottleDetailTableViewController.h"

@interface AlcoholSubTypesTableViewController ()

@end

@implementation AlcoholSubTypesTableViewController

// why do I have to synthesize these here, as well as in the parent class?
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize parentType = _parentType;

-(void)setParentType:(AlcoholType *)parentType
{
    _parentType = parentType;
    self.title = parentType.name;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AlcoholSubType"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parent.name = %@", self.parentType.name];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // get the results and print them
//    NSError *err;
//    NSArray *fetchedObjects = [self.parentType.managedObjectContext executeFetchRequest:fetchRequest error:&err];
//    for (AlcoholSubType *subType in fetchedObjects) {
//        NSLog(@"SubType Name: %@", subType.name);
//    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.parentType.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlcoholSubTypesCellId" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AlcoholSubType *subType = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = subType.name;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    AlcoholSubType *subType = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setSubType:)]) {
        [segue.destinationViewController setSubType:subType];
    }
}


-(void)viewDidUnload
{
    self.fetchedResultsController = nil;
}
@end
