//
//  UIImage+FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

#import "UIImage+FastttCamera.h"
@import UIKit;

CG_INLINE CGFLOAT_TYPE FastttRound(CGFLOAT_TYPE f) {
#if CGFLOAT_IS_DOUBLE
    return round(f);
#else
    return roundf(f);
#endif
};

@implementation UIImage (FastttCamera)

- (UIImage *)fastttCroppedToPreviewLayerBounds:(AVCaptureVideoPreviewLayer *)previewLayer
{
    CGRect outputRect = [previewLayer metadataOutputRectOfInterestForRect:previewLayer.bounds];
    
    return [self fastttCroppedToOutputRect:outputRect];
}

- (CGRect)fastttCropRectFromOutputRect:(CGRect)outputRect
{
    return CGRectMake(FastttRound(CGRectGetMinX(outputRect) * CGImageGetWidth(self.CGImage)),
                      FastttRound(CGRectGetMinY(outputRect) * CGImageGetHeight(self.CGImage)),
                      FastttRound(CGRectGetWidth(outputRect) * CGImageGetWidth(self.CGImage)),
                      FastttRound(CGRectGetHeight(outputRect) * CGImageGetHeight(self.CGImage)));
}

- (UIImage *)fastttCroppedToOutputRect:(CGRect)outputRect
{
    CGRect cropRect = [self fastttCropRectFromOutputRect:outputRect];
    return [self fastttCroppedToRect:cropRect];
}

- (UIImage *)fastttCroppedToRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:self.scale
                                          orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)fastttScaledToSize:(CGSize)size
{
    CGImageRef imageRef = self.CGImage;
    CGFloat newScale = (CGFloat)(MIN(size.width, size.height) / MIN((CGFloat)CGImageGetWidth(imageRef), (CGFloat)CGImageGetHeight(imageRef)));
    
    return [self fastttScaledToScale:newScale];
}

- (UIImage *)fastttScaledToMaxDimension:(CGFloat)maxDimension
{
    CGImageRef imageRef = self.CGImage;
    CGFloat newScale = (CGFloat)(maxDimension / MAX((CGFloat)CGImageGetWidth(imageRef), (CGFloat)CGImageGetHeight(imageRef)));
    
    return [self fastttScaledToScale:newScale];
}

- (UIImage *)fastttScaledToScale:(CGFloat)newScale
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

- (UIImage *)fastttNormalizeOrientation
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

- (UIImage *)fastttRotatedToMatchCameraView
{
    UIImageOrientation orientation = UIImageOrientationRight;
    
    if (self.imageOrientation == UIImageOrientationRightMirrored
        || self.imageOrientation == UIImageOrientationLeftMirrored
        || self.imageOrientation == UIImageOrientationUpMirrored
        || self.imageOrientation == UIImageOrientationDownMirrored) {
        
        orientation = UIImageOrientationLeftMirrored;
    }
    
    if (orientation == self.imageOrientation) {
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
