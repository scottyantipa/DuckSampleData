//
//  main.m
//  OSXData
//
//  Created by Scott Antipa on 8/24/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "Bottle+Create.h"
#import "AlcoholType+Create.h"
#import "AlcoholSubType+Create.h"
//#import "InventorySnapshotForBottle+Create.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Duck";
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
        

        
    }
    return context;
}

// Put the major types in DB (e.g. 'Wine', 'Liquor', 'Beer')
static void *enterTypes() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    //create the categories and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AlcoholTypes" ofType:@"json"];
    NSArray* AlcoholTypes = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                            options:kNilOptions
                                                              error:&err];
    
    [AlcoholTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [AlcoholType newTypeForName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    

    // list out the categories (FOR DEBEGGUING)
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"AlcoholType"
//                                   inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
//    for (AlcoholType *type in fetchedObjects) {
//        NSLog(@"Type Created: %@", type.name);
//    }
}

static void *enterSubTypes() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    
    //create the bottles and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AlcoholSubTypes" ofType:@"json"];
    NSArray* SubTypes = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                        options:kNilOptions
                                                          error:&err];
    
    [SubTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AlcoholSubType * subType = [AlcoholSubType newSubTypeFromName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        AlcoholType * parent = [AlcoholType alcoholTypeFromName:[obj objectForKey:@"parentType"] inManagedObjectContext:context];
        subType.parent = parent;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    
    // list out the subTypes
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"AlcoholSubType"
//                                   inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
//    for (AlcoholSubType *subType in fetchedObjects) {
//        NSLog(@"SubType Created: %@", subType.name);
//    }
}

static void *enterVarietals() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    
    //create the bottles and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"Varietals" ofType:@"json"];
    NSArray* SubTypes = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                        options:kNilOptions
                                                          error:&err];
    
    [SubTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * subTypeName = [obj objectForKey:@"subType"];
        NSString * name = [obj objectForKey:@"name"];
        if (subTypeName == nil || [subTypeName isEqualToString:@""] || name == nil || [name isEqualToString:@""]) {
            return;
        }
        AlcoholSubType * subType = [AlcoholSubType alcoholSubTypeFromName:subTypeName inManagedObjectContext:context];
        if (subType == nil) {
            return;
        }
        Varietal * varietal = [AlcoholSubType newVarietalForSubType:subType inContext:context];
        varietal.name = name;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    
}

static void *enterBottles() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    
    //create the bottles and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"Bottles" ofType:@"json"];
    NSDictionary * bottles = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                       options:kNilOptions
                                                         error:&err];

    [bottles enumerateKeysAndObjectsUsingBlock:^(id key, id record, BOOL *stop) {

        // unpack all the info from the record
        NSString * name = [record objectForKey:@"name"];
        NSNumber * barcodeNum = [record objectForKey:@"barcode"];
        NSString * barcode = [barcodeNum stringValue];
        NSString * category = [record objectForKey:@"category"];
        
        // create the bottle and retrieve the subtype
        AlcoholSubType * subType = [AlcoholSubType alcoholSubTypeFromName:category inManagedObjectContext:context];
        if (!subType || !category) {
            return; // don't add the bottle
        }
        Bottle * bottle = [Bottle newBottleForType:subType.parent inManagedObjectContext:context];
        bottle.barcode = barcode;
        bottle.name = name;
        bottle.userHasBottle = [NSNumber numberWithBool:NO];
        bottle.subType = subType;
        NSError *error; // save it
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
}

// Iterate through each subtype and set ordering for each bottle
static void *enterUserOrdering() {
    NSManagedObjectContext * context = managedObjectContext();
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription
                                   entityForName:@"AlcoholSubType"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError* err = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (AlcoholSubType *alcSubType in fetchedObjects) {
        // fetch all bottles and set ordering
        NSFetchRequest * fetchRequestBottles = [[NSFetchRequest alloc] init];
        NSEntityDescription * entityBottles = [NSEntityDescription entityForName:@"Bottle" inManagedObjectContext:context];
        fetchRequestBottles.predicate = [NSPredicate predicateWithFormat:@"subType.name = %@", alcSubType.name];
        [fetchRequestBottles setEntity:entityBottles];
        NSError * errorBottles = nil;
        NSArray * fetchedBottles = [context executeFetchRequest:fetchRequestBottles error:&errorBottles];
        for (Bottle * bottle in fetchedBottles) {
            NSUInteger index = [fetchedBottles indexOfObject:bottle];
            int value = (int)index;
            bottle.userOrdering = [NSNumber numberWithInt:value];
        }
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

// only for testing, enters some default inventory snapshots
//static void *enterInventorySnapshots() {
//    NSManagedObjectContext *context = managedObjectContext();
//    NSError * err = nil;
//    NSString * dataPath = [[NSBundle mainBundle] pathForResource:@"InventorySnapshotsForBottle" ofType:@"json"];
//    NSArray * Snapshots = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
//                                                          options:kNilOptions
//                                                       error:&err];
//    [Snapshots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        InventorySnapshotForBottle * snapShot = [NSEntityDescription insertNewObjectForEntityForName:@"InventorySnapshotForBottle" inManagedObjectContext:context];
//        Bottle * whichBottle = [Bottle bottleForName:[obj objectForKey:@"whichBottle"] inManagedObjectContext:context];
//        // there needs to be a safe gaurd here if this returns something empty
//        NSNumber * dateNum = [obj objectForKey:@"date"];
//        float floatNum = [dateNum floatValue];
//        NSDate * date = [NSDate dateWithTimeIntervalSince1970:floatNum];
//        
//        snapShot.date = date;
//        snapShot.whichBottle = whichBottle;
//        snapShot.count = [obj objectForKey:@"count"];
//        NSError *error;
//        if (![context save:&error]) {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }
//    }];
//}

//static void *printSnapShots() {
//    NSManagedObjectContext *context = managedObjectContext();
//    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InventorySnapshotForBottle"];
//    NSError *err;
//    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
//    for (InventorySnapshotForBottle * snapshot in fetchedObjects) {
//        NSLog(@"snapshot for bottle: %@ with count: %@", snapshot.whichBottle.name, snapshot.count);
//    }
//}

static void *printStoredBottles() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    // list out the bottles
    NSError *err; // save it
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Bottle"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (Bottle *bottle in fetchedObjects) {
        NSLog(@"Bottle: %@ for subType: %@:%@", bottle.name, bottle.subType.name, bottle.subType.parent.name);
    }
}

static void *printVarietals() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    // list out the bottles
    NSError *err; // save it
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Varietal"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (Varietal * varietal in fetchedObjects) {
        NSLog(@"VARIETAL %@ for SUBTYPE: %@", varietal.name, varietal.subType.name);
    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        enterTypes();
        
        enterSubTypes();

        enterVarietals();
        
        enterBottles();
        
        enterUserOrdering();
        
        printStoredBottles();
        
        printVarietals();
        
    }
    return 0;
}

