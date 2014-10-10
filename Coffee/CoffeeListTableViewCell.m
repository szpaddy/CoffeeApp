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
    
}

@end
