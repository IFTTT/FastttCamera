//
//  FastttCameraInterface.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <UIKit/UIKit.h>
#import "FastttCameraTypes.h"
#import "FastttCapturedImage.h"
#import "UIViewController+FastttCamera.h"

@protocol FastttCameraDelegate;

@protocol FastttCameraInterface <NSObject>

/**
 *  The delegate of the FastttCamera instance.
 */
@property (nonatomic, weak) id <FastttCameraDelegate> delegate;


#pragma mark - Advanced Configuration Options

/**
 *  Default is YES. Set this to NO if you don't want to enable
 *  FastttCamera to manage tap-to-focus with its internal tap gesture recognizer.
 *  You can still send it manual focusAtPoint: calls from your own gesture recognizer.
 */
@property (nonatomic, assign) BOOL handlesTapFocus;

/**
 *  Default is YES. Set this to NO if you don't want the focus square to show when
 *  the camera is focusing at a point.
 */
@property (nonatomic, assign) BOOL showsFocusView;

/**
 *  Default is YES. Set this to NO if you don't want to enable
 *  FastttCamera to manage pinch-to-zoom with its internal pinch gesture recognizer.
 *  You can still send it manual zoomToScale: calls from your own gesture recognizer.
 */
@property (nonatomic, assign) BOOL handlesZoom;

/**
 *  Default is YES. Set this to NO if you don't want the zoom indicator to show when
 *  the camera is zoomed in.
 */
@property (nonatomic, assign) BOOL showsZoomView;

/**
 *  Returns the maximum zoom factor for the current device, useful if you are handling zooming manually.
 */
@property (nonatomic, assign) CGFloat maxZoomFactor;

/**
 *  Defaults to nil. Set this if you need to manage custom UIGestureRecognizerDelegate settings
 *  for tap-to-focus and pinch-zoom. This will only have an effect if handlesTapFocus or handlesZoom is true.
 */
@property (nonatomic, weak) id <UIGestureRecognizerDelegate> gestureDelegate;

/**
 *  Defaults to FastttCamera's view. Set this if you have an overlay with additional gesture recognizers that would
 *  conflict with FastttCamera's tap-to-focus gesture recognizer and pinch-to-zoom gesture recognizer.
 */
@property (nonatomic, strong) UIView *gestureView;

/**
 *  Defaults to YES. Set this to NO if you want FastttCamera to return the full image
 *  captured by the camera instead of an image cropped to the view's aspect ratio. The
 *  image will be returned by the cameraController:didFinishCapturingImage: delegate method,
 *  in the fullImage property of the FastttCapturedImage object.
 *  cameraController:didFinishNormalizingCapturedImage: is the only other method that will
 *  be called, and only if normalizesImageOrientations == YES.
 */
@property (nonatomic, assign) BOOL cropsImageToVisibleAspectRatio;

/**
 *  Defaults to YES. Set this to NO if you don't want FastttCamera to return a scaled version of the
 *  full captured image. The scaled image will be returned in the scaledImage property of the
 *  FastttCapturedImage object, and will trigger the cameraController:didFinishScalingCapturedImage:
 *  delegate method when it is available.
 */
@property (nonatomic, assign) BOOL scalesImage;

/**
 *  Defaults to scaling the cropped image to fit within the size of the camera preview. If you'd like to
 *  set an explicit max dimension for scaling the image, set it here. This can be useful if you have specific
 *  requirements for uploading the image.
 */
@property (nonatomic, assign) CGFloat maxScaledDimension;

/**
 *  Defaults to YES. Set this to NO if you would like to only use the images initially returned by FastttCamera
 *  and don't need the versions returned that have been rotated so that their orientation is UIImageOrientationUP.
 *  If true, normalized images will replace the initial images in the FastttCapturedImage object when they are finished
 *  processing in the background, and the cameraController:didFinishNormalizingCapturedImage: delegate method will
 *  notify you that they are ready.
 */
@property (nonatomic, assign) BOOL normalizesImageOrientations;

/**
 *  Defaults to YES. Set this to NO if you don't want to display the captured image preview to the user in the same orientation
 *  that it was captured, or if you are already rotating your interface to account for this.
 */
@property (nonatomic, assign) BOOL returnsRotatedPreview;

/**
 *  Defaults to YES. Set this to NO if your interface does not autorotate with device orientation to make sure that preview
 *  images are still displayed correctly when orientation lock is off but your interface stays in portrait.
 */
@property (nonatomic, assign) BOOL interfaceRotatesWithOrientation;

