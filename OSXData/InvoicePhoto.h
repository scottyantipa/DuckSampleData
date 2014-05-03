//
//  InvoicePhoto.h
//  Duck
//
//  Created by Scott Antipa on 5/3/14.
//  Copyright (c) 2014 Scott Antipa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invoice;

@interface InvoicePhoto : NSManagedObject

@property (nonatomic, retain) NSString * documentName;
@property (nonatomic, retain) Invoice *invoice;

@end
