//
//  CoffeeCard.m
//  Coffee
//
//  Created by Robert Blafford on 10/10/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCard.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <AFNetworking/AFURLResponseSerialization.h>

@implementation CoffeeCard

@dynamic desc;
@dynamic id;
@dynamic image_url;
@dynamic name;
@dynamic imageData;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    [self observeImageUrl];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    [self observeImageUrl];
}

- (void)willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"image_url"];
}

- (void)observeImageUrl
{
    [self addObserver:self forKeyPath:@"image_url" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

// When the image_url changes asynchronously start a new download for the image
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image_url"])
    {
        NSString *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue && ![newValue isEqualToString:@""] && ![newValue isEqualToString:oldValue])
        {
            [self downloadImageData:newValue];
        }
    }
}

- (void)downloadImageData:(NSString*)imageUrl
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:imageUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.imageData = UIImagePNGRepresentation(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to download imageData");
    }];

}

@end
