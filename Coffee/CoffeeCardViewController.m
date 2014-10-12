//
//  CoffeeCardViewController.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCardViewController.h"
#import "CoffeeCard.h"
#import <AFNetworking/AFNetworking.h>

@interface NSDate (utility)

- (NSString *)lastUpdatedString;

@end

@implementation NSDate (utility)

- (NSString *)lastUpdatedString
{
    // Get conversion to months, days, hours, minutes
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]  toDate:self  options:0];
    if (breakdownInfo.year >= 1)
        [NSString stringWithFormat:@"Updated %ldi %@ ago", (long)breakdownInfo.year, (breakdownInfo.year > 1 ? @"years" : @"year")];
    else if (breakdownInfo.month >= 1)
        [NSString stringWithFormat:@"Updated %ldi %@ ago", (long)breakdownInfo.month, (breakdownInfo.month > 1 ? @"months" : @"month")];
    else if (breakdownInfo.day >= 1)
        [NSString stringWithFormat:@"Updated %ldi %@ ago", (long)breakdownInfo.day, (breakdownInfo.day > 1 ? @"days" : @"day")];
    
    return @"Updated less then a day ago";
}

@end

@interface CoffeeCardViewController ()

@property (nonatomic, strong) UILabel *itemDescription;
@property (nonatomic, strong) UILabel *lastUpdated;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation CoffeeCardViewController

#pragma mark - View lifecycle 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentView];
    
    // Instantiate and initialize subviews
    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:32];
    title.text = self.coffeeItem.name;
    [contentView addSubview:title];
    
    UIView *line = [[UIView alloc] init];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    line.backgroundColor = [UIColor grayColor];
    [contentView addSubview:line];
    
    UILabel *description = [[UILabel alloc] init];
    description.translatesAutoresizingMaskIntoConstraints = NO;
    description.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:21];
    description.numberOfLines = 0;
    description.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - 15.0; // This is necessary to allow the label to use multi-line text properly
    description.text = self.coffeeItem.desc;
    [contentView addSubview:description];
    
    UILabel *lastUpdated = [[UILabel alloc] init];
    lastUpdated.translatesAutoresizingMaskIntoConstraints = NO;
    lastUpdated.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14];
    [contentView addSubview:lastUpdated];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageWithData:self.coffeeItem.imageData];
    [contentView addSubview:imageView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.view.center;
    [contentView addSubview:self.activityIndicator];
    
    // Auto Layout subviews

    // When using UIViewContentModeScaleAspectFit the imageView will attempt to scale the image until its biggest side sits flush with the target area
    // Therefore empty space will be applied to either the side or top, lets use the imageHeight variable to tell the autoLayout system to perfectly size the image. The result is that the image will have a fixed with, be scaled correctly, and not appear so be shifted to the right or lower then expected.
    CGFloat width = (CGRectGetWidth(self.view.bounds) - 30.0);
    CGFloat scale = width/imageView.image.size.width;
    CGFloat imageHeight = (imageView.image) ? imageView.image.size.height * scale : 0;

    NSDictionary *views = NSDictionaryOfVariableBindings(title, line, description, imageView, lastUpdated, contentView);
    NSDictionary *metrics = @{ @"padding" : @15.0,
                               @"width" : @(width),
                               @"imageHeight" : @(imageHeight),
                               @"lineThickness" : @2 };

    // All subviews should be padding px away from the left edge of the superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[title]-padding-|" options:0 metrics:metrics views:views]];

    // Set line to be line width px wide and lineHeight px high
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[line]|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[description]-padding-|" options:0 metrics:metrics views:views]];
    
    // Set imageView tobe <=imageEdge in length and height, so if imageView.image == nil then the lastUpdated uilabel will shift up to be underneath the description label
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[imageView(width)]-padding-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[lastUpdated]-padding-|" options:0 metrics:metrics views:views]];
    
    // Vertically align all components one after the other with padding px as the space between them.
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-padding-[line(lineThickness)]-padding-[description]-padding-[imageView(imageHeight)]-padding-[lastUpdated]-padding-|" options:0 metrics:metrics views:views]];
    
    // Keep the content scrollviews frame to be that of self.view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:views]];
    
    self.itemDescription = description;
    self.lastUpdated = lastUpdated;
    
    // Add share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 70, 34);
    shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareButton.layer.borderWidth = 1.0f;
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareSelected:) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch additional details about this coffee item such as the last time the page was updated and a detailed description
    [self loadCoffeeItemDetail];
}

#pragma mark - Instance methods

- (void)loadCoffeeItemDetail
{
    [self.activityIndicator startAnimating];
    
    __weak CoffeeCardViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"WuVbkuUsCXHPx3hsQzus4SE" forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"https://coffeeapi.percolate.com/api/coffee/%@", weakSelf.coffeeItem.id] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        weakSelf.itemDescription.text = responseObject[@"desc"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        // Example Date: 2014-10-04 01:44:49.285430
        NSString *dateString = responseObject[@"last_updated_at"];
        NSRange rangeForChar = [dateString rangeOfString:@"."];
        dateString = (rangeForChar.location != NSNotFound) ? [dateString substringToIndex:rangeForChar.location] : dateString;
        
        weakSelf.lastUpdated.text = [[dateFormatter dateFromString:dateString] lastUpdatedString];
        
        [weakSelf.activityIndicator stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to make detailed request for coffee entity");
    }];
}

#pragma mark - Custom event handlers

- (void)shareSelected:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.coffeeItem.image_url] applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
}


@end
