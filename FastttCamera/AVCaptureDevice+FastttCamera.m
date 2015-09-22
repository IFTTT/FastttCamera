//
//  AVCaptureDevice+FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "AVCaptureDevice+FastttCamera.h"

@implementation AVCaptureDevice (FastttCamera)

#pragma mark - Public Methods

+ (BOOL)isPointFocusAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self cameraDevice:cameraDevice];
    if (device.focusPointOfInterestSupported) {
        return YES;
    }
    
    if (device.exposurePointOfInterestSupported) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isFlashAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self cameraDevice:cameraDevice];
    if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isTorchAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self cameraDevice:cameraDevice];
    if ([device isTorchModeSupported:AVCaptureTorchModeOn]) {
        return YES;
    }
    
    return NO;
}

+ (AVCaptureDevice *)cameraDevice:(FastttCameraDevice)cameraDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == [self _avPositionForDevice:cameraDevice]) {
            return device;
        }
    }
    
    return nil;
}

+ (AVCaptureDevicePosition)positionForCameraDevice:(FastttCameraDevice)cameraDevice
{
    switch (cameraDevice) {
        case FastttCameraDeviceFront:
            return AVCaptureDevicePositionFront;
        default:
            return AVCaptureDevicePositionBack;
    }
}

- (BOOL)setCameraFlashMode:(FastttCameraFlashMode)cameraFlashMode
{
    BOOL success = NO;
    
    if ([self lockForConfiguration:nil]) {
        
        AVCaptureFlashMode flashMode = [self.class _modeForFastttCameraFlashMode:cameraFlashMode];
        
        if ([self isFlashModeSupported:flashMode]) {
            self.flashMode = flashMode;
            success = YES;
        }
        
        [self unlockForConfiguration];
    }
    
    return success;
}

- (BOOL)setCameraTorchMode:(FastttCameraTorchMode)cameraTorchMode
{
    BOOL success = NO;
    
    if ([self lockForConfiguration:nil]) {
        
        AVCaptureTorchMode torchMode = [self.class _modeForFastttCameraTorchMode:cameraTorchMode];
        
        if ([self isTorchModeSupported:torchMode]) {
            self.torchMode = torchMode;
            success = YES;
        }
        
        [self unlockForConfiguration];
    }
    
    return success;
}

- (BOOL)focusAtPointOfInterest:(CGPoint)pointOfInterest
{
    if ([self lockForConfiguration:nil]) {
        
        if (self.focusPointOfInterestSupported) {
            self.focusPointOfInterest = pointOfInterest;
        }
        
        if (self.exposurePointOfInterestSupported) {
            self.exposurePointOfInterest = pointOfInterest;
        }
        
        if ([self isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([self isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [self unlockForConfiguration];
        return YES;
    }
    
    return NO;
}
    
- (CGFloat)videoMaxZoomFactor
{
    return MIN(self.activeFormat.videoMaxZoomFactor, 4.f);
}

- (BOOL)zoomToScale:(CGFloat)zoomScale
{
    BOOL success = NO;
    
    if ([self lockForConfiguration:nil]) {
        
        if (!(zoomScale > [self videoMaxZoomFactor])
            && !(zoomScale < 1.f)) {
            self.videoZoomFactor = zoomScale;
            success = YES;
        }
        
        [self unlockForConfiguration];
    }
    
    return success;
}

#pragma mark - Internal Methods

+ (AVCaptureDevicePosition)_avPositionForDevice:(FastttCameraDevice)cameraDevice
{
    switch (cameraDevice) {
        case FastttCameraDeviceFront:
            return AVCaptureDevicePositionFront;
            
        case FastttCameraDeviceRear:
            return AVCaptureDevicePositionBack;
            
        default:
            break;
    }
    
    return AVCaptureDevicePositionUnspecified;
}

+ (AVCaptureFlashMode)_modeForFastttCameraFlashMode:(FastttCameraFlashMode)cameraFlashMode
{
    AVCaptureFlashMode mode;
    
    switch (cameraFlashMode) {
        case FastttCameraFlashModeOn:
            mode = AVCaptureFlashModeOn;
            break;
            
        case FastttCameraFlashModeOff:
            mode = AVCaptureFlashModeOff;
            break;
            
        case FastttCameraFlashModeAuto:
            mode = AVCaptureFlashModeAuto;
            break;
    }
    
    return mode;
}

+ (AVCaptureTorchMode)_modeForFastttCameraTorchMode:(FastttCameraTorchMode)cameraTorchMode
{
    AVCaptureTorchMode mode;
    
    switch (cameraTorchMode) {
        case FastttCameraTorchModeOn:
            mode = AVCaptureTorchModeOn;
            break;
            
        case FastttCameraTorchModeOff:
            mode = AVCaptureTorchModeOff;
            break;
            
        case FastttCameraTorchModeAuto:
            mode = AVCaptureTorchModeAuto;
            break;
    }
    
    return mode;
}

@end
