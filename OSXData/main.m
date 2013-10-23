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
#import "InventorySnapshotForBottle+Create.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Duck03";
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


static void *enterTypes() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    //create the categories and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AlcoholTypes" ofType:@"json"];
    NSArray* AlcoholTypes = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                            options:kNilOptions
                                                              error:&err];
    
    NSLog(@"Count of Types: %u", AlcoholTypes.count);
    
    [AlcoholTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [AlcoholType newTypeForName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    

    // list out the categories
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"AlcoholType"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (AlcoholType *type in fetchedObjects) {
        NSLog(@"Type Name: %@", type.name);
    }
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
    NSLog(@"Count of SubTypes: %u", SubTypes.count);
    
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"AlcoholSubType"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (AlcoholSubType *subType in fetchedObjects) {
        NSLog(@"SubType Name: %@", subType.name);
        NSLog(@"SubType Parent: %@", subType.parent.name);
    }
}

static void *enterBottles() {
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    
    //create the bottles and save them
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"Bottles" ofType:@"json"];
    NSArray * Bottles = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                       options:kNilOptions
                                                         error:&err];
    
    [Bottles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Bottle * bottle = [Bottle newBottleForName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        NSString * subTypeName = [obj objectForKey:@"subType"];
        AlcoholSubType * subType = [AlcoholSubType alcoholSubTypeFromName:subTypeName inManagedObjectContext:context];
        bottle.subType = subType;
        bottle.barcode = [obj objectForKey:@"barcode"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    
    // list out the bottles
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Bottle"
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (Bottle *bottle in fetchedObjects) {
        NSLog(@"Bottle name and barcode: %@, %@", bottle.name, bottle.barcode);
    }
}

static void *enterInventorySnapshots() {
    NSManagedObjectContext *context = managedObjectContext();
    NSError * err = nil;
    NSString * dataPath = [[NSBundle mainBundle] pathForResource:@"InventorySnapshotsForBottle" ofType:@"json"];
    NSArray * Snapshots = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                          options:kNilOptions
                                                       error:&err];
    [Snapshots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        InventorySnapshotForBottle * snapShot = [NSEntityDescription insertNewObjectForEntityForName:@"InventorySnapshotForBottle" inManagedObjectContext:context];
        Bottle * whichBottle = [Bottle bottleForName:[obj objectForKey:@"whichBottle"] inManagedObjectContext:context];
        // there needs to be a safe gaurd here if this returns something empty
        NSNumber * dateNum = [obj objectForKey:@"date"];
        float floatNum = [dateNum floatValue];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:floatNum];
        
        snapShot.date = date;
        snapShot.whichBottle = whichBottle;
        snapShot.count = [obj objectForKey:@"count"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
    
    // list out the snapshots
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InventorySnapshotForBottle"];
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
    for (InventorySnapshotForBottle * snapshot in fetchedObjects) {
        NSLog(@"snapshot for bottle: %@ with count: %@", snapshot.whichBottle.name, snapshot.count);
    }
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        enterTypes();
        
        enterSubTypes();
        
        enterBottles();
        
        enterInventorySnapshots();
        
    }
    return 0;
}

