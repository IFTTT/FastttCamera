//
//  UIImageFastttCameraSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/20/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

//#define IS_RECORDING

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#include <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <FastttCamera/UIImage+FastttCamera.h>

SpecBegin(UIImageFastttCamera)

describe(@"UIImageFastttCamera", ^{
    __block UIImage *image;
    __block UIImage *rightImage;
    __block UIImage *mirroredImage;
    
    beforeAll(^{
        // This is run once and only once before all of the examples
        // in this group and before any beforeEach blocks.
        image = [UIImage imageNamed:@"FastttCameraTest.png"];
        rightImage = [UIImage imageNamed:@"FastttCameraTestRight.png"];
        rightImage = [UIImage imageWithCGImage:rightImage.CGImage
                                         scale:rightImage.scale
                                   orientation:UIImageOrientationRight];
        
        mirroredImage = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
        mirroredImage = [UIImage imageWithCGImage:mirroredImage.CGImage
                                            scale:mirroredImage.scale
                                      orientation:UIImageOrientationLeftMirrored];
    });
    
    describe(@"Test Images", ^{
        
        it(@"should not return nil", ^{
            expect(image).toNot.beNil;
            expect(rightImage).toNot.beNil;
            expect(mirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(image).to.beKindOf([UIImage class]);
            expect(rightImage).to.beKindOf([UIImage class]);
            expect(mirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should have the correct image orientation", ^{
            expect(image.imageOrientation).to.equal(UIImageOrientationUp);
            expect(rightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(mirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should have the correct width", ^{
            expect(image.size.width).to.equal(400.f);
            expect(rightImage.size.width).to.equal(400.f);
            expect(mirroredImage.size.width).to.equal(400.f);
        });
        
        it(@"should have the correct height", ^{
            expect(image.size.height).to.equal(320.f);
            expect(rightImage.size.height).to.equal(320.f);
            expect(mirroredImage.size.height).to.equal(320.f);
        });
#if TARGET_IPHONE_SIMULATOR
        it(@"records snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            expect(imageView).toNot.recordSnapshotNamed(@"TestImage");
        });
        
        it(@"matches snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
#ifdef IS_RECORDING
            expect(imageView).to.recordSnapshotNamed(@"TestImage");
#endif
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
        
        it(@"matches snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:rightImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
        
        it(@"matches snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:mirroredImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
#endif
    });
    
    describe(@"Image Crop Rect From Preview Bounds", ^{
        
        it(@"should crop taller aperture correctly", ^{
            CGRect previewBounds = CGRectMake(0.f, 0.f, 100.f, 100.f);
            CGRect apertureBounds = CGRectMake(0.f, 0.f, 200.f, 400.f);
            CGRect cropRect = [UIImage fastttCropRectFromPreviewBounds:previewBounds apertureBounds:apertureBounds];

            expect(CGRectGetWidth(cropRect) / CGRectGetHeight(cropRect)).to.equal(CGRectGetWidth(previewBounds) / CGRectGetHeight(previewBounds));
            expect(CGRectGetWidth(cropRect)).to.equal(CGRectGetWidth(apertureBounds));
        });
        
        it(@"should crop wider aperture correctly", ^{
            CGRect previewBounds = CGRectMake(0.f, 0.f, 100.f, 100.f);
            CGRect apertureBounds = CGRectMake(0.f, 0.f, 400.f, 200.f);
            CGRect cropRect = [UIImage fastttCropRectFromPreviewBounds:previewBounds apertureBounds:apertureBounds];
            
            expect(CGRectGetWidth(cropRect) / CGRectGetHeight(cropRect)).to.equal(CGRectGetWidth(previewBounds) / CGRectGetHeight(previewBounds));
            expect(CGRectGetHeight(cropRect)).to.equal(CGRectGetHeight(apertureBounds));
        });
    });
    
    describe(@"Image Output Rect Cropping", ^{
        __block UIImage *croppedImage;
        __block UIImage *croppedRightImage;
        __block UIImage *croppedMirroredImage;
        
        beforeAll(^{
            // This is run once and only once before all of the examples
            // Expected crop rect for 400 x 320 image size: CGRectMake(40.f, 64.f, 100.f, 240.f)
            // Expected crop rect for 320 x 400 image size (rotated images): CGRectMake(32.f, 80.f, 80.f, 300.f)
            // Expected size for left or right orientation image after cropping: CGSizeMake(300.f, 80.f)
            CGRect outputRect = CGRectMake(0.1f, 0.2f, 0.25f, 0.75f);
            
            croppedImage = [image fastttCroppedImageFromOutputRect:outputRect];
            croppedRightImage = [rightImage fastttCroppedImageFromOutputRect:outputRect];
            croppedMirroredImage = [mirroredImage fastttCroppedImageFromOutputRect:outputRect];
        });
        
        it(@"should not return nil", ^{
            expect(croppedImage).toNot.beNil;
            expect(croppedRightImage).toNot.beNil;
            expect(croppedMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(croppedImage).to.beKindOf([UIImage class]);
            expect(croppedRightImage).to.beKindOf([UIImage class]);
            expect(croppedMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should crop to correct width", ^{
            expect(croppedImage.size.width).to.equal(100.f);
            expect(croppedRightImage.size.width).to.equal(300.f);
            expect(croppedMirroredImage.size.width).to.equal(300.f);
        });
        
        it(@"should crop to correct height", ^{
            expect(croppedImage.size.height).to.equal(240.f);
            expect(croppedRightImage.size.height).to.equal(80.f);
            expect(croppedMirroredImage.size.height).to.equal(80.f);
        });
        
        it(@"should return the correct x origin for cropping", ^{
            CGRect outputRect = CGRectMake(0.1f, 0.2f, 0.25f, 0.75f);
            expect(CGRectGetMinX((CGRect)[image fastttCropRectFromOutputRect:outputRect])).to.equal(40.f);
            expect(CGRectGetMinX((CGRect)[rightImage fastttCropRectFromOutputRect:outputRect])).to.equal(32.f);
            expect(CGRectGetMinX((CGRect)[mirroredImage fastttCropRectFromOutputRect:outputRect])).to.equal(32.f);
        });
        
        it(@"should return the correct y origin for cropping", ^{
            CGRect outputRect = CGRectMake(0.1f, 0.2f, 0.25f, 0.75f);
            expect(CGRectGetMinY((CGRect)[image fastttCropRectFromOutputRect:outputRect])).to.equal(64.f);
            expect(CGRectGetMinY((CGRect)[rightImage fastttCropRectFromOutputRect:outputRect])).to.equal(80.f);
            expect(CGRectGetMinY((CGRect)[mirroredImage fastttCropRectFromOutputRect:outputRect])).to.equal(80.f);
        });
        
        it(@"should not change image orientation", ^{
            expect(croppedImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(croppedRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(croppedMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should not change image scale property", ^{
            expect(croppedImage.scale).to.equal(image.scale);
            expect(croppedRightImage.scale).to.equal(rightImage.scale);
            expect(croppedMirroredImage.scale).to.equal(mirroredImage.scale);
        });
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            croppedImage = nil;
            croppedRightImage = nil;
            croppedMirroredImage = nil;
        });
    });
    
    describe(@"Image Crop Rect Cropping", ^{
        __block UIImage *croppedImage;
        __block UIImage *croppedRightImage;
        __block UIImage *croppedMirroredImage;
        
        beforeAll(^{
            // This is run once and only once before all of the examples
            // Expected crop rect for 400 x 320 image size: CGRectMake(40.f, 64.f, 100.f, 240.f)
            // Expected size for left or right orientation image after cropping: CGSizeMake(240.f, 100.f)
            CGRect cropRect = CGRectMake(40.f, 64.f, 100.f, 240.f);
            
            croppedImage = [image fastttCroppedImageFromCropRect:cropRect];
            croppedRightImage = [rightImage fastttCroppedImageFromCropRect:cropRect];
            croppedMirroredImage = [mirroredImage fastttCroppedImageFromCropRect:cropRect];
        });
        
        it(@"should not return nil", ^{
            expect(croppedImage).toNot.beNil;
            expect(croppedRightImage).toNot.beNil;
            expect(croppedMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(croppedImage).to.beKindOf([UIImage class]);
            expect(croppedRightImage).to.beKindOf([UIImage class]);
            expect(croppedMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should crop to correct width", ^{
            expect(croppedImage.size.width).to.equal(100.f);
            expect(croppedRightImage.size.width).to.equal(240.f);
            expect(croppedMirroredImage.size.width).to.equal(240.f);
        });
        
        it(@"should crop to correct height", ^{
            expect(croppedImage.size.height).to.equal(240.f);
            expect(croppedRightImage.size.height).to.equal(100.f);
            expect(croppedMirroredImage.size.height).to.equal(100.f);
        });
        
        it(@"should not change image orientation", ^{
            expect(croppedImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(croppedRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(croppedMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should not change image scale property", ^{
            expect(croppedImage.scale).to.equal(image.scale);
            expect(croppedRightImage.scale).to.equal(rightImage.scale);
            expect(croppedMirroredImage.scale).to.equal(mirroredImage.scale);
        });
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            croppedImage = nil;
            croppedRightImage = nil;
            croppedMirroredImage = nil;
        });
    });
    
    describe(@"Image Scale To Size", ^{
        __block UIImage *scaledImage;
        __block UIImage *scaledRightImage;
        __block UIImage *scaledMirroredImage;
        
        beforeAll(^{
            // This is run before each example
            CGSize scaledSize = CGSizeMake(100.f, 80.f);
            
            scaledImage = [image fastttScaledImageOfSize:scaledSize];
            scaledRightImage = [rightImage fastttScaledImageOfSize:scaledSize];
            scaledMirroredImage = [mirroredImage fastttScaledImageOfSize:scaledSize];
        });
        
        it(@"should not return nil", ^{
            expect(scaledImage).toNot.beNil;
            expect(scaledRightImage).toNot.beNil;
            expect(scaledMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(scaledImage).to.beKindOf([UIImage class]);
            expect(scaledRightImage).to.beKindOf([UIImage class]);
            expect(scaledMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should scale to correct width", ^{
            expect(scaledImage.size.width).to.equal(100.f);
            expect(scaledRightImage.size.width).to.equal(100.f);
            expect(scaledMirroredImage.size.width).to.equal(100.f);
        });
        
        it(@"should scale to correct height", ^{
            expect(scaledImage.size.height).to.equal(80.f);
            expect(scaledRightImage.size.height).to.equal(80.f);
            expect(scaledMirroredImage.size.height).to.equal(80.f);
        });
        
        it(@"should not change image orientation", ^{
            expect(scaledImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(scaledRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(scaledMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should set scale property to screen scale", ^{
            expect(scaledImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledRightImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledMirroredImage.scale).to.equal([UIScreen mainScreen].scale);
        });
#if TARGET_IPHONE_SIMULATOR
        
        it(@"up scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledImage];
#ifdef IS_RECORDING
            expect(imageView).to.recordSnapshotNamed(@"TestScaledImage");
#endif
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledImage");
        });
        
        it(@"right scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledRightImage];
#ifdef IS_RECORDING
            expect(imageView).to.recordSnapshotNamed(@"TestScaledRightImage");
#endif
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledRightImage");
        });
        
        it(@"left mirrored scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledMirroredImage];
#ifdef IS_RECORDING
            expect(imageView).to.recordSnapshotNamed(@"TestScaledMirroredImage");
#endif
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledMirroredImage");
        });
#endif
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            scaledImage = nil;
            scaledRightImage = nil;
            scaledMirroredImage = nil;
        });
    });
    
    describe(@"Image Scale To Max Dimension", ^{
        __block UIImage *scaledImage;
        __block UIImage *scaledRightImage;
        __block UIImage *scaledMirroredImage;
        __block UIImage *scaledTallImage;
        
        beforeAll(^{
            // This is run before each example
            CGFloat maxDimension = 100.f;
            
            scaledImage = [image fastttScaledImageWithMaxDimension:maxDimension];
            scaledRightImage = [rightImage fastttScaledImageWithMaxDimension:maxDimension];
            scaledMirroredImage = [mirroredImage fastttScaledImageWithMaxDimension:maxDimension];
            scaledTallImage = [UIImage imageNamed:@"FastttCameraTestRight.png"];
            scaledTallImage = [scaledTallImage fastttScaledImageWithMaxDimension:maxDimension];

        });
        
        it(@"should not return nil", ^{
            expect(scaledImage).toNot.beNil;
            expect(scaledRightImage).toNot.beNil;
            expect(scaledMirroredImage).toNot.beNil;
            expect(scaledTallImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(scaledImage).to.beKindOf([UIImage class]);
            expect(scaledRightImage).to.beKindOf([UIImage class]);
            expect(scaledMirroredImage).to.beKindOf([UIImage class]);
            expect(scaledTallImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should scale to correct width", ^{
            expect(scaledImage.size.width).to.equal(100.f);
            expect(scaledRightImage.size.width).to.equal(100.f);
            expect(scaledMirroredImage.size.width).to.equal(100.f);
            expect(scaledTallImage.size.width).to.equal(80.f);
        });
        
        it(@"should scale to correct height", ^{
            expect(scaledImage.size.height).to.equal(80.f);
            expect(scaledRightImage.size.height).to.equal(80.f);
            expect(scaledMirroredImage.size.height).to.equal(80.f);
            expect(scaledTallImage.size.height).to.equal(100.f);
        });
        
        it(@"should not change image orientation", ^{
            expect(scaledImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(scaledRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(scaledMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
            expect(scaledTallImage.imageOrientation).to.equal(UIImageOrientationUp);
        });
        
        it(@"should set scale property to screen scale", ^{
            expect(scaledImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledRightImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledMirroredImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledTallImage.scale).to.equal([UIScreen mainScreen].scale);
        });
#if TARGET_IPHONE_SIMULATOR

        it(@"up scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledImage");
        });
        
        it(@"right scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledRightImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledRightImage");
        });
        
        it(@"left mirrored scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledMirroredImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledMirroredImage");
        });
#endif
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            scaledImage = nil;
            scaledRightImage = nil;
            scaledMirroredImage = nil;
            scaledTallImage = nil;
        });
    });
    
    describe(@"Image Scale To Scale", ^{
        __block UIImage *scaledImage;
        __block UIImage *scaledRightImage;
        __block UIImage *scaledMirroredImage;
        
        beforeAll(^{
            // This is run before each example
            CGFloat scale = 0.25f;
            
            scaledImage = [image fastttScaledImageWithScale:scale];
            scaledRightImage = [rightImage fastttScaledImageWithScale:scale];
            scaledMirroredImage = [mirroredImage fastttScaledImageWithScale:scale];
        });
        
        it(@"should not return nil", ^{
            expect(scaledImage).toNot.beNil;
            expect(scaledRightImage).toNot.beNil;
            expect(scaledMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(scaledImage).to.beKindOf([UIImage class]);
            expect(scaledRightImage).to.beKindOf([UIImage class]);
            expect(scaledMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should scale to correct width", ^{
            expect(scaledImage.size.width).to.equal(100.f);
            expect(scaledRightImage.size.width).to.equal(100.f);
            expect(scaledMirroredImage.size.width).to.equal(100.f);
        });
        
        it(@"should scale to correct height", ^{
            expect(scaledImage.size.height).to.equal(80.f);
            expect(scaledRightImage.size.height).to.equal(80.f);
            expect(scaledMirroredImage.size.height).to.equal(80.f);
        });
        
        it(@"should not change image orientation", ^{
            expect(scaledImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(scaledRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(scaledMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should set scale property to screen scale", ^{
            expect(scaledImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledRightImage.scale).to.equal([UIScreen mainScreen].scale);
            expect(scaledMirroredImage.scale).to.equal([UIScreen mainScreen].scale);
        });
#if TARGET_IPHONE_SIMULATOR
        
        it(@"up scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledImage");
        });
        
        it(@"right scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledRightImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledRightImage");
        });
        
        it(@"left mirrored scaled image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledMirroredImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestScaledMirroredImage");
        });
#endif
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            scaledImage = nil;
            scaledRightImage = nil;
            scaledMirroredImage = nil;
        });
    });
    
    describe(@"Image Normalize Orientation", ^{
        __block UIImage *normalizedImage;
        __block UIImage *normalizedRightImage;
        __block UIImage *normalizedMirroredImage;
        
        beforeAll(^{
            // This is run before each example
            normalizedImage = [image fastttImageWithNormalizedOrientation];
            normalizedRightImage = [rightImage fastttImageWithNormalizedOrientation];
            normalizedMirroredImage = [mirroredImage fastttImageWithNormalizedOrientation];
        });
        
        it(@"should not return nil", ^{
            expect(normalizedImage).toNot.beNil;
            expect(normalizedRightImage).toNot.beNil;
            expect(normalizedMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(normalizedImage).to.beKindOf([UIImage class]);
            expect(normalizedRightImage).to.beKindOf([UIImage class]);
            expect(normalizedMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should scale to correct width", ^{
            expect(normalizedImage.size.width).to.equal(400.f);
            expect(normalizedRightImage.size.width).to.equal(400.f);
            expect(normalizedMirroredImage.size.width).to.equal(400.f);
        });
        
        it(@"should scale to correct height", ^{
            expect(normalizedImage.size.height).to.equal(320.f);
            expect(normalizedRightImage.size.height).to.equal(320.f);
            expect(normalizedMirroredImage.size.height).to.equal(320.f);
        });
        
        it(@"should change image orientation to UIImageOrientationUp", ^{
            expect(normalizedImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(normalizedRightImage.imageOrientation).to.equal(UIImageOrientationUp);
            expect(normalizedMirroredImage.imageOrientation).to.equal(UIImageOrientationUp);
        });
        
        it(@"should not change image scale property", ^{
            expect(normalizedImage.scale).to.equal(image.scale);
            expect(normalizedRightImage.scale).to.equal(rightImage.scale);
            expect(normalizedMirroredImage.scale).to.equal(mirroredImage.scale);
        });
#if TARGET_IPHONE_SIMULATOR
        
        it(@"up normalized image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:normalizedImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
        
        it(@"right normalized image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:normalizedRightImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
        
        it(@"left mirrored normalized image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:normalizedMirroredImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
#endif
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            normalizedImage = nil;
            normalizedRightImage = nil;
            normalizedMirroredImage = nil;
        });
    });
    
    describe(@"Image Rotate to match camera view", ^{
        __block UIImage *rotatedImage;
        __block UIImage *rotatedRightImage;
        __block UIImage *rotatedMirroredImage;
        
        beforeAll(^{
            // This is run before each example
            rotatedImage = [image fastttRotatedImageMatchingCameraViewWithOrientation:UIDeviceOrientationPortrait];
            rotatedRightImage = [rightImage fastttRotatedImageMatchingCameraViewWithOrientation:UIDeviceOrientationPortrait];
            rotatedMirroredImage = [mirroredImage fastttRotatedImageMatchingCameraViewWithOrientation:UIDeviceOrientationPortrait];
        });
        
        it(@"should not return nil", ^{
            expect(rotatedImage).toNot.beNil;
            expect(rotatedRightImage).toNot.beNil;
            expect(rotatedMirroredImage).toNot.beNil;
        });
        
        it(@"should return an image", ^{
            expect(rotatedImage).to.beKindOf([UIImage class]);
            expect(rotatedRightImage).to.beKindOf([UIImage class]);
            expect(rotatedMirroredImage).to.beKindOf([UIImage class]);
        });
        
        it(@"should be correct width", ^{
            expect(rotatedImage.size.width).to.equal(320.f);
            expect(rotatedRightImage.size.width).to.equal(400.f);
            expect(rotatedMirroredImage.size.width).to.equal(400.f);
        });
        
        it(@"should be correct height", ^{
            expect(rotatedImage.size.height).to.equal(400.f);
            expect(rotatedRightImage.size.height).to.equal(320.f);
            expect(rotatedMirroredImage.size.height).to.equal(320.f);
        });
        
        it(@"should change image orientation to match camera preview", ^{
            expect(rotatedImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(rotatedRightImage.imageOrientation).to.equal(UIImageOrientationRight);
            expect(rotatedMirroredImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
        });
        
        it(@"should not change image scale property", ^{
            expect(rotatedImage.scale).to.equal(image.scale);
            expect(rotatedRightImage.scale).to.equal(rightImage.scale);
            expect(rotatedMirroredImage.scale).to.equal(mirroredImage.scale);
        });
#if TARGET_IPHONE_SIMULATOR
        
        it(@"up camera preview rotated image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:rotatedImage];
#ifdef IS_RECORDING
            expect(imageView).to.recordSnapshotNamed(@"TestImageRotatedUp");
#endif
            expect(imageView).to.haveValidSnapshotNamed(@"TestImageRotatedUp");
        });
        
        it(@"right camera preview rotated image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:rotatedRightImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
        
        it(@"left camera preview rotated normalized image matches image snapshot", ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:rotatedMirroredImage];
            expect(imageView).to.haveValidSnapshotNamed(@"TestImage");
        });
#endif
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            rotatedImage = nil;
            rotatedRightImage = nil;
            rotatedMirroredImage = nil;
        });
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
        image = nil;
        rightImage = nil;
        mirroredImage = nil;
    });
});

SpecEnd
