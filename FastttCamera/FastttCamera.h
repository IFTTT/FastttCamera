//
//  FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/5/15.
//
//

#import <UIKit/UIKit.h>
#import "FastttCameraInterface.h"

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
