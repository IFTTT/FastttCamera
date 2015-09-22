//
//  FastttZoom.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/5/15.
//
//

@import UIKit;

@protocol FastttZoomDelegate;

/**
 *  Private class to handle focusing. If you want to manually handle focus, set
 *  handlesTapFocus = NO on your FastttCamera instance and use its
 *  focusAtPoint: method to manually set the focus point.
 */
@interface FastttZoom : NSObject

/**
 *  The delegate of the FastttFocus instance.
 */
@property (nonatomic, weak) id <FastttZoomDelegate> delegate;

/**
 *  YES if it should detect pinch gestures with a gesture recognizer, NO if handling zoom manually.
 *
 *  Defaults to YES.
 */
@property (nonatomic, assign) BOOL detectsPinch;

/**
 *  Set this to the maximum zoom scale of the current camera.
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 *  Defaults to nil. Set this through FastttCameraInterface's gestureDelegate property 
 *  if you need to manage custom UIGestureRecognizerDelegate settings.
 */
@property (nonatomic, weak) id <UIGestureRecognizerDelegate> gestureDelegate;

/**
 *  Initializer
 *
 *  @param view The view to use for receiving touch events.
 *  @param gestureDelegate The delegate, if any, to use for the pinch gesture recognizer.
 *
 *  @return An instance of FastttZoom.
 */
+ (instancetype)fastttZoomWithView:(UIView *)view gestureDelegate:(id <UIGestureRecognizerDelegate>)gestureDelegate;

/**
 *  Call this if manually handling zoom.
 *
 *  @param zoomScale How much to zoom, a number starting at 1.f and growing larger.
 */
- (void)showZoomViewWithScale:(CGFloat)zoomScale;

/**
 *  Call this when switching cameras to reset the zoom state to default 1.f scale.
 */
- (void)resetZoom;

@end

#pragma mark - FastttZoomDelegate

@protocol FastttZoomDelegate <NSObject>

/**
 *  Called when a pinch gesture was detected, letting the delegate know to handle zooming the camera
 *  to the given degree.
 *
 *  @param zoomScale How much to zoom, a number starting at 1.f and growing larger.
 *
 *  @return YES if the current camera is able to zoom, NO if not.
 */
- (BOOL)handlePinchZoomWithScale:(CGFloat)zoomScale;

@end
