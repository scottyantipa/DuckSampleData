//
//  AlcoholSubType+Create.m
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholSubType+Create.h"

@implementation AlcoholSubType (Create)

// Gets the managed object for the alcohol type with the given name
// If there isn't one already in existence (or the name is "") then create one
+(AlcoholSubType *)alcoholSubTypeFromName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AlcoholSubType"];
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
        AlcoholSubType *newSubType = [AlcoholSubType newSubTypeFromName:@"New Bottle" inManagedObjectContext:context];
        return newSubType;
    }
    else {
        AlcoholSubType *subType = [fetchedObjects lastObject];
        return subType;
    }
    
}

+(AlcoholSubType *)newSubTypeFromName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    AlcoholSubType *subType = [NSEntityDescription
                               insertNewObjectForEntityForName:@"AlcoholSubType"
                               inManagedObjectContext:context];
    subType.name = name;
    // need to add in unique id here
    return subType;
}

@end
