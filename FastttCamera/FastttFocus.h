//
//  FastttFocus.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

@import UIKit;

@protocol FastttFocusDelegate;

/**
 *  Private class to handle focusing. If you want to manually handle focus, set
 *  handlesTapFocus = NO on your FastttCamera instance and use its
 *  focusAtPoint: method to manually set the focus point.
 */
@interface FastttFocus : NSObject

/**
 *  The delegate of the FastttFocus instance.
 */
@property (nonatomic, weak) id <FastttFocusDelegate> delegate;

/**
 *  YES if it should detect taps with a gesture recognizer, NO if handling focus manually.
 *
 *  Defaults to YES.
 */
@property (nonatomic, assign) BOOL detectsTaps;

/**
 *  Initializer
 *
 *  @param view The view to use for receiving touch events.
 *
 *  @return An instance of FastttFocus.
 */
+ (instancetype)fastttFocusWithView:(UIView *)view;

/**
 *  Call this if manually handling focus.
 *
 *  @param location The location of the tap in the view.
 */
- (void)showFocusViewAtPoint:(CGPoint)location;

@end

#pragma mark - FastttFocusDelegate

@protocol FastttFocusDelegate <NSObject>

/**
 *  Called when a tap gesture was detected, letting the delegate know to handle focusing the camera
 *  at the given point.
 *
 *  @param touchPoint The point in the view where a tap was detected.
 *
 *  @return YES if the current camera is able to focus, NO if not.
 */
- (BOOL)handleTapFocusAtPoint:(CGPoint)touchPoint;

@end
