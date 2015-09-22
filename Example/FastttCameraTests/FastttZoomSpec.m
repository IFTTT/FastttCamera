//
//  FastttZoomSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/5/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FastttZoom.h>

SpecBegin(FastttZoom)

describe(@"FastttZoom", ^{
    __block FastttZoom *fastZoom;
    __block UIView *view;
    __block id delegate;
    
    beforeAll(^{
        
        view = [UIView new];
        view.frame = CGRectMake(0.f, 0.f, 320.f, 480.f);
        fastZoom = [FastttZoom fastttZoomWithView:view gestureDelegate:nil];
        
        delegate = [OCMockObject mockForProtocol:@protocol(FastttZoomDelegate)];
        
        fastZoom.delegate = delegate;
    });
    
    describe(@"Setting detects pinch", ^{
        
        it(@"adds a gesture recognizer", ^{
            fastZoom.detectsPinch = YES;
            BOOL hasRecognizer = NO;
            for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    hasRecognizer = YES;
                    break;
                }
            }
            expect(hasRecognizer).to.beTruthy();
        });
        
        it(@"removes gesture recognizer", ^{
            fastZoom.detectsPinch = NO;
            BOOL hasRecognizer = NO;
            for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    hasRecognizer = YES;
                    break;
                }
            }
            expect(hasRecognizer).to.beFalsy();
        });
    });
    
    afterAll(^{
        fastZoom = nil;
        delegate = nil;
    });
});

SpecEnd
