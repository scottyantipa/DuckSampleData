//
//  Order.h
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OrderForBottle;

@interface Order : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * totalAmount;
@property (nonatomic, retain) NSSet *ordersByBottle;
@property (nonatomic, retain) NSManagedObject *whichVendor;
@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addOrdersByBottleObject:(OrderForBottle *)value;
- (void)removeOrdersByBottleObject:(OrderForBottle *)value;
- (void)addOrdersByBottle:(NSSet *)values;
- (void)removeOrdersByBottle:(NSSet *)values;

@end
