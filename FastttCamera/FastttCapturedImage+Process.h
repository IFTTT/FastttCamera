//
//  FastttCapturedImage+Process.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttCapturedImage.h"

/**
 *  Private category used by FastttCamera for processing FastttCapturedImages.
 */
@interface FastttCapturedImage (Process)

/**
 *  Processes the captured image by cropping and returning a rotated preview as necessary.
 *
 *  @param cropRect             The CGRect to use for cropping. Use CGRectNull for no cropping.
 *  @param returnsPreview       YES if the FastttCapturedImage should set its rotatedPreviewImage property.
 *  @param needsPreviewRotation YES if the image needs its imageOrientation tag changed for displaying a preview.
 *  @param previewOrientation   The orientation to use for the preview view (usually UIDeviceOrientationPortrait)
 *  @param callback             The callback fired after image cropping and preview processing is complete
 *  and the FastttCapturedImage fullImage and rotatedPreviewImage properties have been set as needed.
 */
- (void)cropToRect:(CGRect)cropRect
    returnsPreview:(BOOL)returnsPreview
needsPreviewRotation:(BOOL)needsPreviewRotation
withPreviewOrientation:(UIDeviceOrientation)previewOrientation
      withCallback:(void (^)(FastttCapturedImage *capturedImage))callback;

/**
 *  Processes the captured image by scaling to the given maximum dimension.
 *
 *  @param maxDimension The maximum dimension to use for scaling the image.
 *  @param callback     The callback fired after image scaling is complete and the FastttCapturedImage scaledImage
 *  property has been set.
 */
- (void)scaleToMaxDimension:(CGFloat)maxDimension
               withCallback:(void (^)(FastttCapturedImage *capturedImage))callback;

/**
 *  Processes the captured image by scaling to the given size.
 *
 *  @param size         The output size to use for scaling the image. Assumes that this size and the image have
 *  the same aspect ratio.
 *
 *  @param callback     The callback fired after image scaling is complete and the FastttCapturedImage scaledImage
 *  property has been set.
 */
- (void)scaleToSize:(CGSize)size
       withCallback:(void (^)(FastttCapturedImage *capturedImage))callback;

/**
 *  Processes the captured image by normalizing the fullImage and scaledImage to have UIImageOrientationUp.
 *
 *  @param callback     The callback fired after image normalization is complete and the FastttCapturedImage scaledImage
 *  and fullImage and isNormalized properties have been set appropriately.
 */
- (void)normalizeWithCallback:(void (^)(FastttCapturedImage *capturedImage))callback;

@end
