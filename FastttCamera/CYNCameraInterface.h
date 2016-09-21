//
//  CYNCameraInterface.h
//  CYNCamera
//
//  Created by Marco Rossi on 19/09/16.
//
//

#import "FastttCameraInterface.h"

@protocol CYNCameraInterface <FastttCameraInterface>

+ (BOOL)supportsVideoCapture;
+ (BOOL)isFrontCameraAvailable;
+ (BOOL)isRearCameraAvailable;

//Video & audio permission
+ (BOOL)hasCameraPermission;
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

+ (BOOL)hasMicrophonePermission;
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

@end
