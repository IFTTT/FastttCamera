//
//  IFTTTDeviceOrientation.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/6/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import CoreMotion;
#import "IFTTTDeviceOrientation.h"

CG_INLINE CGFLOAT_TYPE FastttATan2(CGFLOAT_TYPE f, CGFLOAT_TYPE g) {
#if CGFLOAT_IS_DOUBLE
    return atan2(f, g);
#else
    return atan2f(f, g);
#endif
};

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
    CGFloat baseAngle = [self _currentDeviceAngle];
    
    if ((baseAngle > -M_PI_4) && (baseAngle < M_PI_4)) {
        return UIDeviceOrientationPortrait;
    }
    
    if ((baseAngle < -M_PI_4) && (baseAngle > -3 * M_PI_4)) {
        return UIDeviceOrientationLandscapeLeft;
    }
    
    if ((baseAngle > M_PI_4) && (baseAngle < 3 * M_PI_4)) {
        return UIDeviceOrientationLandscapeRight;
    }
    
    return UIDeviceOrientationPortraitUpsideDown;
}

- (CGFloat)_currentDeviceAngle
{
#if TARGET_IPHONE_SIMULATOR
    CGPoint acceleration = CGPointZero;
#else
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;
#endif
    CGFloat deviceAngle = M_PI / 2.f - FastttATan2(-acceleration.y, acceleration.x);
    
    if (deviceAngle > M_PI) {
        deviceAngle -= 2.f * M_PI;
    }
    
    return deviceAngle;
}

@end
