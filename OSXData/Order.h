//
//  Order.h
//  Duck
//
//  Created by Scott Antipa on 5/3/14.
//  Copyright (c) 2014 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invoice, OrderForBottle, Vendor;

@interface Order : NSManagedObject

@property (nonatomic, retain) NSNumber * arrived;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * sent;
@property (nonatomic, retain) NSNumber * totalAmount;
@property (nonatomic, retain) NSSet *ordersByBottle;
@property (nonatomic, retain) Vendor *whichVendor;
@property (nonatomic, retain) Invoice *invoice;
@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addOrdersByBottleObject:(OrderForBottle *)value;
- (void)removeOrdersByBottleObject:(OrderForBottle *)value;
- (void)addOrdersByBottle:(NSSet *)values;
- (void)removeOrdersByBottle:(NSSet *)values;

@end