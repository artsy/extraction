//
//  ORStackScrollView.m
//  ARAutoLayoutStackExample
//
//  Created by Orta on 10/09/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <FLKAutoLayout/UIView+FLKAutoLayout.h>
#import "ORStackScrollView.h"

@interface ORStackScrollView()

@end

@implementation ORStackScrollView

- (instancetype)init
{
    return [self initWithStackViewClass:[ORStackView class]];
}

- (instancetype)initWithStackViewClass:(Class)klass
{
    NSAssert([klass isSubclassOfClass:[ORStackView class]], @"Class for ORStackScrollView must be a ORStackView subclass");

    self = [super init];
    if (!self) return self;

    [self _loadStackView:klass];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _loadStackView:[ORStackView class]];
    }

    return self;
}

- (void)_loadStackView:(Class)klass {
    _stackView = [[klass alloc] init];
    _stackView.bottomMarginHeight = 0;

    [self addSubview:_stackView];
    [_stackView alignToView:self];
    [_stackView constrainWidthToView:self predicate:@""];
}

@end
