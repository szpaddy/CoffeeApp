//
//  CoffeeListTableViewCell.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeListTableViewCell.h"

@interface CoffeeListTableViewCell ()

@property (nonatomic, getter=didAddConstraints) BOOL addedConstraints;

@property (nonatomic, strong) UILabel *customTextLabel;
@property (nonatomic, strong) UILabel *customDetailTextLabel;
@property (nonatomic, strong) UIImageView *lowerImageView;

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
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)updateConstraints
{
    if (self.didAddConstraints)
    {
        [super updateConstraints];
        return;
    }
    
    UILabel *customTextLabel = self.customTextLabel;
    UILabel *customDetailTextLabel = self.customDetailTextLabel;
    UIImageView *lowerImageView = self.lowerImageView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(customTextLabel, customDetailTextLabel, lowerImageView);
    NSDictionary *metrics = @{ @"imageDimensions" : @100,
                               @"paddingHeight" : @5 ,
                               @"paddingWidth" : @15 ,
                               @"width" : @(CGRectGetWidth(self.contentView.bounds) - 15)
                               };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-paddingWidth-[customTextLabel(width)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-paddingWidth-[customDetailTextLabel(width)]-paddingWidth-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-paddingWidth-[lowerImageView(<=imageDimensions)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-paddingHeight-[customTextLabel]-2-[customDetailTextLabel]-paddingHeight-[lowerImageView(<=imageDimensions)]-paddingHeight-|" options:0 metrics:metrics views:views]];

    self.addedConstraints = YES;
    [super updateConstraints];
}

- (void)setupCell
{
    UILabel *customTextLabel = [[UILabel alloc] init];
    UILabel *customDetailTextLabel = [[UILabel alloc] init];
    UIImageView *lowerImageView = [[UIImageView alloc] init];
    
    customTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18];
    customDetailTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:13];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:customTextLabel];
    [self.contentView addSubview:customDetailTextLabel];
    [self.contentView addSubview:lowerImageView];
    
    customTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    lowerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    customDetailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customTextLabel = customTextLabel;
    self.customDetailTextLabel = customDetailTextLabel;
    self.lowerImageView = lowerImageView;
    
    [self setNeedsUpdateConstraints];
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
