//
//  Order.m
//  Duck
//
//  Created by Scott Antipa on 5/3/14.
//  Copyright (c) 2014 Scott Antipa. All rights reserved.
//

#import "Order.h"
#import "Invoice.h"
#import "OrderForBottle.h"
#import "Vendor.h"


@implementation Order

@dynamic arrived;
@dynamic date;
@dynamic sent;
@dynamic totalAmount;
@dynamic ordersByBottle;
@dynamic whichVendor;
@dynamic invoice;

@end
