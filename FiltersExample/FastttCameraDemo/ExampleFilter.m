//
//  ExampleFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/4/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "ExampleFilter.h"

@implementation ExampleFilter

+ (instancetype)filterWithType:(FastttFilterType)filterType
{
    ExampleFilter *imageFilter = [[self alloc] init];
    
    imageFilter.filterType = filterType;
    imageFilter.filterImage = [self imageForFilterType:filterType];
    imageFilter.filterName = [self nameForFilterType:filterType];
    
    return imageFilter;
}

- (instancetype)nextFilter
{
    return [ExampleFilter filterWithType:[self nextFilterType]];
}

- (FastttFilterType)nextFilterType
{
    FastttFilterType filterType;
    
    switch (self.filterType) {
        case FastttCameraFilterNone:
            filterType = FastttCameraFilterRetro;
            break;
        case FastttCameraFilterRetro:
            filterType = FastttCameraFilterHighContrast;
            break;
        case FastttCameraFilterHighContrast:
            filterType = FastttCameraFilterSepia;
            break;
        case FastttCameraFilterSepia:
            filterType = FastttCameraFilterBW;
            break;
        case FastttCameraFilterBW:
        default:
            filterType = FastttCameraFilterNone;
            break;
    }
    
    return filterType;
}

+ (UIImage *)imageForFilterType:(FastttFilterType)filterType
{
    NSString *lookupImageName;

    switch (filterType) {
        case FastttCameraFilterRetro:
            lookupImageName = @"RetroFilter";
            break;
        case FastttCameraFilterHighContrast:
            lookupImageName = @"HighContrastFilter";
            break;
        case FastttCameraFilterSepia:
            lookupImageName = @"SepiaFilter";
            break;
        case FastttCameraFilterBW:
            lookupImageName = @"BWFilter";
            break;
        case FastttCameraFilterNone:
        default:
            break;
    }
    
    UIImage *filterImage;
    
    if ([lookupImageName length] > 0) {
        filterImage = [UIImage imageNamed:lookupImageName];
    }
    
    return filterImage;
}

+ (NSString *)nameForFilterType:(FastttFilterType)filterType
{
    NSString *filterName;
    
    switch (filterType) {
        case FastttCameraFilterRetro:
            filterName = @"Retro";
            break;
        case FastttCameraFilterHighContrast:
            filterName = @"High Contrast";
            break;
        case FastttCameraFilterSepia:
            filterName = @"Sepia";
            break;
        case FastttCameraFilterBW:
            filterName = @"Black + White";
            break;
        case FastttCameraFilterNone:
        default:
            filterName = @"None";
            break;
    }
    
    return filterName;
}

@end
