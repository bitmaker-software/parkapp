#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.25 green:0.87 blue:0.60 alpha:1.0]];
      [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
      [[UINavigationBar appearance] setTitleTextAttributes:
       [NSDictionary dictionaryWithObjectsAndKeys:
        [UIColor whiteColor], NSForegroundColorAttributeName,
        [UIFont fontWithName:@"Regular-Bold" size:17.0], NSFontAttributeName, nil]];
      [[UIBarButtonItem appearance] setTitleTextAttributes:
       [NSDictionary dictionaryWithObjectsAndKeys:
        [UIColor whiteColor], NSForegroundColorAttributeName,
        [UIFont fontWithName:@"Regular-Semibold" size:17.0], NSFontAttributeName, nil]
        forState:UIControlStateNormal];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
