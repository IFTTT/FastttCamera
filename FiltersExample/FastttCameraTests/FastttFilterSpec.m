//
//  FastttFilterSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/3/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <FastttCamera/FastttFilter.h>
#import <FastttCamera/FastttLookupFilter.h>
#import <FastttCamera/FastttEmptyFilter.h>

SpecBegin(FastttFilter)

describe(@"FastttFilter", ^{
    __block FastttFilter *fastFilter;
    
    describe(@"create with lookup image", ^{
        beforeAll(^{
            fastFilter = [FastttFilter filterWithLookupImage:[UIImage imageNamed:@"RetroFilter"]];
        });

        it(@"can be created", ^{
            expect(fastFilter).toNot.beNil();
        });
        
        it(@"has a filter", ^{
            expect(fastFilter.filter).toNot.beNil();
        });
        
        it(@"has a lookup filter", ^{
            expect(fastFilter.filter).to.beKindOf([FastttLookupFilter class]);
        });
        
        afterAll(^{
            fastFilter = nil;
        });
    });
    
    describe(@"create with nil lookup image", ^{
        beforeAll(^{
            fastFilter = [FastttFilter filterWithLookupImage:nil];
        });
        
        it(@"can be created", ^{
            expect(fastFilter).toNot.beNil();
        });
        
        it(@"has a filter", ^{
            expect(fastFilter.filter).toNot.beNil();
        });
        
        it(@"has an empty filter", ^{
            expect(fastFilter.filter).to.beKindOf([FastttEmptyFilter class]);
        });
        
        afterAll(^{
            fastFilter = nil;
        });
    });
    
    describe(@"create with plain filter", ^{
        beforeAll(^{
            fastFilter = [FastttFilter plainFilter];
        });
        
        it(@"can be created", ^{
            expect(fastFilter).toNot.beNil();
        });
        
        it(@"has a filter", ^{
            expect(fastFilter.filter).toNot.beNil();
        });
        
        it(@"has an empty filter", ^{
            expect(fastFilter.filter).to.beKindOf([FastttEmptyFilter class]);
        });
        
        afterAll(^{
            fastFilter = nil;
        });
    });
});

SpecEnd
