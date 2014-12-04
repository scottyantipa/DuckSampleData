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
#import "WineBottle+Create.h"

const BOOL REMOTE = NO;

NSMutableString * stringForRemote() {
    return [[NSMutableString alloc] initWithString:@"http://ec2-54-82-243-92.compute-1.amazonaws.com:3333/"];
}

NSMutableString * stringForLocal() {
    return [[NSMutableString alloc] initWithString:@"http://10.0.1.23:3333/"];
}

NSMutableString * baseUrl() {
    return REMOTE ? stringForRemote() : stringForLocal();
}

NSMutableString * baseBottleUrl() {
    NSMutableString * base = baseUrl();
    [base appendString:[NSString stringWithFormat:@"bottle"]];
    return base;
}

//
// urls for json data
//
NSMutableString * baseVarietalUrl() {
    NSMutableString * base = baseUrl();
    [base appendString:@"varietals"];
    return base;
}

NSMutableString * baseSubTypesUrl() {
    NSMutableString * base = baseUrl();
    [base appendString:@"alcoholSubTypes"];
    return base;
}

NSMutableString * baseTypesUrl() {
    NSMutableString * base = baseUrl();
    [base appendString:@"alcoholTypes"];
    return base;
}



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

    
    // fetch types
    NSURL * url = [[NSURL alloc] initWithString:baseTypesUrl()];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSError * fetchSubTypesErr;
    NSURLResponse * response;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&fetchSubTypesErr];
    NSError * serialErr;
    NSMutableArray * types = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];
    
    
    for (NSDictionary * obj in types) {
        [AlcoholType newTypeForName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

static void *enterSubTypes() {
    // create context
    
    // fetch sub stypes
    NSManagedObjectContext *context = managedObjectContext();
    NSURL * url = [[NSURL alloc] initWithString:baseSubTypesUrl()];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSError * fetchSubTypesErr;
    NSURLResponse * response;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&fetchSubTypesErr];
    NSError * serialErr;
    NSMutableArray * subTypes = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];
    
    for (NSDictionary * obj in subTypes) {
        AlcoholSubType * subType = [AlcoholSubType newSubTypeFromName:[obj objectForKey:@"name"] inManagedObjectContext:context];
        AlcoholType * parent = [AlcoholType alcoholTypeFromName:[obj objectForKey:@"parentType"] inManagedObjectContext:context];
        subType.parent = parent;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
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
    // get varietals from server
    NSURL * url = [[NSURL alloc] initWithString:baseVarietalUrl()];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSError * varietalsFetchErr;
    NSURLResponse * response;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&varietalsFetchErr];
    NSError * serialErr;
    NSArray * varietals = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];

    // create context
    NSManagedObjectContext *context = managedObjectContext();

    for (NSDictionary * obj in varietals) {
        NSString * subTypeName = [obj objectForKey:@"subType"];
        NSString * name = [obj objectForKey:@"name"];
        if (subTypeName == nil || [subTypeName isEqualToString:@""] || name == nil || [name isEqualToString:@""]) {
            continue;
        }
        AlcoholSubType * subType = [AlcoholSubType alcoholSubTypeFromName:subTypeName inManagedObjectContext:context];
        if (subType == nil) {
            continue;
        }
        Varietal * varietal = [AlcoholSubType newVarietalForSubType:subType inContext:context];
        varietal.name = name;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

static void *enterBottles() {
    NSURL * url = [[NSURL alloc] initWithString:baseBottleUrl()];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    NSURLResponse * response;
    NSError * error;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSError * serialErr;
    NSDictionary * bottles = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serialErr];
    
    // create context
    NSManagedObjectContext *context = managedObjectContext();
    
    [bottles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        // unpack all the info from the record
        NSString * name = [obj objectForKey:@"name"];
        NSNumber * barcodeNum = [obj objectForKey:@"barcode"];
        NSString * barcode = [barcodeNum stringValue];
        NSString * alcoholSubType = [obj objectForKey:@"alcoholSubType"];
        NSString * alcoholType = [obj objectForKey:@"alcoholType"];
        
        // create the bottle and retrieve the subtype
        AlcoholSubType * subType = [AlcoholSubType alcoholSubTypeFromName:alcoholSubType inManagedObjectContext:context];
        AlcoholType * type = [AlcoholType alcoholTypeFromName:alcoholType inManagedObjectContext:context];
        if (!subType || !alcoholSubType) {
            return; // don't add the bottle
        }
        NSString * producerName = [obj objectForKey:@"producer"];
        Producer * producer = [Bottle producerForName:producerName inContext:context];
        if (producer == nil) {
            producer = [Bottle newProducerForName:producerName inContext:context];
        }
        if ([alcoholType isEqualToString:@"Wine"]) {
            // NOTE: There is repeated code for Wine vs Bottle creation below (not sure how to do it otherwise)
            NSString * varietalName = [obj objectForKey:@"varietal"];
            Varietal * varietal = [AlcoholSubType varietalForName:varietalName inContext:context];
            WineBottle * bottle = [Bottle newWineBottleForName:name varietal:varietal inManagedObjectContext:context];
            bottle.producer = producer;
            bottle.userHasBottle = [NSNumber numberWithBool:NO];
            bottle.subType = subType;
            bottle.barcode = barcode;
            bottle.type = type;
        } else {
            Bottle * bottle = [Bottle newBottleForType:subType.parent inManagedObjectContext:context];
            bottle.barcode = barcode;
            bottle.name = name;
            bottle.userHasBottle = [NSNumber numberWithBool:NO];
            bottle.subType = subType;
            bottle.type = type;
            bottle.producer = producer;
        }
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

