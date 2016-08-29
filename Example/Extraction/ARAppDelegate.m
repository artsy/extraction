#import "ARAppDelegate.h"

#import <Extraction/ARSwitchView.h>
#import <Extraction/ARSpinner.h>
#import <Extraction/ARLoadFailureView.h>

#import <FLKAutoLayout/UIView+FLKAutoLayout.h>
#import <FLKAutoLayout/UIViewController+FLKAutoLayout.h>

@interface ARAppDelegate () <ARLoadFailureViewDelegate>
@property (nonatomic, strong, readwrite) UIStackView *stackView;
@end

@implementation ARAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.stackView = [UIStackView new];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.distribution = UIStackViewDistributionFill;
    self.stackView.spacing = 20;

    UIViewController *viewController = [UIViewController new];
    [viewController.view addSubview:self.stackView];
    [self.stackView alignLeadingEdgeWithView:viewController.view predicate:@"20"];
    [self.stackView alignTrailingEdgeWithView:viewController.view predicate:@"-20"];
    [self.stackView alignTopEdgeWithView:viewController.flk_topLayoutGuide predicate:@"40"];
    [self.stackView alignBottomEdgeWithView:viewController.flk_bottomLayoutGuide predicate:@"0"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    //
    // These are the sections
    //
    
    ARSwitchView *switchView = [[ARSwitchView alloc] initWithButtonTitles:@[@"one", @"two", @"three"]];
    [self addSection:@"ARSwitchView" view:switchView];
    
    ARSpinner *spinner = [ARSpinner new];
    [spinner startAnimating];
    [self addSection:@"ARSpinner" view:spinner];
  
    ARLoadFailureView *loadFailureView = [ARLoadFailureView new];
    loadFailureView.delegate = self;
    [self addSection:@"ARLoadFailureView" view:loadFailureView];

    // This view is just there to gobble up the rest of the space.
    [self.stackView addArrangedSubview:[UIView new]];

    return YES;
}

- (void)addSection:(NSString *)title view:(UIView *)view;
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];

    [self.stackView addArrangedSubview:label];
    [self.stackView addArrangedSubview:view];
    
    UIView *border = [UIView new];
    border.backgroundColor = [UIColor lightGrayColor];
    [border constrainHeight:@"1"];
    [self.stackView addArrangedSubview:border];
}

#pragma mark - ARLoadFailureViewDelegate

- (void)loadFailureViewDidRequestRetry:(ARLoadFailureView *)loadFailureView;
{
    NSLog(@"Retry Load.");
    [loadFailureView retryFailed];
}

@end
