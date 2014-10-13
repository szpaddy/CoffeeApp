//
//  CoffeeNavigationBar.m
//  Coffee
//
//  Created by Robert Blafford on 10/12/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeNavigationBar.h"

@interface UIImageView (resizable)

+ (UIImageView *)imageViewWithImage:(UIImage *)image andSize:(CGSize)size;

@end

@implementation UIImageView (resizable)

+ (UIImageView *)imageViewWithImage:(UIImage *)image andSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:destImage];
}

@end

@interface CoffeeNavigationBar ()

@property (nonatomic, strong) UIImageView *titleImage;

@end

@implementation CoffeeNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translucent = NO;
        self.barTintColor = [UIColor colorWithRed:0.949 green:0.4 blue:0.13 alpha:0.0];
        
        // Add a logo to the navigation bar and center it using autolayout
        UIImageView *titleImage = [UIImageView imageViewWithImage:[UIImage imageNamed:@"Drip"] andSize:CGSizeMake(35, 40)];
        [self addSubview:titleImage];
        self.titleImage = titleImage;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleImage.center = CGPointMake(self.center.x, self.center.y / 2);
    
    self.titleImage.hidden = UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation);
}

@end
