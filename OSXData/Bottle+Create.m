//
//  Bottle+Create.m
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Bottle+Create.h"

@implementation Bottle (Create)
+(NSOrderedSet *)whiteList;
{
    NSOrderedSet *set = [NSOrderedSet orderedSetWithObjects:@"name", @"count", @"subType", @"barcode", nil];
    return set;
    
}

+(Bottle *)bottleForName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bottle"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // get the results and print them
    NSError *err;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    
    // if none were returned, then create one
    if ([fetchedObjects count] == 0) {
        Bottle *newBottle = [Bottle newBlankBottleInContext:context];
        newBottle.name = name;
        return newBottle;
    }
    else {
        Bottle *bottle = [fetchedObjects lastObject];
        return bottle;
    }
}

+(Bottle *)bottleForBarcode:(NSString *)barcode inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bottle"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"barcode = %@", barcode];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // get the results and print them
    NSError *err;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    
    // if none were returned, return NO
    if ([fetchedObjects count] == 0) {
        return NO;
    }
    else {
        Bottle *bottle = [fetchedObjects lastObject];
        return bottle;
    }
}

+(Bottle *)newBlankBottleInContext:(NSManagedObjectContext *)context {
    Bottle *bottle = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Bottle"
                      inManagedObjectContext:context];
    bottle.name = @"No Name";
    bottle.barcode = @"No Barcode";
    [InventorySnapshotForBottle newInventoryForBottleSnapshotForDate:[NSDate date] withCount:(NSNumber *)0 forBottle:bottle inManagedObjectContext:context];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return bottle;
}

+(Bottle *)newBottleForBarcode:(NSString *)barcode inManagedObjectContext:(NSManagedObjectContext *)context {
    Bottle *bottle = [Bottle newBlankBottleInContext:context];
    if (barcode) {
        bottle.barcode = barcode;
    }
    return bottle;
}
+(OrderForBottle *)mostRecentOrderForBottle:(Bottle *)bottle inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderForBottle" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"whichBottle.name = %@", bottle.name];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"whichOrder.date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // We only want the most recent one
    [fetchRequest setFetchBatchSize:1];
    
    NSError * err = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    OrderForBottle * orderForBottle = [fetchedObjects lastObject];
    
    return orderForBottle;
}

@end
