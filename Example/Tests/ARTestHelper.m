@import UIKit;
@import Artsy_UIFonts;


@interface ARTestHelper : NSObject <UIApplicationDelegate>
@property (nonatomic, strong, readwrite) UIWindow *window;
@end

@implementation ARTestHelper

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
  NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
  
  NSAssert(version.majorVersion == 9,
           @"The tests should be run on iOS 9.x, not %ld.%ld", version.majorVersion, version.minorVersion);
  
  CGSize nativeResolution = [UIScreen mainScreen].nativeBounds.size;
  NSAssert([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && CGSizeEqualToSize(nativeResolution, CGSizeMake(750, 1334)),
           @"The tests should be run on an iPhone 6, not a device with native resolution %@",
           NSStringFromCGSize(nativeResolution));
  
  [UIView setAnimationsEnabled:NO];

  __unused UIFont *font = [UIFont serifBoldItalicFontWithSize:12];
  font = [UIFont serifBoldFontWithSize:12];
  font = [UIFont serifSemiBoldFontWithSize:12];
  font = [UIFont serifFontWithSize:12];
  font = [UIFont serifItalicFontWithSize:12];
  font = [UIFont sansSerifFontWithSize:12];
  font = [UIFont smallCapsSerifFontWithSize:12];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [[UIViewController alloc] init];
  [self.window makeKeyAndVisible];

  return YES;
}

@end