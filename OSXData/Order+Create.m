//
//  Order+Create.m
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Order+Create.h"


@implementation Order (Create)
+(Order *)newOrderForDate:(NSDate *)date
   inManagedObjectContext:(NSManagedObjectContext *)context {
    Order * order = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Order"
                               inManagedObjectContext:context];
    order.date = date;
    return order;
}

+(NSArray *)getSortedBottlesInOrder:(Order *)order {
    NSSet * bottlesInOrder = order.ordersByBottle;
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"whichBottle.name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    return [bottlesInOrder sortedArrayUsingDescriptors:sortDescriptors];
}


+(float)totalAmountOfOrder:(Order *)order {
    NSArray * sortedBottleOrders = [Order getSortedBottlesInOrder:order];
    float totalAmount = 0;
    for (OrderForBottle * order in sortedBottleOrders) {
        float floatPrice = [order.unitPrice floatValue];
        float floatQuantity = [order.quantity floatValue];
        float totalForBottleOrder = floatPrice * floatQuantity;
        totalAmount = totalAmount + totalForBottleOrder;
    }
    return totalAmount;
}
@end
