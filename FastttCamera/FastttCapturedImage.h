//
//  FastttCapturedImage.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

#import <UIKit/UIKit.h>

/**
 *  Public class to hold a captured image object, used in FastttCameraDelegate callbacks
 *  as the image is being cropped, scaled, and normalized.
 */
@interface FastttCapturedImage : NSObject

/**
 *  Create a FastttCapturedImage object.
 *
 *  @param fullImage The full-resolution cropped image that was captured by the camera.
 *
 *  @return An initialized FastttCapturedImage object.
 */
+ (instancetype) fastttCapturedFullImage:(UIImage *)fullImage;

/**
 *  Customizable object for you to use to hold any data specific to your app.
 */
@property (nonatomic, strong) id userInfo;

/**
 *  The full-resolution cropped image that was captured by the camera.
 */
@property (nonatomic, strong) UIImage *fullImage;

/**
 *  The captured image scaled to the size of the camera preview viewport.
 */
@property (nonatomic, strong) UIImage *scaledImage;

/**
 *  The scaled image rotated to match the camera preview. The image's orientation has been set so that 
 *  it image displays in the same orientation as the camera preview when the image was taken. So, if the 
 *  device was held landscape left, the image returned will be set to display so that landscape left
 *  is "up". This is great if your interface doesn't rotate, or if the photo was taken
 *  with orientation lock on.
 */
@property (nonatomic, strong) UIImage *rotatedPreviewImage;

/**
 *  Whether the images have finished being redrawn so that their orientations are UIImageOrientationUp.
 *  This is a slower process than the initial images that are returned which have varying orientations, but
 *  they are more ideal for uploading or saving as they are displayed more predictably in different browsers
 *  and applications than rotated images with an orientation tag set that is not UIImageOrientationUp.
 */
@property (nonatomic, assign) BOOL isNormalized;

/**
 *  The orientation that the image was captured with, useful if you are doing additional image editing
 *  using the rotated preview image.
 */
@property (nonatomic, assign) UIImageOrientation capturedImageOrientation;

@end
