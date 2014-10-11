//
//  CoffeeCard+Utility.h
//  Coffee
//
//  Created by Robert Blafford on 10/10/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCard.h"

@interface CoffeeCard (Utility)

+ (CoffeeCard*)coffeeCardWithInfo:(NSDictionary*)coffeeInfo inManagedObjectContext:(NSManagedObjectContext*)context;

@end
