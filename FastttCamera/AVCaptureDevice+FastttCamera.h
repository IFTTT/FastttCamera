//
//  AVCaptureDevice+FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <AVFoundation/AVFoundation.h>
#import "FastttCameraTypes.h"

/**
 *  Private category used by FastttCamera for managing the AVCaptureDevice.
 */
@interface AVCaptureDevice (FastttCamera)

/**
 *  Checks whether either point focus or point exposure is available for the given FastttCameraDevice.
 *
 *  @param cameraDevice The FastttCameraDevice to check.
 *
 *  @return YES if point focus or point exposure adjustments are available for the device, NO if not.
 */
+ (BOOL)isPointFocusAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  The maximum zoom scale of this device.
 *
 *  @return The maximum zoom scale.
 */
- (CGFloat)videoMaxZoomFactor;

/**
 *  Tells this AVCaptureDevice to zoom to the given scale.
 *
 *  @param zoomScale The scale to which to zoom the camera device.
 *
 *  @return YES if zoomed successfully, NO if not.
 */
- (BOOL)zoomToScale:(CGFloat)zoomScale;

/**
 *  Checks whether flash is available for the given FastttCameraDevice.
 *
 *  @param cameraDevice The FastttCameraDevice to check.
 *
 *  @return YES if flash is available for the device, NO if not.
 */
+ (BOOL)isFlashAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Checks whether torch is available for the given FastttCameraDevice.
 *
 *  @param cameraDevice The FastttCameraDevice to check.
 *
 *  @return YES if torch is available for the device, NO if not.
 */
+ (BOOL)isTorchAvailableForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Returns the AVCaptureDevice that corresponds to the given FastttCameraDevice position.
 *
 *  @param cameraDevice The FastttCameraDevice camera position to check.
 *
 *  @return The AVCaptureDevice that corresponds to the given FastttCameraDevice position.
 */
+ (AVCaptureDevice *)cameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Returns the AVCaptureDevicePosition for the given FastttCameraDevice.
 *
 *  @param cameraDevice The FastttCameraDevice type to check for the associated AVCaptureDevicePosition.
 *
 *  @return The AVCaptureDevicePosition associated with the given FastttCameraDevice.
 */
+ (AVCaptureDevicePosition)positionForCameraDevice:(FastttCameraDevice)cameraDevice;

/**
 *  Tells this AVCaptureDevice to focus and set point exposure at the given point of interest.
 *
 *  @param pointOfInterest The point of interest in the current AVCaptureDevice's coordinate system
 *  at which to set point focus and point exposure for this device.
 *
 *  @return YES if the device was able to focus.
 */
- (BOOL)focusAtPointOfInterest:(CGPoint)pointOfInterest;

/**
 *  Sets the FastttCameraFlashMode for this AVCaptureDevice.
 *
 *  @param cameraFlashMode The FastttCameraFlashMode to set for this AVCaptureDevice.
 *
 *  @return YES if the FastttCameraFlashMode is supported by this AVCaptureDevice, NO if not.
 */
- (BOOL)setCameraFlashMode:(FastttCameraFlashMode)cameraFlashMode;

/**
 *  Sets the FastttCameraTorchMode for this AVCaptureDevice.
 *
 *  @param cameraTorchMode The FastttCameraTorchMode to set for this AVCaptureDevice.
 *
 *  @return YES if the FastttCameraTorchMode is supported by this AVCaptureDevice, NO if not.
 */
- (BOOL)setCameraTorchMode:(FastttCameraTorchMode)cameraTorchMode;

@end
