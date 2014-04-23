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

// Either add or remove an orderForBottle from the Order (e.g. when a user toggles that bottle in the
// order table view controller)
+(void)toggleBottle:(Bottle *)bottle inOrder:(Order *)order inContext:(NSManagedObjectContext *)context {
    bool isSelected = NO;
    NSSet * bottlesInOrder = order.ordersByBottle;
    for (OrderForBottle * orderForBottle in bottlesInOrder) {
        if ([orderForBottle.whichBottle.name isEqualToString:[NSString stringWithFormat:@"%@", bottle.name]]) { // there was an order for that bottle -- lets delete it
            isSelected = YES;
            [context deleteObject:orderForBottle];
            break; // note, it would be a bug if there are more than one orderesForBottle, so we are safe to break after 1
        }
    }
    if (!isSelected) {
        [OrderForBottle newOrderForBottle:bottle forOrder:order inManagedObjectContext:context];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

//+(MFMailComposeViewController *)mailComposeForOrder:(Order *)order {
//    NSSet * bottlesInOrder = order.ordersByBottle;
//    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"whichBottle.name" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    NSArray * sortedBottlesInOrder = [bottlesInOrder sortedArrayUsingDescriptors:sortDescriptors];
//
//    Vendor * vendor = order.whichVendor;
//    NSArray * toRecipients = @[vendor.email];
//    NSString * greeting = [NSString stringWithFormat:@"%@\n\nI would like to place an order with you as described below:", vendor.firstName];
//    
//    // Create the string for this bottle order (bottle name, price, quantity)
//    NSMutableArray * bottleStrings = [[NSMutableArray alloc] init];
//    for (OrderForBottle * orderForBottle in sortedBottlesInOrder) {
//        if ([orderForBottle.quantity isEqualToNumber:[NSNumber numberWithInt:0]]) {
//            continue;
//        }
//        NSString * quantity = [NSString stringWithFormat:@"Qty: %g", [orderForBottle.quantity floatValue]];
//        NSString * name = [NSString stringWithFormat:@"Bottle: %@", orderForBottle.whichBottle.name];
//        NSString * price = [NSString stringWithFormat:@"Unit Price (as of last order): %g", [orderForBottle.unitPrice floatValue]];
//        NSString * blockForBottle = [NSString stringWithFormat:@"%@\n%@\n%@", name, quantity, price];
//        [bottleStrings addObject:blockForBottle];
//    }
//
//    NSString * allBottles = [bottleStrings componentsJoinedByString:@"\n\n"];  // join all bottle descriptions with a space between
//    NSString * signOff = [NSString stringWithFormat:@"Thank you. \n\nPowered by Duck Rows"];
//    NSString * body = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", greeting, allBottles, signOff];
//
//    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//    [mailViewController setToRecipients:toRecipients];
//    [mailViewController setSubject:@"Re-Order"];
//    [mailViewController setMessageBody:body isHTML:NO];
//    return mailViewController;
//}

// When user tries to send a new or past order to the vendor
// this checks to see if the order has enough information (vendor, vendor email, bottles, etc.)
+(NSString *)errorStringForSendingIncompleteOrder:(Order *)order {
    BOOL noError = YES;
    NSMutableArray * errorStrings = [[NSMutableArray alloc]init];
    if (order.whichVendor) {
        if (!order.whichVendor.email) {
            noError = NO;
            [errorStrings addObject:[NSString stringWithFormat:@"No email for Vendor."]];
        }
    } else {
        noError = NO;
        [errorStrings addObject:[NSString stringWithFormat:@"No Vendor Specified."]];
    }
    
    if ([order.ordersByBottle count] > 0) { // check that all the bottles have a price/quantity
        BOOL ordersAreComplete = YES;
        for (OrderForBottle * orderForBottle in order.ordersByBottle) {
            if (([orderForBottle.quantity intValue] == 0) || ([orderForBottle.unitPrice intValue] == 0)) {
                ordersAreComplete = NO;
                noError = NO;
                break;
            }
        }
        if (!ordersAreComplete) {
            [errorStrings addObject:@"Some bottles have zero quantity or price."];
        }
    } else {
        noError = NO;
        [errorStrings addObject:@"You haven't added bottles to this order."];
    }
    
    if (noError) {
        return NULL;
    } else {
        return [errorStrings componentsJoinedByString:@"\n"];
    }
    return NULL;
}

// When user wants to duplicate a previous order, we need to make
// a new Order object with same data, but with a new date.
+(Order *)makeDuplicate:(Order *)order inContext:(NSManagedObjectContext *)context {
    Order * duplicateOrder = [Order newOrderForDate:[NSDate date] inManagedObjectContext:context];
    duplicateOrder.whichVendor = order.whichVendor;

    // copy over the orderForBottles
    for (OrderForBottle * orderForBottle in order.ordersByBottle) {
        Bottle * bottle = orderForBottle.whichBottle;
        OrderForBottle * duplicateOrderForBottle = [OrderForBottle newOrderForBottle:bottle forOrder:duplicateOrder inManagedObjectContext:context];
        duplicateOrderForBottle.quantity = orderForBottle.quantity;
        duplicateOrderForBottle.unitPrice = orderForBottle.unitPrice;
    }
    return duplicateOrder;
}
@end
