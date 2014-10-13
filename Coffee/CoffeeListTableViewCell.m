//
//  CoffeeListTableViewCell.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeListTableViewCell.h"

const CGFloat DefaultAutoLayoutCellPadding = 15.0f;
const CGFloat DefaultAutoLayoutCellWidth = 230.0f; // Preferred width, will be resized if its bigger then actual image width

@interface CoffeeListTableViewCell ()

@property (nonatomic, getter=didAddConstraints) BOOL addedConstraints;

@property (nonatomic, strong) NSLayoutConstraint *dynamicHeightConstraint;

@property (nonatomic, strong) UILabel *customTextLabel;
@property (nonatomic, strong) UILabel *customDetailTextLabel;
@property (nonatomic, strong) UIImageView *lowerImageView;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation CoffeeListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *customTextLabel = [[UILabel alloc] init];
        UILabel *customDetailTextLabel = [[UILabel alloc] init];
        UIImageView *lowerImageView = [[UIImageView alloc] init];
        UIView *separatorLine = [[UIView alloc] init];
        
        customTextLabel.numberOfLines = 0;
        customDetailTextLabel.numberOfLines = 0;
        
        customTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds) - DefaultAutoLayoutCellPadding*2;
        customDetailTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds) - DefaultAutoLayoutCellPadding*2;
        
        customTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        lowerImageView.translatesAutoresizingMaskIntoConstraints = NO;
        customDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
        
        separatorLine.backgroundColor = [UIColor grayColor];
        lowerImageView.contentMode = UIViewContentModeScaleAspectFit;
        customTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18];
        customDetailTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:13];
        
        [self.contentView addSubview:customTextLabel];
        [self.contentView addSubview:customDetailTextLabel];
        [self.contentView addSubview:lowerImageView];
        [self.contentView addSubview:separatorLine];
        
        self.customTextLabel = customTextLabel;
        self.customDetailTextLabel = customDetailTextLabel;
        self.lowerImageView = lowerImageView;
        self.separatorLine = separatorLine;
    }
    return self;
}

- (void)updateConstraints
{
    UILabel *customTextLabel = self.customTextLabel;
    UILabel *customDetailTextLabel = self.customDetailTextLabel;
    UIImageView *lowerImageView = self.lowerImageView;
    UIView *separatorLine = self.separatorLine;
    
    CGFloat width = DefaultAutoLayoutCellWidth;
    CGFloat scale = width/lowerImageView.image.size.width;
    CGFloat imageHeight = (lowerImageView.image) ? lowerImageView.image.size.height * scale : 0;
    
    if (self.didAddConstraints)
    {
        // When view layout is detected theres no need to remove and create new constraints.
        self.dynamicHeightConstraint.constant = imageHeight; // Allow imageView to stretch out in height accordingly
        [super updateConstraints];
        return;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(customTextLabel, customDetailTextLabel, lowerImageView, separatorLine);
    NSDictionary *metrics = @{ @"imageHeight" : @(imageHeight),
                               @"width" : @(width),
                               @"padding" : @(DefaultAutoLayoutCellPadding),
                               @"separatorThickness" : @1,
                               };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[customTextLabel]-padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[customDetailTextLabel]-padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[lowerImageView(<=width)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[separatorLine]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[customTextLabel]-[customDetailTextLabel]-[lowerImageView]-[separatorLine(separatorThickness)]|" options:0 metrics:metrics views:views]];
    
    // Add height constraint to lowerImageView and save as an instance varaible so the we can resize the content view if an image is added after the cells creation
    NSLayoutConstraint *dynamicHeightConstraint = [NSLayoutConstraint constraintWithItem:lowerImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageHeight];
    [self.contentView addConstraint:dynamicHeightConstraint];
    self.dynamicHeightConstraint = dynamicHeightConstraint;
    
    self.addedConstraints = YES;
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (UILabel *)textLabel
{
    return _customTextLabel;
}

- (UILabel *)detailTextLabel
{
    return _customDetailTextLabel;
}
  
- (UIImageView *)imageView
{
    return _lowerImageView;
}

@end
