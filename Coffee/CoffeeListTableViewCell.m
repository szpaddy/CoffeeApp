//
//  CoffeeListTableViewCell.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeListTableViewCell.h"

@interface CoffeeListTableViewCell ()

@end

@implementation CoffeeListTableViewCell

- (id)init
{
    self = [super init];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setupCell
{
//    self.imageView.image = [UIImage imageNamed:@"Logo.png"];
//
//    UILabel *textLabel = self.textLabel;
//    UILabel *detailTextLabel = self.detailTextLabel;
//    UIImageView *imageView = self.imageView;
//    
//    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    imageView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    NSDictionary *views = NSDictionaryOfVariableBindings(textLabel, detailTextLabel, imageView);
//    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textLabel]-[detailTextLabel]-[imageView]-|" options:0 metrics:nil views:views];
//    [self addConstraints:constraints];
}

@end
