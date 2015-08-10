//
//  FastttCameraSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FastttCamera/FastttCamera.h>

SpecBegin(FastttCamera)

describe(@"FastttCamera", ^{
    __block FastttCamera *fastCamera;
    __block id delegate;
    
    beforeAll(^{
        // This is run once and only once before all of the examples
        // in this group and before any beforeEach blocks.
        fastCamera = [FastttCamera new];
        [fastCamera loadView];
        fastCamera.view.frame = CGRectMake(0.f, 0.f, 100.f, 200.f);
        [fastCamera beginAppearanceTransition:YES animated:NO];
        [fastCamera endAppearanceTransition];
        
        delegate = [OCMockObject mockForProtocol:@protocol(FastttCameraDelegate)];
        
        fastCamera.delegate = delegate;
    });
    
    it(@"can be created", ^{
        expect(fastCamera).toNot.beNil();
    });
    
    describe(@"Process a back camera portrait style photo", ^{
        __block UIImage *image;
        
        beforeAll(^{
            image = [UIImage imageNamed:@"FastttCameraTestRight.png"];
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:UIImageOrientationRight];
        });
        
        it(@"returns the full image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = NO;
            fastCamera.returnsRotatedPreview = NO;
            fastCamera.scalesImage = NO;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.fullImage.size.width == 400.f
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationRight
                    && !capturedImage.rotatedPreviewImage
                    && !capturedImage.scaledImage
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectNull];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the cropped image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = NO;
            fastCamera.scalesImage = NO;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.fullImage.size.width < 400.f
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationRight
                    && !capturedImage.rotatedPreviewImage
                    && !capturedImage.scaledImage
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectMake(10.f, 20.f, 100.f, 200.f)];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the scaled image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = YES;
            fastCamera.scalesImage = YES;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishScalingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.scaledImage
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationRight
                    && capturedImage.scaledImage.imageOrientation == UIImageOrientationRight
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withMaxDimension:100.f];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the normalized images", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = YES;
            fastCamera.scalesImage = YES;
            fastCamera.normalizesImageOrientations = YES;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishScalingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishNormalizingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.scaledImage
                    && capturedImage.isNormalized
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationUp
                    && capturedImage.scaledImage.imageOrientation == UIImageOrientationUp) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectMake(10.f, 20.f, 100.f, 200.f) maxDimension:100.f];
            [delegate verifyWithDelay:0.5f];
        });
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            image = nil;
        });
    });
    
    describe(@"Process a front camera portrait style photo", ^{
        __block UIImage *image;
        
        beforeAll(^{
            image = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:UIImageOrientationLeftMirrored];
        });
        
        it(@"returns the full image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = NO;
            fastCamera.returnsRotatedPreview = NO;
            fastCamera.scalesImage = NO;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.fullImage.size.width == 400.f
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationLeftMirrored
                    && !capturedImage.rotatedPreviewImage
                    && !capturedImage.scaledImage
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectNull];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the cropped image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = NO;
            fastCamera.scalesImage = NO;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.fullImage.size.width < 400.f
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationLeftMirrored
                    && !capturedImage.rotatedPreviewImage
                    && !capturedImage.scaledImage
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectMake(10.f, 20.f, 100.f, 200.f)];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the scaled image", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = YES;
            fastCamera.scalesImage = YES;
            fastCamera.normalizesImageOrientations = NO;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishScalingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.scaledImage
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationLeftMirrored
                    && capturedImage.scaledImage.imageOrientation == UIImageOrientationLeftMirrored
                    && !capturedImage.isNormalized) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withMaxDimension:100.f];
            [delegate verifyWithDelay:0.5f];
        });
        
        it(@"returns the normalized images", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = YES;
            fastCamera.scalesImage = YES;
            fastCamera.normalizesImageOrientations = YES;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishScalingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishNormalizingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.scaledImage
                    && capturedImage.isNormalized
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationUp
                    && capturedImage.scaledImage.imageOrientation == UIImageOrientationUp) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera processImage:image withCropRect:CGRectMake(10.f, 20.f, 100.f, 200.f) maxDimension:100.f];
            [delegate verifyWithDelay:0.5f];
        });
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            image = nil;
        });
    });
    
    describe(@"Taking a photo", ^{
        it(@"takes a photo", ^{
            fastCamera.cropsImageToVisibleAspectRatio = YES;
            fastCamera.returnsRotatedPreview = YES;
            fastCamera.scalesImage = YES;
            fastCamera.normalizesImageOrientations = YES;
            
            [[delegate expect] cameraController:fastCamera didFinishCapturingImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishScalingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [[delegate expect] cameraController:fastCamera didFinishNormalizingCapturedImage:[OCMArg checkWithBlock:^BOOL(id value) {
                FastttCapturedImage *capturedImage = (FastttCapturedImage *)value;
                if (capturedImage.fullImage
                    && capturedImage.scaledImage
                    && capturedImage.isNormalized
                    && capturedImage.fullImage.imageOrientation == UIImageOrientationUp
                    && capturedImage.scaledImage.imageOrientation == UIImageOrientationUp) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            [fastCamera takePicture];
            [delegate verifyWithDelay:1.f];
        });
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
        fastCamera = nil;
    });
    
});

SpecEnd
