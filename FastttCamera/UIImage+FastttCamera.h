//
//  UIImage+FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 *  Private category used by FastttCamera for processing UIImages.
 */
@interface UIImage (FastttCamera)

/**
 *  Calculates a crop rect for the aperture fitting into the preview bounds with aspect fill.
 *
 *  @param previewBounds  The bounds of the view displaying the camera preview.
 *  @param apertureBounds The bounds of the camera's output.
 *
 *  @return The CGRect to use for cropping the camera's captured image to match the camera preview.
 */
+ (CGRect)fastttCropRectFromPreviewBounds:(CGRect)previewBounds apertureBounds:(CGRect)apertureBounds;

/**
 *  Calculates a crop rect for cropping the captured image to the visible area of the preview layer.
 *
 *  @param previewLayer The preview layer of the camera's live preview.
 *
 *  @return The CGRect to use for cropping the camera's captured image to match the camera preview.
 */
- (CGRect)fastttCropRectFromPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

/**
 *  Calculates a crop rect for the image fitting into the preview bounds with aspect fill.
 *
 *  @param previewBounds  The bounds of the view displaying the camera preview.
 *
 *  @return The CGRect to use for cropping the camera's captured image to match the camera preview.
 */
- (CGRect)fastttCropRectFromPreviewBounds:(CGRect)previewBounds;

/**
 *  Converts the 0-to-1-scaled output rect to a crop rect for this image
 *
 *  @param outputRect The 0-to-1-scaled output rect to convert
 *
 *  @return The CGRect to use to crop this image
 */
- (CGRect)fastttCropRectFromOutputRect:(CGRect)outputRect;

/**
 *  Crops the image to the given output CGRect, which has its origin and dimensions scaled from 0 to 1,
 *  to match the output of AVFoundation's metadataOutputRectOfInterestForRect.
 *
 *  @param outputRect The 0-to-1-scaled CGRect to use for cropping the image.
 *
 *  @return The cropped image.
 */
- (UIImage *)fastttCroppedImageFromOutputRect:(CGRect)outputRect;

/**
 *  Crops the image to the given CGRect origin, width, and height.
 *
 *  @param cropRect The CGRect to use for cropping the image.
 *
 *  @return The cropped image.
 */
- (UIImage *)fastttCroppedImageFromCropRect:(CGRect)cropRect;

/**
 *  Scales the image to the given size.
 *
 *  @param size The destination size of the image. Assumes that this size and the image have
 *  the same aspect ratio.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledImageOfSize:(CGSize)size;

/**
 *  Scales the image to the given maximum dimension.
 *
 *  @param size The destination maximum dimension of the image.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledImageWithMaxDimension:(CGFloat)maxDimension;

/**
 *  Scales the image to the given scale.
 *
 *  @param newScale The scale for the image.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledImageWithScale:(CGFloat)newScale;

/**
 *  Redraws the image so that its orientation is UIImageOrientationUp.
 *
 *  @return An image drawn so that the orientation is UIImageOrientationUp.
 */
- (UIImage *)fastttImageWithNormalizedOrientation;

/**
 *  Sets the image orientation so that the image displays in the same
 *  orientation as the camera preview when the image was taken. So, if the device
 *  was held landscape left, the image returned will be set to display so that landscape left
 *  is "up". This is great if your interface doesn't rotate, or if the photo was taken
 *  with orientation lock on.
 *
 *  @param deviceOrientation The orientation of the preview view.
 *
 *  @return The image that has been rotated to match the camera preview.
 */
- (UIImage *)fastttRotatedImageMatchingCameraViewWithOrientation:(UIDeviceOrientation)deviceOrientation;

/**
 *  Moves the image orientation tag of the image to the given image orientation.
 *  The pixels of the image stay as-is.
 *
 *  @param orientation The image orientation tag to set.
 *
 *  @return The image that has had its new orientation tag set.
 */
- (UIImage *)fastttRotatedImageMatchingOrientation:(UIImageOrientation)orientation;

/**
 *  Creates a fake image for testing.
 *
 *  @return The fake image.
 */
+ (UIImage *)fastttFakeTestImage;

@end
