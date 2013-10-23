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
        Bottle *newBottle = [Bottle newBottleForName:name inManagedObjectContext:context];
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
    
    // if none were returned, then create one
    if ([fetchedObjects count] == 0) {
        Bottle *newBottle = [Bottle newBottleForBarcode:barcode inManagedObjectContext:context];
        return newBottle;
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
    // NOTE:  need to make a new InventorySnapshot of 0 for it
    return bottle;
}

+(Bottle *)newBottleForName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Bottle *bottle = [Bottle newBlankBottleInContext:context];
    if (name) {
        bottle.name = name;
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

@end
