//
//  FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/5/15.
//
//

@import UIKit;

#import "FastttCameraInterface.h"
#import "IFTTTDeviceOrientation.h"
#import "FastttFocus.h"
#import "CoreGraphics/CoreGraphics.h"
#import "CoreVideo/CoreVideo.h"
#import "CoreMedia/CoreMedia.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>

/**
 *  Public class for you to use to create a standard FastttCamera!
 *
 *  @note The full interface for the FastttCamera can be found in
 *  the FastttCameraInterface protocol.
 *
 *  @note If you want to use filters with your live camera preview,
 *  use an instance of FastttFilterCamera instead.
 */
@interface FastttCamera : UIViewController <FastttCameraInterface>

@end
