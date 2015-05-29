//
//  FastttCapturedImage+Process.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttCapturedImage+Process.h"
#import "UIImage+FastttCamera.h"

@implementation FastttCapturedImage (Process)

- (void)cropToRect:(CGRect)cropRect
    returnsPreview:(BOOL)returnsPreview
needsPreviewRotation:(BOOL)needsPreviewRotation
withPreviewOrientation:(UIDeviceOrientation)previewOrientation
      withCallback:(void (^)(FastttCapturedImage *capturedImage))callback
{
    if (!CGRectEqualToRect(cropRect, CGRectNull) && !CGRectEqualToRect(cropRect, CGRectZero)) {
        self.fullImage = [self.fullImage fastttCroppedImageFromCropRect:cropRect];
    }
    
    self.capturedImageOrientation = self.fullImage.imageOrientation;
    
    if (returnsPreview) {
        UIImage *previewImage;
        if (needsPreviewRotation) {
            previewImage = [self.fullImage fastttRotatedImageMatchingCameraViewWithOrientation:previewOrientation];
        } else {
            previewImage = self.fullImage;
        }
        self.rotatedPreviewImage = previewImage;
    }
    
    if (callback) {
        callback(self);
    }
}

- (void)scaleToMaxDimension:(CGFloat)maxDimension
               withCallback:(void (^)(FastttCapturedImage *capturedImage))callback
{
    self.scaledImage = [self.fullImage fastttScaledImageWithMaxDimension:maxDimension];
    
    if (callback) {
        callback(self);
    }
}

- (void)scaleToSize:(CGSize)size
       withCallback:(void (^)(FastttCapturedImage *capturedImage))callback
{
    self.scaledImage = [self.fullImage fastttScaledImageOfSize:size];
    
    if (callback) {
        callback(self);
    }
}

- (void)normalizeWithCallback:(void (^)(FastttCapturedImage *capturedImage))callback
{
    UIImage *normalizedFullImage = [self.fullImage fastttImageWithNormalizedOrientation];
    UIImage *normalizedScaledImage = [self.scaledImage fastttImageWithNormalizedOrientation];
    
    self.fullImage = normalizedFullImage;
    self.scaledImage = normalizedScaledImage;
    self.isNormalized = YES;
    
    if (callback) {
        callback(self);
    }
}

@end
