//
//  FastttFocusSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/3/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FastttCamera/FastttFocus.h>

SpecBegin(FastttFocus)

describe(@"FastttFocus", ^{
    __block FastttFocus *fastFocus;
    __block UIView *view;
    __block id delegate;
    
    beforeAll(^{
        
        view = [UIView new];
        view.frame = CGRectMake(0.f, 0.f, 320.f, 480.f);
        fastFocus = [FastttFocus fastttFocusWithView:view gestureDelegate:nil];
        
        delegate = [OCMockObject mockForProtocol:@protocol(FastttFocusDelegate)];
        
        fastFocus.delegate = delegate;
    });
    
    describe(@"Setting detects tap", ^{
        
        it(@"adds a gesture recognizer", ^{
            fastFocus.detectsTaps = YES;
            BOOL hasRecognizer = NO;
            for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                    hasRecognizer = YES;
                    break;
                }
            }
            expect(hasRecognizer).to.beTruthy();
        });
        
        it(@"removes gesture recognizer", ^{
            fastFocus.detectsTaps = NO;
            BOOL hasRecognizer = NO;
            for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                    hasRecognizer = YES;
                    break;
                }
            }
            expect(hasRecognizer).to.beFalsy();
        });
    });
    
    describe(@"Showing focus view", ^{
        
        it(@"shows a focus view", ^{
            fastFocus.detectsTaps = YES;
            [fastFocus showFocusViewAtPoint:CGPointMake(20.f, 30.f)];
            expect([view.subviews count]).to.beGreaterThan(0);
        });
    });
    
    afterAll(^{
        fastFocus = nil;
        delegate = nil;
    });
});

SpecEnd
