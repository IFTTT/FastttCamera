//
//  FastttCameraPerformance.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/23/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import UIKit;
@import XCTest;
#import <FastttCamera/UIImage+FastttCamera.h>

@interface FastttCameraPerformance : XCTestCase

@property (nonatomic, strong) UIImage *image;

@end

@implementation FastttCameraPerformance

- (void)setUp {
    [super setUp];
    // Called before the invocation of each test method in the class.
    self.image = [UIImage imageNamed:@"LargeTestPhoto.jpg"];
    self.image = [UIImage imageWithCGImage:self.image.CGImage
                                     scale:self.image.scale
                               orientation:UIImageOrientationLeftMirrored];
}

- (void)tearDown {
    // Called after the invocation of each test method in the class.
    [super tearDown];
    self.image = nil;
}

- (void)testCropPerformance {
    [self measureBlock:^{
        CGRect outputRect = CGRectMake(0.1f, 0.05f, 0.8f, 0.9f);
        for (NSInteger i=0; i<10000; i++) {
            __unused UIImage *croppedImage = [self.image fastttCroppedImageFromOutputRect:outputRect];
        }
    }];
}

- (void)testRotatedPreviewPerformance {
    [self measureBlock:^{
        for (NSInteger i=0; i<100000; i++) {
            __unused UIImage *rotatedImage = [self.image fastttRotatedImageMatchingCameraViewWithOrientation:UIDeviceOrientationPortrait];
        }
    }];
}

- (void)testScaleToSizePerformance {
    [self measureBlock:^{
        __unused UIImage *scaledImage = [self.image fastttScaledImageOfSize:CGSizeMake(600.f, 500.f)];
    }];
}

- (void)testScaleToMaxDimensionPerformance {
    [self measureBlock:^{
        __unused UIImage *scaledImage = [self.image fastttScaledImageWithMaxDimension:600.f];
    }];
}

- (void)testScaleToScalePerformance {
    [self measureBlock:^{
        __unused UIImage *scaledImage = [self.image fastttScaledImageWithScale:0.3f];
    }];
}

- (void)testNormalizePerformance {
    [self measureBlock:^{
        __unused UIImage *normalizedImage = [self.image fastttImageWithNormalizedOrientation];
    }];
}

@end
