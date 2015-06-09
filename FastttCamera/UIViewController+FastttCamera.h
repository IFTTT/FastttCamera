//
//  UIViewController+FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <UIKit/UIKit.h>

/**
 *  Public category you can use for adding and removing the FastttCamera instance
 *  as a child of your view controller.
 */
@interface UIViewController (FastttCamera)

/**
 *  Adds as a child view controller of this view controller and handles
 *  view appearance transition event calls.
 *
 *  @param childViewController The child view controller to add.
 */
- (void)fastttAddChildViewController:(UIViewController *)childViewController;

/**
 *  Adds as a child view controller of this view controller below the given 
 *  sibling subview and handles view appearance transition event calls.
 *
 *  @param childViewController The child view controller to add.
 *  @param siblingSubview The subview below which to add the child view controller's view.
 */
- (void)fastttAddChildViewController:(UIViewController *)childViewController belowSubview:(UIView *)siblingSubview;

/**
 *  Removes the given child view controller from this view controller and handles
 *  view appearance transition event calls.
 *
 *  @param childViewController The child view controller to remove.
 */
- (void)fastttRemoveChildViewController:(UIViewController *)childViewController;

@end
