//
//  Order+Create.h
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Order.h"
#import "OrderForBottle+Create.h"
#import "Vendor.h"
//#import <MessageUI/MessageUI.h>
//#import <MessageUI/MFMailComposeViewController.h>
//#import <AddressBookUI/AddressBookUI.h>

@interface Order (Create)
+(Order *)newOrderForDate:(NSDate *)date
            inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)getSortedBottlesInOrder:(Order *)order;
+(float)totalAmountOfOrder:(Order *)order;
//+(MFMailComposeViewController *)mailComposeForOrder:(Order *)order;
+(void)toggleBottle:(Bottle *)bottle inOrder:(Order *)order inContext:(NSManagedObjectContext *)context;
+(NSString *)errorStringForSendingIncompleteOrder:(Order *)order;
+(Order *)makeDuplicate:(Order *)order inContext:(NSManagedObjectContext *)context;
@end
