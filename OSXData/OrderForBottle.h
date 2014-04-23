//
//  OrderForBottle.h
//  Duck
//
//  Created by Scott Antipa on 4/23/14.
//  Copyright (c) 2014 Scott Antipa. All rights reserved.
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
