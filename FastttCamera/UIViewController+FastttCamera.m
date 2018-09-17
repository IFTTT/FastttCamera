//
//  UIViewController+FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "UIViewController+FastttCamera.h"

@implementation UIViewController (FastttCamera)

- (void)fastttAddChildViewController:(UIViewController *)childViewController
{
    [self fastttAddChildViewController:childViewController belowSubview:nil];
}

- (void)fastttAddChildViewController:(UIViewController *)childViewController belowSubview:(UIView *)siblingSubview
{
    [childViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:childViewController];
    if (siblingSubview && [self.view.subviews containsObject:siblingSubview]) {
        [self.view insertSubview:childViewController.view belowSubview:siblingSubview];
    } else {
        [self.view addSubview:childViewController.view];
    }
    [childViewController didMoveToParentViewController:self];
    [childViewController endAppearanceTransition];
}
    
- (void)fastttAddChildViewController:(UIViewController *)childViewController inView:(UIView*)view {
    [childViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:childViewController];
    [view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
    [childViewController endAppearanceTransition];
}
    
- (void)fastttAddChildViewController:(UIViewController *)childViewController inView:(UIView*)view belowSubview:(UIView *)subview {
    [childViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:childViewController];
    [view insertSubview:childViewController.view belowSubview:subview];
    [childViewController didMoveToParentViewController:self];
    [childViewController endAppearanceTransition];
}
    
- (void)fastttAddChildViewController:(UIViewController *)childViewController inView:(UIView*)view aboveSubview:(UIView *)subview {
    [childViewController beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:childViewController];
    [view insertSubview:childViewController.view aboveSubview:subview];
    [childViewController didMoveToParentViewController:self];
    [childViewController endAppearanceTransition];
}
    
- (void)fastttRemoveChildViewController:(UIViewController *)childViewController
{
    [childViewController willMoveToParentViewController:nil];
    [childViewController beginAppearanceTransition:NO animated:NO];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
    [childViewController endAppearanceTransition];
}

@end
