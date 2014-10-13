//
//  CoffeeNavigationController.m
//  Coffee
//
//  Created by Robert Blafford on 10/12/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeNavigationController.h"

@implementation CoffeeNavigationController

// Forward rotation calls to view controllers in the navigation hierarchy
- (NSUInteger)supportedInterfaceOrientations
{
    if([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return(NSInteger)[self.topViewController performSelector:@selector(supportedInterfaceOrientations) withObject:nil];
    }
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    if([self.visibleViewController respondsToSelector:@selector(shouldAutorotate)])
    {
        BOOL autoRotate = (BOOL)[self.visibleViewController performSelector:@selector(shouldAutorotate) withObject:nil];
        return autoRotate;        
    }
    return NO;
}

@end
