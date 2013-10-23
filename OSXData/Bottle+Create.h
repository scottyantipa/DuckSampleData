//
//  Bottle+Create.h
//  Duck03
//
//  Created by Scott Antipa on 8/25/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Bottle.h"

@interface Bottle (Create)
+(NSOrderedSet *)whiteList;
+(Bottle *)bottleForName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+(Bottle *)bottleForBarcode:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+(Bottle *)newBottleForName:(NSString *)barcode inManagedObjectContext:(NSManagedObjectContext *)context;
+(Bottle *)newBottleForBarcode:(NSString *)barcode inManagedObjectContext:(NSManagedObjectContext *)context;
+(Bottle *)newBlankBottleInContext:(NSManagedObjectContext *)context;
@end
