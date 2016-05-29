//
//  FastttFocus.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <UIKit/UIKit.h>

@protocol FastttFocusDelegate;
@class AVCaptureDevice;

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
 *  Defaults to nil. Set this through FastttCameraInterface's gestureDelegate property
 *  if you need to manage custom UIGestureRecognizerDelegate settings.
 */
@property (nonatomic, weak) id <UIGestureRecognizerDelegate> gestureDelegate;

/**
 *  Initializer
 *
 *  @param view The view to use for receiving touch events.
 *  @param gestureDelegate The delegate, if any, to use for the tap gesture recognizer.
 *
 *  @return An instance of FastttFocus.
 */
+ (instancetype)fastttFocusWithView:(UIView *)view gestureDelegate:(id <UIGestureRecognizerDelegate>)gestureDelegate;

/**
 *  Call this if manually handling focus.
 *
 *  @param location The location of the tap in the view.
 */
- (void)showFocusViewAtPoint:(CGPoint)location;

/**
 *  Tells the caller whether a focus operation is currently running.
 *
 *  @discussion By default, FastttFocus KVOs the AVCaptureDevice to know whether a focus operation has finished or not, 
 *              so KVOing this property is essentially the same thing as KVOing AVFoundation.
 *
 *  @note If handlesTapFocus has been set to NO, then this property will never change. 
 */
@property (nonatomic, readonly, getter=isFocusing) BOOL focusing;

/**
 *  The AVCaptureDevice currently associated with the FastttFocus instance.
 *
 *  @discussion You tipically call this method to let the FastttFocus instance KVO the Capture Device to know whether 
 *              a focus operation is being performed.
 *
 *  @note If handlesTapFocus has been set to NO, then this property doesn't do anything.
 */
@property (nonatomic, weak) AVCaptureDevice *currentDevice;

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

@optional

/**
 *  Called when the focus, the exposure and the white balance operations have finished processing.
 *
 *  @warning This method may be called multiple times due to the system automatically adjusting the focus, exposure and white balance trio,
 *              when AVCaptureFocusModeContinuousAutoFocus, AVCaptureExposureModeContinuousAutoExposure or 
 *              AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance have been set.
 *
 *  @note If handlesTapFocus has been set to NO, then this method won't be called.
 */
- (void)hasFinishedAdjustingFocusAndExposure;

@end