/**
 *  Defaults to UIDeviceOrientationPortrait. Set this to UIDeviceOrientationLandscapeLeft or UIDeviceOrientationLandscapeRight
 *  if your interface does not autorotate with device orientation and sticks to a landscape interface, to make sure that preview
 *  images are still displayed correctly when orientation lock is off but your interface stays in landscape mode.
 *  Make sure to also set interfaceRotatesWithOrientation = YES, otherwise this property will be ignored.
 */
@property (nonatomic, assign) UIDeviceOrientation fixedInterfaceOrientation;

#pragma mark - Camera State

/**
 *  The current camera device.
 */
@property (nonatomic, assign) FastttCameraDevice cameraDevice;

/**
 *  The current flash mode.
 */
@property (nonatomic, assign) FastttCameraFlashMode cameraFlashMode;

/**
 *  The current torch mode.
 */
@property (nonatomic, assign) FastttCameraTorchMode cameraTorchMode;

/**
 *  Check if flash is available for the current camera device.
 *
 *  @return YES if flash is available, NO if not.
 */
- (BOOL)isFlashAvailableForCurrentDevice;

/**
 *  Check if flash is available for the specified camera device.
 *
 *  @return YES if flash is available, NO if not.
 */
+ (BOOL)isFlashAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Check if torch is available for the current camera device.
 *
 *  @return YES if torch is available, NO if not.
 */
- (BOOL)isTorchAvailableForCurrentDevice;

/**
 *  Check if torch is available for the specified camera device.
 *
 *  @return YES if torch is available, NO if not.
 */
+ (BOOL)isTorchAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Check if point focus is available for the specified camera device.
 *
 *  @param cameraDevice The camera device to check for point focus availability.
 *
 *  @return YES if point focus is available, NO if not.
 */
+ (BOOL)isPointFocusAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Check if the specified camera device is available on this device.
 *
 *  @param cameraDevice The camera device to check for.
 *
 *  @return YES if the specified camera is available, NO if it is not.
 */
+ (BOOL)isCameraDeviceAvailable:(FastttCameraDevice)cameraDevice;

/**
 *  Focus the camera at the specified point, if focus at point is available on the current camera device.
 *  You only need to worry about this if you set handlesTapFocus to NO, and want to manually control
 *  tap-to-focus.
 *
 *  @param touchPoint The point at which to focus the camera, if point focus is available.
 *
 *  @return YES if the camera was able to focus, NO if not. You can use this response to decide whether or not 
 *  to show a custom UI indication that the camera is focusing.
 */
- (BOOL)focusAtPoint:(CGPoint)touchPoint;

/**
 *  Zoom the camera to the specified scale, if zooming is available on the current camera device.
 *  You only need to worry about this if you set handlesZoom to NO, and want to manually control
 *  pinch-to-zoom.
 *
 *  @param scale The scale to which to zoom the camera. The camera will not zoom past its maximum zoom scale.
 *
 *  @return YES if the camera was able to zoom, NO if not. You can use this response to decide whether or not
 *  to show a custom UI indication that the camera is zooming.
 */
- (BOOL)zoomToScale:(CGFloat)scale;


#pragma mark - Take a picture!

/**
 *  Checks whether the last photo has finished processing.
 *
 *  @return YES if the last photo has finished processing and it is ready to capture, NO if not.
 */
- (BOOL)isReadyToCapturePhoto;

/**
 *  Triggers the camera to take a photo.
 */
- (void)takePicture;


#pragma mark - Process a photo

/**
 *  Scale the image to the given max dimension and trigger the delegate callbacks
 *  with a capturedImage object similarly to takePicture.
 *
 *  @note This will always trigger cameraController:didFinishCapturingImage: and cameraController:didFinishScalingCapturedImage:
 *  and will trigger cameraController:didFinishNormalizingCapturedImage: if normalizesImageOrientations is set to YES.
 *
 *  @param image The image to process.
 *  @param maxDimension The maximum dimension of the target size for aspect scaling the image.
 */
- (void)processImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension;

/**
 *  Crop the image to the given cropRect and trigger the delegate callbacks
 *  with a capturedImage object similarly to takePicture.
 *
 *  @param image The image to process.
 *  @param cropRect The CGRect to use for cropping the image.
 *
 *  @note This will always trigger cameraController:didFinishCapturingImage:, will never trigger cameraController:didFinishScalingCapturedImage:,
 *  and will trigger cameraController:didFinishNormalizingCapturedImage: if normalizesImageOrientations is set to YES.
 */
- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect;

