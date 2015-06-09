//
//  FastttCameraTypes.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FastttCameraDevice) {
    FastttCameraDeviceFront,
    FastttCameraDeviceRear
};

typedef NS_ENUM(NSInteger, FastttCameraFlashMode) {
    FastttCameraFlashModeOff,
    FastttCameraFlashModeOn,
    FastttCameraFlashModeAuto
};

typedef NS_ENUM(NSInteger, FastttCameraTorchMode) {
    FastttCameraTorchModeOff,
    FastttCameraTorchModeOn,
    FastttCameraTorchModeAuto
};
