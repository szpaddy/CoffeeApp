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

const CGFloat DefaultAutoLayoutPadding = 15.0f;
NSString * const CoffeeDetailDescriptionString = @"desc";
NSString * const CoffeeDetailLastUpdatedString = @"last_updated_at";

@interface NSDate (utility)

- (NSString *)lastUpdatedString;

@end

@implementation NSDate (utility)

- (NSString *)lastUpdatedString
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:self toDate:[NSDate date] options:0];
    if (breakdownInfo.year >= 1)
        return [NSString stringWithFormat:@"Updated %ld %@ ago", (long)breakdownInfo.year, (breakdownInfo.year > 1 ? @"years" : @"year")];
    else if (breakdownInfo.month >= 1)
        return [NSString stringWithFormat:@"Updated %ld %@ ago", (long)breakdownInfo.month, (breakdownInfo.month > 1 ? @"months" : @"month")];
    else if (breakdownInfo.day >= 1)
        return [NSString stringWithFormat:@"Updated %ld %@ ago", (long)breakdownInfo.day, (breakdownInfo.day > 1 ? @"days" : @"day")];
    
    return @"Updated less then a day ago";
}

@end

@interface CoffeeCardViewController ()

@property (nonatomic, strong) UILabel *itemDescription;
@property (nonatomic, strong) UILabel *lastUpdated;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation CoffeeCardViewController

#pragma mark - View lifecycle 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    
    UIView* contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];
    
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
    description.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - DefaultAutoLayoutPadding*2; // This is necessary to allow the label to use multi-line text properly
    description.text = self.coffeeItem.desc;
    [contentView addSubview:description];
    
    UILabel *lastUpdated = [[UILabel alloc] init];
    lastUpdated.translatesAutoresizingMaskIntoConstraints = NO;
    lastUpdated.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14];
    [contentView addSubview:lastUpdated];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor redColor];
    imageView.image = [UIImage imageWithData:self.coffeeItem.imageData];
    [contentView addSubview:imageView];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [contentView addSubview:self.activityView];
    
    // Auto Layout subviews

    // When using UIViewContentModeScaleAspectFit the imageView will attempt to scale the image until its biggest side sits flush with the target area.
    // Therefore empty space will be applied to either the side or top. Lets use the imageHeight variable to tell the autoLayout system to shrink the imageViews frame to be the same size as the image. The result is that the image will have a fixed with, be scaled correctly, and not appear so be shifted to the right or lower then expected.
    CGFloat width = (CGRectGetWidth(self.view.bounds) - DefaultAutoLayoutPadding*2);
    CGFloat scale = width/imageView.image.size.width;
    CGFloat imageHeight = (imageView.image) ? imageView.image.size.height * scale : 0;

    UIView *mainView = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(title, line, description, imageView, lastUpdated, contentView, scrollView, mainView);
    NSDictionary *metrics = @{ @"padding" : @(DefaultAutoLayoutPadding),
                               @"width" : @(width),
                               @"imageHeight" : @(imageHeight),
                               @"lineThickness" : @2 };

    // All subviews should be padding px away from the left edge of the superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[title]-padding-|" options:0 metrics:metrics views:views]];

    // Set line to begin at padding x coordinate and have a width until the end of its superview
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[line]|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[description]-padding-|" options:0 metrics:metrics views:views]];
    
    // Set imageView tobe <=width in length and height, so the image will shrink its width in the event that there would be leftover space on the left and right sides
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[imageView(<=width)]" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[lastUpdated]-padding-|" options:0 metrics:metrics views:views]];
    
    // Vertically align all components one after the other with padding px as the space between them.
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[title]-padding-[line(lineThickness)]-padding-[description]-padding-[imageView(<=imageHeight)]-padding-[lastUpdated]-padding-|" options:0 metrics:metrics views:views]];
    
    // AutoLayout is notorious for not working well with UIScrollViews. These constraints will pin the backing views to eachother
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:0 views:views]];
    
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:0 views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:views]];
    
    // This will make the contentView equal to the main view, otherwise when rotating the contentView will not expand
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:views]];
        
    self.itemDescription = description;
    self.lastUpdated = lastUpdated;
    
    // Add share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 70, 25);
    shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareButton.layer.borderWidth = 1.0f;
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [shareButton addTarget:self action:@selector(shareSelected:) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Fetch additional details about this coffee item such as the last time the page was updated and a detailed description
    [self loadCoffeeItemDetail];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Instance methods

- (void)loadCoffeeItemDetail
{
    [self.activityView startAnimating];
    
    __weak CoffeeCardViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"WuVbkuUsCXHPx3hsQzus4SE" forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"https://coffeeapi.percolate.com/api/coffee/%@", weakSelf.coffeeItem.id] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        weakSelf.itemDescription.text = responseObject[CoffeeDetailDescriptionString];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        // Example Date: 2014-10-04 01:44:49.285430, remove everything after the decimal
        NSString *dateString = responseObject[CoffeeDetailLastUpdatedString];
        NSRange rangeForChar = [dateString rangeOfString:@"."];
        dateString = (rangeForChar.location != NSNotFound) ? [dateString substringToIndex:rangeForChar.location] : dateString;
        
        weakSelf.lastUpdated.text = [[dateFormatter dateFromString:dateString] lastUpdatedString];
        
        [weakSelf.activityView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to make detailed request for coffee entity: %@", error);
        [weakSelf.activityView stopAnimating];
    }];
}

#pragma mark - Custom event handlers

- (void)shareSelected:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.coffeeItem.image_url] applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
}

@end
