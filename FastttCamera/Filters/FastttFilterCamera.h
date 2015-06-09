//
//  FastttFilterCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/5/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastttCameraInterface.h"

/**
 *  Public class for you to use to create a filtered FastttFilterCamera!
 *
 *  @note The full interface for the FastttFilterCamera can be found in
 *  the FastttCameraInterface protocol.
 *
 *  @note If you don't want to use filters with your live camera preview,
 *  use an instance of the standard FastttCamera instead.
 */
@interface FastttFilterCamera : UIViewController <FastttCameraInterface>

/**
 *  The current lookup image for filtering both the camera's live preview and the captured image, 
 *  which should be created from 512 x 512 png lookup image found in FiltersExample/Resources, 
 *  as shown in the example app.
 *
 *  @note You can edit the lookup image found in FiltersExample/Resources using your favorite
 *  image editing application, but make sure to only apply effects to the lookup image that are
 *  independent of the surrounding pixels, such as Contrast, Brightness, Hue, Levels, Color Multiply, etc.
 *  The lookup image will not work with effects such as Vignette or Blur, because they are dependent upon
 *  the location of the pixels, and not simply on the color.
 *  Remember to save it as an uncompressed 512 x 512 png image when you're done.
 *
 *  @note Setting this property to nil will leave a plain, unfiltered camera.
 */
@property (nonatomic, strong) UIImage *filterImage;

/**
 *  Returns an instance of FastttFilterCamera with the given lookup image applied to both the camera's live
 *  preview and any captured images.
 *
 *  @param filterImage The lookup image to use for filtering the camera's preview and the captured images.
 *  Setting this to nil will return a plain, unfiltered camera.
 *
 *  @note If you want to apply changeable filters to your photos only after they have been captured, and not to the
 *  camera's live preview and captured images, use FastttCamera instead for slightly faster camera performance, 
 *  and use the methods in UIImage+FastttFilters to apply filters to your captured UIImages.
 *
 *  @return An instance of FastttFilterCamera.
 */
+ (instancetype)cameraWithFilterImage:(UIImage *)filterImage;

@end
