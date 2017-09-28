//
//  UIImage+FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

#import "UIImage+FastttCamera.h"
#import <UIKit/UIKit.h>

CG_INLINE CGFLOAT_TYPE FastttRound(CGFLOAT_TYPE f) {
#if CGFLOAT_IS_DOUBLE
    return round(f);
#else
    return roundf(f);
#endif
};

@implementation UIImage (FastttCamera)

+ (CGRect)fastttCropRectFromPreviewBounds:(CGRect)previewBounds apertureBounds:(CGRect)apertureBounds
{
    CGSize apertureSize = apertureBounds.size;
    
    CGFloat apertureRatio = apertureSize.width / apertureSize.height;
    CGFloat viewRatio = previewBounds.size.width / previewBounds.size.height;
    
    CGFloat xOrigin = 0.f;
    CGFloat yOrigin = 0.f;
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    
    if (apertureRatio > viewRatio) {
        width = viewRatio * apertureSize.height;
        height = apertureSize.height;
        
        xOrigin = (apertureSize.width - width) / 2.f;
        yOrigin = 0.f;
    } else {
        width = apertureSize.width;
        height = apertureSize.width / viewRatio;
        
        xOrigin = 0.f;
        yOrigin = (apertureSize.height - height) / 2.f;
    }
    
    return CGRectMake(xOrigin, yOrigin, width, height);
}

- (CGRect)fastttCropRectFromPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
{
    CGRect outputRect = [previewLayer metadataOutputRectOfInterestForRect:previewLayer.bounds];
    
    return [self fastttCropRectFromOutputRect:outputRect];
}

- (CGRect)fastttCropRectFromPreviewBounds:(CGRect)previewBounds
{
    CGSize imageSize = self.size;
    
    CGSize previewSize = previewBounds.size;
    
    if (self.imageOrientation == UIImageOrientationRight
        || self.imageOrientation == UIImageOrientationLeft
        || self.imageOrientation == UIImageOrientationRightMirrored
        || self.imageOrientation == UIImageOrientationLeftMirrored) {
        
        previewSize = CGSizeMake(previewSize.height, previewSize.width);
    }
    
    CGFloat imageRatio = imageSize.width / imageSize.height;
    CGFloat viewRatio = previewBounds.size.width / previewBounds.size.height;
    
    CGFloat xOrigin = 0.f;
    CGFloat yOrigin = 0.f;
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    
    if (imageRatio > viewRatio) {
        width = viewRatio * imageSize.height;
        height = imageSize.height;
        
        xOrigin = (imageSize.width - width) / 2.f;
        yOrigin = 0.f;
    } else {
        width = imageSize.width;
        height = imageSize.width / viewRatio;
        
        xOrigin = 0.f;
        yOrigin = (imageSize.height - height) / 2.f;
    }
    
    return CGRectMake(xOrigin, yOrigin, width, height);
}

- (CGRect)fastttCropRectFromOutputRect:(CGRect)outputRect
{
    return CGRectMake(FastttRound(CGRectGetMinX(outputRect) * CGImageGetWidth(self.CGImage)),
                      FastttRound(CGRectGetMinY(outputRect) * CGImageGetHeight(self.CGImage)),
                      FastttRound(CGRectGetWidth(outputRect) * CGImageGetWidth(self.CGImage)),
                      FastttRound(CGRectGetHeight(outputRect) * CGImageGetHeight(self.CGImage)));
}

- (UIImage *)fastttCroppedImageFromOutputRect:(CGRect)outputRect
{
    CGRect cropRect = [self fastttCropRectFromOutputRect:outputRect];
    
    return [self fastttCroppedImageFromCropRect:cropRect];
}

- (UIImage *)fastttCroppedImageFromCropRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:self.scale
                                          orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)fastttScaledImageOfSize:(CGSize)size
{
    CGImageRef imageRef = self.CGImage;
    CGFloat newScale = (CGFloat)(MIN(size.width, size.height) / MIN((CGFloat)CGImageGetWidth(imageRef), (CGFloat)CGImageGetHeight(imageRef)));
    
    return [self fastttScaledImageWithScale:newScale];
}

- (UIImage *)fastttScaledImageWithMaxDimension:(CGFloat)maxDimension
{
    CGImageRef imageRef = self.CGImage;
    CGFloat newScale = (CGFloat)(maxDimension / MAX((CGFloat)CGImageGetWidth(imageRef), (CGFloat)CGImageGetHeight(imageRef)));
    
    return [self fastttScaledImageWithScale:newScale];
}

- (UIImage *)fastttScaledImageWithScale:(CGFloat)newScale
{
    CGImageRef imageRef = self.CGImage;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat width = (CGImageGetWidth(imageRef) * newScale * scale);
    CGFloat height = (CGImageGetHeight(imageRef) * newScale * scale);
    
    CGRect newRect = CGRectMake(0.f,
                                0.f,
                                FastttRound(width),
                                FastttRound(height));
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)CGRectGetWidth(newRect),
                                                 (size_t)CGRectGetHeight(newRect),
                                                 bitsPerComponent,
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    if (!context)
        return nil;
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextDrawImage(context, newRect, imageRef);
    
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(context);
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef
                                               scale:scale
                                         orientation:self.imageOrientation];
    
    CFRelease(context);
    CGImageRelease(scaledImageRef);
    
    return scaledImage;
}

- (UIImage *)fastttImageWithNormalizedOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    CGRect newRect = CGRectMake(0.f,
                                0.f,
                                FastttRound(self.size.width),
                                FastttRound(self.size.height));
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, YES, self.scale);
    [self drawInRect:newRect];
    
    UIImage *normalized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalized;
}

- (UIImage *)fastttRotatedImageMatchingCameraViewWithOrientation:(UIDeviceOrientation)deviceOrientation
{
    BOOL isMirrored = NO;
    if (self.imageOrientation == UIImageOrientationRightMirrored
        || self.imageOrientation == UIImageOrientationLeftMirrored
        || self.imageOrientation == UIImageOrientationUpMirrored
        || self.imageOrientation == UIImageOrientationDownMirrored) {
        
        isMirrored = YES;
    }
    
    UIImageOrientation orientation = [self.class fastttPreviewImageOrientationForDeviceOrientation:deviceOrientation isMirrored:isMirrored];
    
    return [self fastttRotatedImageMatchingOrientation:orientation];
}

+ (UIImageOrientation)fastttPreviewImageOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation isMirrored:(BOOL)isMirrored
{
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            return (isMirrored ? UIImageOrientationUpMirrored : UIImageOrientationUp);
        case UIDeviceOrientationLandscapeRight:
            return (isMirrored ? UIImageOrientationDownMirrored : UIImageOrientationDown);
        default:
            break;
    }
    
    // default to UIDeviceOrientationPortrait
    return (isMirrored ? UIImageOrientationLeftMirrored : UIImageOrientationRight);
}

- (UIImage *)fastttRotatedImageMatchingOrientation:(UIImageOrientation)orientation
{
    if (self.imageOrientation == orientation) {
        return self;
    }
    
    return [UIImage imageWithCGImage:self.CGImage
                               scale:self.scale
                         orientation:orientation];
}

+ (UIImage *)fastttFakeTestImage
{
    CGSize size = CGSizeMake(2000.f, 1500.f);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor greenColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
