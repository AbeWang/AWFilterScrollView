//
//  AWAppDelegate.m
//  AWFilterScrollView
//
//  Created by Abe on 13/5/14.
//  Copyright (c) 2013年 Abe Wang. All rights reserved.
//

#import "AWAppDelegate.h"
#import "AWFilterViewController.h"

@implementation AWAppDelegate

- (void)dealloc
{
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    AWFilterViewController *controller = [[AWFilterViewController alloc] init];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = naviController;
    [self.window makeKeyAndVisible];
    [controller release];
    [naviController release];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}

@synthesize window;
@end
