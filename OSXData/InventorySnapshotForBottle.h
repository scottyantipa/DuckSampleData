//
//  InventorySnapshotForBottle.h
//  Duck03
//
//  Created by Scott Antipa on 9/5/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bottle;

@interface InventorySnapshotForBottle : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Bottle *whichBottle;

@end