/**
 *  Crop the image to the given cropRect and scale the image to the given max dimension and trigger
 *  the delegate callbacks with a capturedImage object similarly to takePicture.
 *
 *  @param image The image to process.
 *  @param maxDimension The maximum dimension of the target size for aspect scaling the image.
 *
 *  @note This will always trigger cameraController:didFinishCapturingImage: and cameraController:didFinishScalingCapturedImage:
 *  and will trigger cameraController:didFinishNormalizingCapturedImage: if normalizesImageOrientations is set to YES.
 */
- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect maxDimension:(CGFloat)maxDimension;

/**
 *  Cancels the in-process image capture and processing to free up memory and ready FastttCamera to capture a new photo.
 */
- (void)cancelImageProcessing;

#pragma mark - Manage Capture Session

/**
 *  Start the capture session if it is currently paused.
 *
 *  @note This is managed internally by FastttCamera. Advanced use cases can trigger it manually using this method.
 */
- (void)startRunning;

/**
 *  Pause the capture session if it is currently running.
 *
 *  @note This is managed internally by FastttCamera. Advanced use cases can trigger it manually using this method.
 */
- (void)stopRunning;

@end


#pragma mark - FastttCameraDelegate

@protocol FastttCameraDelegate <NSObject>

@optional

/**
 *  Called when the camera controller has obtained the raw data containing the image and metadata.
 *
 *  @param cameraController The FastttCamera instance that captured a photo.
 *
 *  @param rawJPEGData The plain, raw data from the camera, ready to be written to a file if desired.
 *
*/
- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImageData:(NSData *)rawJPEGData;

/**
 *  Called when the camera controller has finished capturing a photo.
 *
 *  @param cameraController The FastttCamera instance that captured a photo.
 *
 *  @param capturedImage The FastttCapturedImage object, containing a full-resolution (UIImage *)fullImage that has not
 *  yet had its orientation normalized (it has not yet been rotated so that its orientation is UIImageOrientationUp),
 *  and a (UIImage *)previewImage that has its image orientation set so that it is rotated to match the camera preview's
 *  orientation as it was captured, so if the device was held landscape left, the image returned will be set to display so
 *  that landscape left is "up". This is great if your interface doesn't rotate, or if the photo was taken with orientation lock on.
 *
 *  @note if you set returnsRotatedPreview=NO, there will be no previewImage here, and if you set cropsImageToVisibleAspectRatio=NO,
 *  the fullImage will be the raw image captured by the camera, while by default the fullImage will have been cropped to the visible
 *  camera preview's aspect ratio.
 */
- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage;

/**
 *  Called when the camera controller has finished scaling the captured photo.
 *
 *  @param cameraController The FastttCamera instance that captured a photo.
 *
 *  @param capturedImage    The FastttCapturedImage object, which now also contains a scaled (UIImage *)scaledImage, that has not yet
 *  had its orientation normalized. The image by default is scaled to fit within the camera's preview window, but you can
 *  set a custom maxScaledDimension above.
 *
 *  @note This method will not be called if scalesImage is set to NO.
 */
- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage;

/**
 *  Called when the camera controller has finished normalizing the captured photo.
 *
 *  @param cameraController The FastttCamera instance that captured the photo.
 *
 *  @param capturedImage    The FastttCapturedImage object, with the (UIImage *)fullImage and (UIImage *)scaledImage (if any) replaced
 *  by images that have been rotated so that their orientation is UIImageOrientationUp. This is a slower process than creating the
 *  initial images that are returned, which have varying orientations based on how the phone was held, but the normalized images
 *  are more ideal for uploading or saving as they are displayed more predictably in different browsers and applications than the
 *  initial images which have an orientation tag set that is not UIImageOrientationUp.
 *
 *  @note This method will not be called if normalizesImageOrientations is set to NO.
 */
- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage;

/**
 *  Called when the camera controller asks for permission to access the user's camera and is denied.
 *
 *  @param cameraController The FastttCamera instance.
 *
 *  @note Use this optional method to handle gracefully the case where the user has denied camera access, either disabling the camera
 *  if not necessary or redirecting the user to your app's Settings page where they can enable the camera permissions. Remember that iOS
 *  will only show the user an alert requesting permission in-app one time. If the user denies permission, they must change this setting
 *  in the app's permissions page within the Settings App. This method will be called every time the app launches or becomes active and
 *  finds that permission to access the camera has not been granted.
 */
- (void)userDeniedCameraPermissionsForCameraController:(id<FastttCameraInterface>)cameraController;

@end
