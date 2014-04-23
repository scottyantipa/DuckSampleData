//
//  OrderForBottle+Create.h
//  Duck03
//
//  Created by Scott Antipa on 9/17/13.
//  Copyright (c) 2013 Scott Antipa. All rights reserved.
//

#import "OrderForBottle.h"
#import "Order+Create.h"
#import "Bottle+Create.h"

@interface OrderForBottle (Create)
+(OrderForBottle *)newOrderForBottle:(Bottle *)bottle
                                forOrder:(Order *)order
                  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
