//
//  CoffeeCardViewController.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeCardViewController.h"
#import "CoffeeCard.h"

@interface CoffeeCardViewController ()

@property (nonatomic, strong) UILabel *itemTitle;
@property (nonatomic, strong) UITextView *itemDescription;

@end

@implementation CoffeeCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.itemTitle = [[UILabel alloc] init];
    self.itemTitle.text = self.card.name;
    [self.itemTitle sizeToFit];
    
    [self.view addSubview:self.itemTitle];
    
    // Add share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 70, 34);
    shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareButton.layer.borderWidth = 1.0f;
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareSelected:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    const CGFloat leftPadding = 10.0f;
    CGRect itemTitleFrame = self.itemTitle.frame;
    itemTitleFrame.origin = CGPointMake(leftPadding, 10.0f);
    self.itemTitle.frame = itemTitleFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareSelected:(id)sender
{
    NSLog(@"Target fired");
}


@end
