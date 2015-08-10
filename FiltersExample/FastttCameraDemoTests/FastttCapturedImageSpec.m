//
//  FastttCapturedImageSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/23/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <FastttCamera/FastttCapturedImage.h>
#import <FastttCamera/FastttCapturedImage+Process.h>

SpecBegin(FastttCapturedImage)

describe(@"FastttCapturedImage", ^{
    __block FastttCapturedImage *capturedImage;
    __block FastttCapturedImage *mirroredCapturedImage;
    
    describe(@"Create captured image", ^{

        beforeAll(^{
            // This is run once and only once before all of the examples
            // in this group and before any beforeEach blocks.
            UIImage *image = [UIImage imageNamed:@"FastttCameraTest.png"];
            capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
        });
        
        it(@"can be created", ^{
            expect(capturedImage).toNot.beNil();
        });
        
        it(@"has a full image when created", ^{
            expect(capturedImage.fullImage).toNot.beNil();
            expect(capturedImage.fullImage).to.beKindOf([UIImage class]);
        });
        
        it(@"has correctly sized full image when created", ^{
            expect(capturedImage.fullImage.size.width).to.equal(400.f);
            expect(capturedImage.fullImage.size.height).to.equal(320.f);
        });
        
        it(@"is created with nil user info property", ^{
            expect(capturedImage.userInfo).to.beNil();
        });
        
        it(@"is created with nil scaled image property", ^{
            expect(capturedImage.scaledImage).to.beNil();
        });
        
        it(@"is created with nil rotated preview image property", ^{
            expect(capturedImage.rotatedPreviewImage).to.beNil();
        });
        
        it(@"is created with isNormalized set to NO", ^{
            expect(capturedImage.isNormalized).to.beFalsy();
        });
        
        afterAll(^{
            // This is run once and only once after all of the examples
            // in this group and after any afterEach blocks.
            capturedImage = nil;
        });
    });
    
    describe(@"Process captured image", ^{
        
        describe(@"Crop and Preview image", ^{

            beforeEach(^{
                UIImage *image = [UIImage imageNamed:@"FastttCameraTest.png"];
                capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
                
                UIImage *mirroredImage = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
                mirroredImage = [UIImage imageWithCGImage:mirroredImage.CGImage
                                                    scale:mirroredImage.scale
                                              orientation:UIImageOrientationLeftMirrored];
                mirroredCapturedImage = [FastttCapturedImage fastttCapturedFullImage:mirroredImage];
            });
            
            it(@"should return a non-nil full image even if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil full image even if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil full image even if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil full image even if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return uncropped full image if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(400.f);
                        expect(capturedImage.fullImage.size.height).to.equal(320.f);
                        done();
                    }];
                });
            });
            
            it(@"should return uncropped full image if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(400.f);
                        expect(capturedImage.fullImage.size.height).to.equal(320.f);
                        done();
                    }];
                });
            });
            
            it(@"should return uncropped full image if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(400.f);
                        expect(capturedImage.fullImage.size.height).to.equal(320.f);
                        done();
                    }];
                });
            });
            
            it(@"should return uncropped full image if cropping to CGRectNull", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(400.f);
                        expect(capturedImage.fullImage.size.height).to.equal(320.f);
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil cropped image", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil cropped image", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil cropped image", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil cropped image", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should crop image correctly", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(80.f);
                        expect(capturedImage.fullImage.size.height).to.equal(120.f);
                        done();
                    }];
                });
            });
            
            it(@"should crop image correctly", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(80.f);
                        expect(capturedImage.fullImage.size.height).to.equal(120.f);
                        done();
                    }];
                });
            });
            
            it(@"should crop image correctly", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(80.f);
                        expect(capturedImage.fullImage.size.height).to.equal(120.f);
                        done();
                    }];
                });
            });
            
            it(@"should crop image correctly", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.size.width).to.equal(80.f);
                        expect(capturedImage.fullImage.size.height).to.equal(120.f);
                        done();
                    }];
                });
            });
            
            it(@"should not return a preview image if returnsPreview is NO", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).to.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should not return a preview image if returnsPreview is NO", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).to.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should not return a preview image if returnsPreview is NO", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).to.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should not return a preview image if returnsPreview is NO", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:NO needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).to.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a preview image if returnsPreview is YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a preview image if returnsPreview is YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a preview image if returnsPreview is YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a preview image if returnsPreview is YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a UIImageOrientationLeftMirrored preview image if needsPreviewRotation is YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [mirroredCapturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
                        done();
                    }];
                });
            });
            
            it(@"should return a UIImageOrientationLeftMirrored preview image if needsPreviewRotation is YES", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
                        done();
                    }];
                });
            });
            
            it(@"should return a UIImageOrientationRight preview image if needsPreviewRotation is YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationRight);
                        done();
                    }];
                });
            });
            
            it(@"should return a UIImageOrientationRight preview image if needsPreviewRotation is YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:YES withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationRight);
                        done();
                    }];
                });
            });
            
            it(@"should not change orientation of preview image if needsPreviewRotation is NO", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [mirroredCapturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
                        done();
                    }];
                });
            });
            
            it(@"should not change orientation of preview image if needsPreviewRotation is NO", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationLeftMirrored);
                        done();
                    }];
                });
            });
            
            it(@"should not change orientation of preview image if needsPreviewRotation is NO", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should not change orientation of preview image if needsPreviewRotation is NO", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage cropToRect:CGRectNull returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.rotatedPreviewImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [capturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    CGRect cropRect = CGRectMake(10.f, 20.f, 80.f, 120.f);
                    [mirroredCapturedImage cropToRect:cropRect returnsPreview:YES needsPreviewRotation:NO withPreviewOrientation:UIDeviceOrientationPortrait withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            afterEach(^{
                capturedImage = nil;
                mirroredCapturedImage = nil;
            });
        });
        
        describe(@"Scale image to max dimension", ^{
            
            beforeEach(^{
                UIImage *image = [UIImage imageNamed:@"FastttCameraTest.png"];
                capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
                
                UIImage *mirroredImage = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
                mirroredImage = [UIImage imageWithCGImage:mirroredImage.CGImage
                                                    scale:mirroredImage.scale
                                              orientation:UIImageOrientationLeftMirrored];
                mirroredCapturedImage = [FastttCapturedImage fastttCapturedFullImage:mirroredImage];
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should still return a non-nil full image after scaling", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should still return a non-nil full image after scaling", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a correctly sized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage.size.width).to.equal(80.f);
                        expect(capturedImage.scaledImage.size.width).to.beLessThanOrEqualTo(80.f);
                        expect(capturedImage.scaledImage.size.height).to.beLessThanOrEqualTo(80.f);
                        done();
                    }];
                });
            });
            
            it(@"should return a correctly sized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage.size.width).to.equal(80.f);
                        expect(mirroredCapturedImage.scaledImage.size.width).to.beLessThanOrEqualTo(80.f);
                        expect(mirroredCapturedImage.scaledImage.size.height).to.beLessThanOrEqualTo(80.f);
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToMaxDimension:80.f withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            afterEach(^{
                capturedImage = nil;
                mirroredCapturedImage = nil;
            });
        });
        
        describe(@"Scale image to size", ^{
            
            beforeEach(^{
                UIImage *image = [UIImage imageNamed:@"FastttCameraTest.png"];
                capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
                
                UIImage *mirroredImage = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
                mirroredImage = [UIImage imageWithCGImage:mirroredImage.CGImage
                                                    scale:mirroredImage.scale
                                              orientation:UIImageOrientationLeftMirrored];
                mirroredCapturedImage = [FastttCapturedImage fastttCapturedFullImage:mirroredImage];
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should still return a non-nil full image after scaling", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should still return a non-nil full image after scaling", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a correctly sized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage.size.width).to.equal(100.f);
                        expect(capturedImage.scaledImage.size.height).to.equal(80.f);
                        done();
                    }];
                });
            });
            
            it(@"should return a correctly sized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage.size.width).to.equal(100.f);
                        expect(mirroredCapturedImage.scaledImage.size.height).to.equal(80.f);
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            it(@"should not set isNormalized to YES", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage scaleToSize:CGSizeMake(100.f, 80.f) withCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.isNormalized).to.beFalsy();
                        done();
                    }];
                });
            });
            
            afterEach(^{
                capturedImage = nil;
                mirroredCapturedImage = nil;
            });
        });
        
        describe(@"Normalize image", ^{
            
            beforeEach(^{
                UIImage *image = [UIImage imageNamed:@"FastttCameraTest.png"];
                capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
                capturedImage.scaledImage = image;
                
                UIImage *mirroredImage = [UIImage imageNamed:@"FastttCameraTestLeftMirrored.png"];
                mirroredImage = [UIImage imageWithCGImage:mirroredImage.CGImage
                                                    scale:mirroredImage.scale
                                              orientation:UIImageOrientationLeftMirrored];
                mirroredCapturedImage = [FastttCapturedImage fastttCapturedFullImage:mirroredImage];
                mirroredCapturedImage.scaledImage = mirroredImage;
            });
            
            it(@"should return a non-nil full image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil full image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.fullImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a non-nil scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage).toNot.beNil();
                        done();
                    }];
                });
            });
            
            it(@"should return a normalized full image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.fullImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should return a normalized full image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.fullImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should return a normalized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.scaledImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should return a normalized scaled image", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.scaledImage.imageOrientation).to.equal(UIImageOrientationUp);
                        done();
                    }];
                });
            });
            
            it(@"should return isNormalized = YES", ^{
                waitUntil(^(DoneCallback done) {
                    [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(capturedImage.isNormalized).to.beTruthy();
                        done();
                    }];
                });
            });
            
            it(@"should return isNormalized = YES", ^{
                waitUntil(^(DoneCallback done) {
                    [mirroredCapturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                        expect(mirroredCapturedImage.isNormalized).to.beTruthy();
                        done();
                    }];
                });
            });
            
            afterEach(^{
                capturedImage = nil;
                mirroredCapturedImage = nil;
            });
        });
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
        capturedImage = nil;
    });
});

SpecEnd
