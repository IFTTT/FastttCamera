//
//  IFTTTDeviceOrientationSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/20/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <FastttCamera/IFTTTDeviceOrientation.h>

SpecBegin(IFTTTDeviceOrientation)

describe(@"IFTTTDeviceOrientation", ^{
    __block IFTTTDeviceOrientation *deviceOrientation;
    
    beforeAll(^{
        // This is run once and only once before all of the examples
        // in this group and before any beforeEach blocks.
        deviceOrientation = [IFTTTDeviceOrientation new];
    });
    
    it(@"can be created", ^{
        expect(deviceOrientation).toNot.beNil();
    });
    
    it(@"has an orientation", ^{
        expect(deviceOrientation.orientation).to.equal(UIDeviceOrientationPortrait);
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
        deviceOrientation = nil;
    });
    
});

SpecEnd
