//
//  AlcoholType+Create.h
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "AlcoholType.h"

@interface AlcoholType (Create)

+(AlcoholType *)alcoholTypeFromName:(NSString *)name
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(AlcoholType *)newTypeForName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
@end
