//
//  OrderForBottle+Create.m
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "OrderForBottle+Create.h"

@implementation OrderForBottle (Create)
+(OrderForBottle *)newOrderForBottle:(Bottle *)bottle
                                forOrder:(Order *)order
                  inManagedObjectContext:(NSManagedObjectContext *)context {
    OrderForBottle * orderForBottle = [NSEntityDescription insertNewObjectForEntityForName:@"OrderForBottle" inManagedObjectContext:context];
    orderForBottle.whichBottle = bottle;
    orderForBottle.whichOrder = order;
    return orderForBottle;
}
@end
