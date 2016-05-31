#import "ARSpinner.h"
#import "UIView+ARSpinner.h"

#if __has_include(<UIView+BooleanAnimations/UIView+BooleanAnimations.h>)
#import <UIView+BooleanAnimations/UIView+BooleanAnimations.h>
#else
@import UIView_BooleanAnimations;
#endif

@interface ARSpinner ()
@property (nonatomic, strong) UIView *spinnerView;
@end


@implementation ARSpinner

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupBar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupBar];
    }
    return self;
}

- (void)setupBar
{
    _spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 5)];
    _spinnerView.backgroundColor = [UIColor blackColor];
    [self layoutSubviews];
    [self addSubview:_spinnerView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _spinnerView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)fadeInAnimated:(BOOL)animated
{
    [self fadeInAnimated:animated completion:nil];
}

- (void)fadeOutAnimated:(BOOL)animated
{
    [self fadeOutAnimated:animated completion:nil];
}

- (void)fadeInAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    self.alpha = 0;
    [self startAnimating];
    
    [UIView animateIf:animated duration:0.3:^{
        self.alpha = 1;
    } completion:completion];
}

- (void)fadeOutAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    self.alpha = 1;
    [self stopAnimating];
    
    [UIView animateIf:animated duration:0.3:^{
        self.alpha = 0;
    } completion:completion];
}

- (void)startAnimating
{
    [self animate:LONG_MAX];
}

- (void)animate:(NSInteger)times
{
    [self ar_startSpinning:times];
}

- (void)stopAnimating
{
    [self ar_stopSpinningInstantly:NO];
}

- (UIColor *)spinnerColor
{
    return self.spinnerView.backgroundColor;
}

- (void)setSpinnerColor:(UIColor *)spinnerColor
{
    self.spinnerView.backgroundColor = spinnerColor;
}

@end
