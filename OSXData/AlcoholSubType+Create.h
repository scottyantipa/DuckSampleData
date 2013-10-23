//
//  AlcoholSubType+Create.h
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholSubType.h"

@interface AlcoholSubType (Create)
+(AlcoholSubType *)alcoholSubTypeFromName:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(AlcoholSubType *)newSubTypeFromName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
@end
