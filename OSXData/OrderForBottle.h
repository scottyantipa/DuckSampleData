//
//  OrderForBottle.h
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bottle, Order;

@interface OrderForBottle : NSManagedObject

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) Bottle *whichBottle;
@property (nonatomic, retain) Order *whichOrder;

@end
