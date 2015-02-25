//
//  UIImage+FastttCamera.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

@import UIKit;
@import AVFoundation;

@interface UIImage (FastttCamera)

/**
 *  Crops the captured image to the visible area of the preview layer.
 *
 *  @param previewLayer The preview layer of the camera's live preview.
 *
 *  @return The cropped image.
 */
- (UIImage *)fastttCroppedToPreviewLayerBounds:(AVCaptureVideoPreviewLayer *)previewLayer;

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
- (UIImage *)fastttCroppedToOutputRect:(CGRect)outputRect;

/**
 *  Crops the image to the given CGRect origin, width, and height.
 *
 *  @param cropRect The CGRect to use for cropping the image.
 *
 *  @return The cropped image.
 */
- (UIImage *)fastttCroppedToRect:(CGRect)cropRect;

/**
 *  Scales the image to the given size.
 *
 *  @param size The destination size of the image.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledToSize:(CGSize)size;

/**
 *  Scales the image to the given maximum dimension.
 *
 *  @param size The destination maximum dimension of the image.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledToMaxDimension:(CGFloat)maxDimension;

/**
 *  Scales the image to the given scale.
 *
 *  @param newScale The scale for the image.
 *
 *  @return The scaled image.
 */
- (UIImage *)fastttScaledToScale:(CGFloat)newScale;

/**
 *  Redraws the image so that its orientation is UIImageOrientationUp.
 *
 *  @return An image drawn so that the orientation is UIImageOrientationUp.
 */
- (UIImage *)fastttNormalizeOrientation;

/**
 *  Sets the image orientation so that the image displays in the same
 *  orientation as the camera preview when the image was taken. So, if the device
 *  was held landscape left, the image returned will be set to display so that landscape left
 *  is "up". This is great if your interface doesn't rotate, or if the photo was taken
 *  with orientation lock on.
 *
 *  @return The image that has been rotated to match the camera preview.
 */
- (UIImage *)fastttRotatedToMatchCameraView;

/**
 *  Creates a fake image for testing.
 *
 *  @return The fake image.
 */
+ (UIImage *)fastttFakeTestImage;

@end
