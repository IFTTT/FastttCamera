//
//  IFTTTDeviceOrientation.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/6/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "IFTTTDeviceOrientation.h"

@interface IFTTTDeviceOrientation ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation IFTTTDeviceOrientation

- (id)init
{
    if ((self = [super init])) {
        
        [self setupMotionManager];
    }
    
    return self;
}

- (void)dealloc
{
    [self teardownMotionManager];
}

#pragma mark - Device Orientation

- (UIDeviceOrientation)orientation
{
    return [self _actualDeviceOrientationFromAccelerometer];
}

- (BOOL)deviceOrientationMatchesInterfaceOrientation
{
    return [self orientation] == [[UIDevice currentDevice] orientation];
}

#pragma mark - Private Methods

- (void)setupMotionManager
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
#if !TARGET_IPHONE_SIMULATOR
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.005;
    [_motionManager startAccelerometerUpdates];
#endif
}

- (void)teardownMotionManager
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#if !TARGET_IPHONE_SIMULATOR
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
#endif
}

- (UIDeviceOrientation)_actualDeviceOrientationFromAccelerometer
{
#if TARGET_IPHONE_SIMULATOR
    return UIDeviceOrientationPortrait;
#else
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
    if (acceleration.z < -0.75f) {
        return UIDeviceOrientationFaceUp;
    }
    
    if (acceleration.z > 0.75f) {
        return UIDeviceOrientationFaceDown;
    }
    
    CGFloat scaling = 1.f / (ABS(acceleration.x) + ABS(acceleration.y));
    
    CGFloat x = acceleration.x * scaling;
    CGFloat y = acceleration.y * scaling;
    
    if (x < -0.5f) {
        return UIDeviceOrientationLandscapeLeft;
    }
    
    if (x > 0.5f) {
        return UIDeviceOrientationLandscapeRight;
    }
    
    if (y > 0.5f) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    
    return UIDeviceOrientationPortrait;
#endif
}

@end
