//
//  InventorySnapshotForBottle.h
//  Duck
//
//  Created by Scott Antipa on 4/23/14.
//  Copyright (c) 2014 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bottle;

@interface InventorySnapshotForBottle : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Bottle *whichBottle;

@end
