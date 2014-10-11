//
//  CoffeeCard+Utility.m
//  Coffee
//
//  Created by Robert Blafford on 10/10/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCard+Utility.h"

@implementation CoffeeCard (Utility)

+ (CoffeeCard*)coffeeCardWithInfo:(NSDictionary*)coffeeInfo inManagedObjectContext:(NSManagedObjectContext*)context
{
    CoffeeCard *coffeeCard = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoffeeCard"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", coffeeInfo[@"id"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || [matches count] > 1)
        NSLog(@"Error when attempting to fetch CoffeeCard entity");
    if ([matches count] == 1)
        coffeeCard = [matches firstObject];
    else if ([matches count] == 0)
    {
        coffeeCard = [NSEntityDescription insertNewObjectForEntityForName:@"CoffeeCard" inManagedObjectContext:context];
        coffeeCard.name = coffeeInfo[@"name"];
        coffeeCard.id = coffeeInfo[@"id"];
        coffeeCard.image_url = coffeeInfo[@"image_url"];
        coffeeCard.desc = coffeeInfo[@"desc"];
    }

    return coffeeCard;
}

@end
