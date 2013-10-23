//
//  AlcoholSubType.h
//  Duck03
//
//  Created by Scott Antipa on 9/5/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlcoholType, Bottle;

@interface AlcoholSubType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *bottles;
@property (nonatomic, retain) AlcoholType *parent;
@end

@interface AlcoholSubType (CoreDataGeneratedAccessors)

- (void)addBottlesObject:(Bottle *)value;
- (void)removeBottlesObject:(Bottle *)value;
- (void)addBottles:(NSSet *)values;
- (void)removeBottles:(NSSet *)values;

@end
