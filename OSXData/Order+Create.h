//
//  Order+Create.h
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Order.h"
#import "OrderForBottle+Create.h"

@interface Order (Create)
+(Order *)newOrderForDate:(NSDate *)date
            inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)getSortedBottlesInOrder:(Order *)order;
+(float)totalAmountOfOrder:(Order *)order;
@end
