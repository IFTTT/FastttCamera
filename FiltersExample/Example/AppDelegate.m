//
//  AppDelegate.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleViewController.h"
#import "FastttCameraBenchmark.h"
#import "UIImagePickerBenchmark.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITabBarController *tabBarController = [UITabBarController new];

    UIViewController *exampleViewController = [ExampleViewController new];
#if TARGET_IPHONE_SIMULATOR
    tabBarController.viewControllers = @[exampleViewController];
#else
    UIViewController *fastCameraBenchmark = [FastttCameraBenchmark new];
    UIViewController *uiImagePickerBenchmark = [UIImagePickerBenchmark new];
    
    tabBarController.viewControllers = @[exampleViewController,
                                         fastCameraBenchmark,
                                         uiImagePickerBenchmark];
#endif
    
    [tabBarController.tabBar setTranslucent:NO];

    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
