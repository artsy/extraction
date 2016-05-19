@import UIKit;

int main(int argc, char * argv[])
{
  @autoreleasepool {
    NSString *appDelegate = @"ARAppDelegate";
#ifdef DEBUG
    if (NSClassFromString(@"XCTestCase")) {
      appDelegate = @"ARTestHelper";
    }
#endif
    return UIApplicationMain(argc, argv, nil, appDelegate);
  }
}
