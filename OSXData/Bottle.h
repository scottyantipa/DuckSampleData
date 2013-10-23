//
//  Bottle.h
//  Duck03
//
//  Created by Scott Antipa on 9/8/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlcoholSubType, InventorySnapshotForBottle;

@interface Bottle : NSManagedObject

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *inventoryShapshots;
@property (nonatomic, retain) AlcoholSubType *subType;
@end

@interface Bottle (CoreDataGeneratedAccessors)

- (void)addInventoryShapshotsObject:(InventorySnapshotForBottle *)value;
- (void)removeInventoryShapshotsObject:(InventorySnapshotForBottle *)value;
- (void)addInventoryShapshots:(NSSet *)values;
- (void)removeInventoryShapshots:(NSSet *)values;

@end
