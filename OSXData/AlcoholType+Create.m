//
//  AlcoholType+Create.m
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholType+Create.h"

@implementation AlcoholType (Create)


// Gets the managed object for the alcohol type with the given name
+(AlcoholType *)alcoholTypeFromName:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AlcoholType"];
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
    if ([fetchedObjects count] == 0) {
        AlcoholType *type = [AlcoholType newTypeForName:@"" inManagedObjectContext:context];
        return type;
    }
    else {
        AlcoholType *alcType = [fetchedObjects lastObject];
        return alcType;
    }
}

+(AlcoholType *)newTypeForName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    AlcoholType *type = [NSEntityDescription
                         insertNewObjectForEntityForName:@"AlcoholType"
                         inManagedObjectContext:context];
    type.name = name;
    return type;
}

@end
