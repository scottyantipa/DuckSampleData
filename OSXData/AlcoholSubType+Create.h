//
//  AlcoholSubType+Create.h
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholSubType.h"
#import "Bottle+Create.h"

@interface AlcoholSubType (Create)
+(AlcoholSubType *)alcoholSubTypeFromName:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(AlcoholSubType *)newSubTypeFromName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

// When a bottle is added/removed/re-ordered, we need to adjust the
// ordering of all the other bottles in the subType
+(void)recalculateUserOrderingForSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context;

// When a user adds a bottle to their collection we need to givee it an ordering
+(void)changeBottle:(Bottle *)bottle toSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context;

// When user adjusts the ordering of a bottle
+(void)changeOrderOfBottle:(Bottle * )bottle toNumber:(NSNumber *)number inContext:(NSManagedObjectContext *)context;

// Get the users bottles for a subtype
+(NSArray *)fetchedBottlesForSubType:(AlcoholSubType *)subType inContext:(NSManagedObjectContext *)context;
@end
