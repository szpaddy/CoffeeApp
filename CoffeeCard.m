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
#import <NSObject+RACPropertySubscribing.h>
#import <ReactiveCocoa/RACSignal.h>

@implementation CoffeeCard

@dynamic desc;
@dynamic id;
@dynamic image_url;
@dynamic name;
@dynamic imageData;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
        
    [RACObserve(self, image_url) subscribeNext:^(id x) {
        // When the image_url changes asynchronously start a new download for the image
        [self downloadImageData:x];
    }];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    [RACObserve(self, image_url) subscribeNext:^(id x) {
        // When the image_url changes asynchronously start a new download for the image
        [self downloadImageData:x];
    }];
}

- (void)downloadImageData:(NSString*)imageUrl
{
    if (!imageUrl || [imageUrl isEqualToString:@""])
        return;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:imageUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.imageData = UIImagePNGRepresentation(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to download imageData");
    }];

}

@end
