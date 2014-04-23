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

+(void)recalculateUserOrderingForSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context {
    NSString * subTypeName = subType.name;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bottle"];
    
    // Completely recalculate the userOrdering for all bottles (there may be gaps if a user removed/added a bottle)
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subType.name = %@", subTypeName];
    NSSortDescriptor * sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"userHasBottle" ascending:NO];
    NSSortDescriptor * sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"userOrdering" ascending:YES];
    NSSortDescriptor * sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray * sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *err;
    NSArray * fetchedBottles = [context executeFetchRequest:fetchRequest error:&err];
    
    for (Bottle * bottle in fetchedBottles) {
        NSUInteger index = [fetchedBottles indexOfObject:bottle];
        int indexInt = (int)index;
        bottle.userOrdering = [NSNumber numberWithInt:indexInt];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

+(void)changeBottle:(Bottle *)bottle toSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context {
    bottle.subType = subType;
    NSArray * fetchedBottles = [AlcoholSubType fetchedBottlesForSubType:bottle.subType inContext:context];
    bottle.userHasBottle = [NSNumber numberWithBool:YES];
    NSUInteger newOrder = [fetchedBottles count];
    int newOrderInt = (int)newOrder;
    bottle.userOrdering = [NSNumber numberWithInteger:(newOrderInt)];
}

+(void)changeOrderOfBottle:(Bottle *)bottle toNumber:(NSNumber *)number inContext:(NSManagedObjectContext *)context {
    int oldOrder = [bottle.userOrdering intValue];
    int newOrder = [number intValue];
    bottle.userOrdering = number;
    
    // iterate over the other bottles and update their user ordrering
    NSArray * fetchedBottles = [AlcoholSubType fetchedBottlesForSubType:bottle.subType inContext:context];
    for (Bottle * otherBottle in fetchedBottles) {
        if (otherBottle.name == bottle.name) { // its the bottle we already moved
            continue;
        }
        int oldOrderForOtherBottle = [otherBottle.userOrdering intValue];
        NSNumber * newOrderForOtherBottle;
        if ((oldOrder < oldOrderForOtherBottle) & (newOrder >= oldOrderForOtherBottle)) { // bottle was before, now is after
            newOrderForOtherBottle = [NSNumber numberWithInt:(oldOrderForOtherBottle - 1)];
        } else if ((oldOrder > oldOrderForOtherBottle) & (newOrder <= oldOrderForOtherBottle)) {   // bottle was after, now is before
            newOrderForOtherBottle = [NSNumber numberWithInt:(oldOrderForOtherBottle + 1)];
        } else {
            continue; // don't change the ordering
        }
        otherBottle.userOrdering = newOrderForOtherBottle;
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

+(NSArray *)fetchedBottlesForSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context {
    NSString * subTypeName = subType.name;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bottle"];
    
    // Fetch the bottles that the user has.  We will adjust their userOrdering when the user
    // adds/removes a bottle
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(subType.name = %@) AND (self.userHasBottle = %@)", subTypeName, [NSNumber numberWithBool:YES]];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userOrdering" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *err;
    return [context executeFetchRequest:fetchRequest error:&err];
}

@end
