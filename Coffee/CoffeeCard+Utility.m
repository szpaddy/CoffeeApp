//
//  CoffeeCard+Utility.m
//  Coffee
//
//  Created by Robert Blafford on 10/10/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCard+Utility.h"

NSString * const CoffeeItemUniqueIdentifier = @"id";
NSString * const CoffeeItemNameString = @"name";
NSString * const CoffeeItemImageUrlString = @"image_url";
NSString * const CoffeeItemDescriptionString = @"desc";

@implementation CoffeeCard (Utility)

// This method queries the database for an object with a matching unique identifier.
// If one exists it returns that object.
// If none exist we create a new object, insert it into the db and return it.
+ (CoffeeCard*)coffeeCardWithInfo:(NSDictionary*)coffeeInfo inManagedObjectContext:(NSManagedObjectContext*)context 
{
    CoffeeCard *coffeeCard = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoffeeCard"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", coffeeInfo[CoffeeItemUniqueIdentifier]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || [matches count] > 1)
        NSLog(@"Error when attempting to fetch CoffeeCard entity");
    if ([matches count] == 1)
        coffeeCard = [matches firstObject];
    else if ([matches count] == 0)
    {
        coffeeCard = [NSEntityDescription insertNewObjectForEntityForName:@"CoffeeCard" inManagedObjectContext:context];
        coffeeCard.name = coffeeInfo[CoffeeItemNameString];
        coffeeCard.id = coffeeInfo[CoffeeItemUniqueIdentifier];
        coffeeCard.image_url = coffeeInfo[CoffeeItemImageUrlString];
        coffeeCard.desc = coffeeInfo[CoffeeItemDescriptionString];
    }

    return coffeeCard;
}

@end
