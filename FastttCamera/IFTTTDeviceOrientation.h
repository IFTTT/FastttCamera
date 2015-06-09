//
//  IFTTTDeviceOrientation.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/6/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Private category used by FastttCamera for managing the device's actual orientation.
 */
@interface IFTTTDeviceOrientation : NSObject

/**
 *  The current actual orientation of the device, based on accelerometer data
 *  if on a device, or [[UIDevice currentDevice] orientation] if on the simulator.
 *
 *  @return The device's current orientation.
 */
- (UIDeviceOrientation)orientation;

/**
 *  Whether the physical orientation of the device matches the device's interface orientation.
 *  Expect this to return YES when orientation lock is off, and NO when orientation lock is on.
 *
 *  @return YES if the device's interface orientation matches the physical device orientation,
 *  NO if the interface and physical orientation are different (when orientation lock is on).
 */
- (BOOL)deviceOrientationMatchesInterfaceOrientation;

@end
