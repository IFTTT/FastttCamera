//
//  UIImage+FastttFilters.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/3/15.
//
//

#import <UIKit/UIKit.h>

/**
 *  Public UIImage category you can use to apply filters to static image on your photo edit/confirm screen.
 */
@interface UIImage (FastttFilters)

/**
 *  Returns an image that has been filtered using the given filterImage,
 *  which should be created from 512 x 512 png lookup image as shown in the example app.
 *
 *  @note You can edit the lookup image found in FiltersExample/Resources using your favorite
 *  image editing application, but make sure to only apply effects to the lookup image that are
 *  independent of the surrounding pixels, such as Contrast, Brightness, Hue, Levels, Color Multiply, etc.
 *  The lookup image will not work with effects such as Vignette or Blur, because they are dependent upon
 *  the location of the pixels, and not simply on the color.
 *  Remember to save it as an uncompressed 512 x 512 png image when you're done.
 *
 *  @param filterImage The 512 x 512 png lookup image to use for filtering this image.
 *
 *  @return The filtered image.
 */
- (UIImage *)fastttFilteredImageWithFilter:(UIImage *)filterImage;

@end
