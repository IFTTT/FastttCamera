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
#import <FastttCapturedImage.h>

SpecBegin(FastttCapturedImage)

describe(@"FastttCapturedImage", ^{
    __block FastttCapturedImage *capturedImage;
    
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

SpecEnd
