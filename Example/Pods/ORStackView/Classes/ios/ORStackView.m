//
//  ORStackView.m
//  ORStackView
//
//  Created by Orta on 10/09/2013.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORStackView.h"
#import <FLKAutoLayout/UIView+FLKAutoLayout.h>
#import "ORStackView+Private.h"

@interface ORStackView()

/// Delay updating constraints when true
@property (nonatomic, assign) BOOL batchingUpdates;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end

@implementation ORStackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self _setup];

    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)awakeFromNib
{
    [self _setup];
}

- (void)_setup
{
    _viewStack = [NSMutableArray array];
    _bottomMarginHeight = 0;
}

- (void)updateConstraints
{
    // Remove all constraints
    for (StackView *stackView in self.viewStack) {
        [self removeConstraint:stackView.topConstraint];
    }

    // Add the new constraints
    for (StackView *stackView in self.viewStack) {
        UIView *view = stackView.view;
        NSString *predicate = stackView.constraintPredicate ?: @"0";
        NSInteger index = [self.viewStack indexOfObject:stackView];

        if (index == 0) {
            if (self.topLayoutGuide) {
                id topLayoutGuide = self.topLayoutGuide;
                NSString *vhl = [NSString stringWithFormat:@"V:[topLayoutGuide]-%@-[view]", predicate];
                NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:vhl options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(view, topLayoutGuide)];
                [self addConstraints:constraints];
                stackView.topConstraint = [constraints firstObject];
            } else {
                stackView.topConstraint = [view alignTopEdgeWithView:self predicate:predicate];
            }
        } else {

            UIView *viewAbove = [self.viewStack[index - 1] view];
            stackView.topConstraint = [view constrainTopSpaceToView:viewAbove predicate:predicate];
        }
    }

    if (self.bottomMarginHeight != NSNotFound) {
        [self removeConstraint:self.bottomConstraint];
        UIView *lastView = self.lastView;
        if (self.lastView) {
            NSString *constraint = [NSString stringWithFormat:@"%0.0f", self.bottomMarginHeight];
            self.bottomConstraint = [self alignBottomEdgeWithView:lastView predicate:constraint];
        }
    }

    [super updateConstraints];
}

#pragma mark - Adding Subviews

- (void)addSubview:(UIView *)view withTopMargin:(NSString *)margin
{
    [self _addSubview:view withTopMargin:margin centered:NO sideMargin:nil];
}

- (void)addSubview:(UIView *)view withTopMargin:(NSString *)topMargin sideMargin:(NSString *)sideMargin
{
    [self _addSubview:view withTopMargin:topMargin centered:YES sideMargin:sideMargin];
}

- (void)_addSubview:(UIView *)view withTopMargin:(NSString *)topMargin centered:(BOOL)centered sideMargin:(NSString *)sideMargin
{
    NSInteger index = self.viewStack.count;
    [self _insertSubview:view atIndex:index withTopMargin:topMargin centered:centered sideMargin:sideMargin];
}

#pragma mark - Inserting Subviews

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index withTopMargin:(NSString *)margin;
{
    [self _insertSubview:view atIndex:index withTopMargin:margin centered:NO sideMargin:nil];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index withTopMargin:(NSString *)topMargin sideMargin:(NSString *)sideMargin
{
    [self _insertSubview:view atIndex:index withTopMargin:topMargin centered:YES sideMargin:sideMargin];
}


- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview withTopMargin:(NSString *)margin
{
    BOOL hasSibling = [self.subviews containsObject:siblingSubview];
    NSInteger index = hasSibling ? [self indexOfView:siblingSubview] : self.viewStack.count;
    [self _insertSubview:view atIndex:index withTopMargin:margin centered:NO sideMargin:nil];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview withTopMargin:(NSString *)margin
{
    NSAssert([self.subviews containsObject:siblingSubview], @"SiblingSubview not found in ORStackView");

    NSInteger index = [self indexOfView:siblingSubview] - 1;
    [self _insertSubview:view atIndex:index withTopMargin:margin centered:NO sideMargin:nil];
}

- (void)_insertSubview:(UIView *)view atIndex:(NSInteger)index withTopMargin:(NSString *)topMargin centered:(BOOL)centered sideMargin:(NSString *)sideMargin
{
    NSParameterAssert(view);
    if ([self.subviews containsObject:view]) return;

    [super addSubview:view];

    StackView *stackView = [[StackView alloc] init];
    stackView.view = view;
    stackView.constraintPredicate = topMargin;
    [self.viewStack insertObject:stackView atIndex:index];

    if (centered) {
        NSString *newSidemargin;
        if ([sideMargin rangeOfString:@"-"].location == NSNotFound) {
            NSMutableString *mutableSideMargin = [sideMargin mutableCopy];
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[0-9]" options:0 error:NULL];
            NSInteger matchLocation = [regex rangeOfFirstMatchInString:mutableSideMargin options:0 range:NSMakeRange(0, [mutableSideMargin length])].location;
            [mutableSideMargin insertString:@"-" atIndex:matchLocation];
            newSidemargin = [mutableSideMargin copy];
        } else {
            newSidemargin = [sideMargin stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }

        if ([newSidemargin rangeOfString:@">"].location != NSNotFound) {
            newSidemargin = [newSidemargin stringByReplacingOccurrencesOfString:@">" withString:@"<"];
        } else if ([newSidemargin rangeOfString:@"<"].location != NSNotFound) {
            newSidemargin = [newSidemargin stringByReplacingOccurrencesOfString:@"<" withString:@">"];
        }

        [view constrainWidthToView:self predicate:newSidemargin];
        [view alignCenterXWithView:self predicate:nil];
    }

    if (!self.batchingUpdates) [self setNeedsUpdateConstraints];
}

#pragma mark Removal

- (void)removeSubview:(UIView *)subview
{
    if (![self.subviews containsObject:subview]) return;

    [subview removeFromSuperview];

    for (StackView *stackView in self.viewStack.copy) {
        if ([subview isEqual:stackView.view]) {
            [self.viewStack removeObject:stackView];
        }
    }

    if (!self.batchingUpdates) [self setNeedsUpdateConstraints];
}

- (void)removeAllSubviews
{
    for (StackView *stackView in [self.viewStack copy]) {
        [self.viewStack removeObject:stackView];
        [stackView.view removeFromSuperview];
    }

    if (!self.batchingUpdates) [self setNeedsUpdateConstraints];
}

#pragma mark Batching

- (void)performBatchUpdates:(void (^)(void))updates;
{
    NSParameterAssert(updates);

    self.batchingUpdates = YES;
    updates();
    self.batchingUpdates = NO;

    [self setNeedsUpdateConstraints];
}

- (void)addViewController:(UIViewController *)viewController toParent:(UIViewController *)parentViewController withTopMargin:(NSString *)margin
{
    [viewController willMoveToParentViewController:parentViewController];
    [parentViewController addChildViewController:viewController];
    [self addSubview:viewController.view withTopMargin:margin];
    [viewController didMoveToParentViewController:parentViewController];
}

- (void)addViewController:(UIViewController *)viewController toParent:(UIViewController *)parentViewController withTopMargin:(NSString *)margin sideMargin:(NSString *)sideMargin;
{
    [viewController willMoveToParentViewController:parentViewController];
    [parentViewController addChildViewController:viewController];
    [self addSubview:viewController.view withTopMargin:margin sideMargin:sideMargin];
    [viewController didMoveToParentViewController:parentViewController];
}


#pragma mark Helper functions

- (NSInteger)indexOfView:(UIView *)view
{
    for (StackView *stackView in self.viewStack) {
        if ([view isEqual:stackView.view]) {
            return [self.viewStack indexOfObject:stackView];
        }
    }
    return NSNotFound;
}

- (NSLayoutConstraint *)topConstraintForView:(UIView *)view
{
    for (StackView *stackView in self.viewStack) {
        if ([view isEqual:stackView.view]) {
            return stackView.topConstraint;
        }
    }
    return nil;
}

- (BOOL)updateTopMargin:(NSString *)topMargin forView:(UIView *)view
{
    for (StackView *stackView in self.viewStack) {
        if ([view isEqual:stackView.view]) {
            stackView.constraintPredicate = topMargin;
            if (!self.batchingUpdates) [self setNeedsUpdateConstraints];
            return YES;
        }
    }

    return NO;
}

- (UIView *)firstView
{
    return [[self.viewStack firstObject] view];
}

- (UIView *)lastView
{
    return [[self.viewStack lastObject] view];
}

#pragma mark - Layout Guides

- (void)setTopLayoutGuide:(id<UILayoutSupport>)topLayoutGuide {
    _topLayoutGuide = topLayoutGuide;
    [self needsUpdateConstraints];
}

@end
