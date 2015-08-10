//
//  ExampleFilter.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/4/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, FastttFilterType) {
    FastttCameraFilterNone,
    FastttCameraFilterRetro,
    FastttCameraFilterHighContrast,
    FastttCameraFilterBW,
    FastttCameraFilterSepia
};

@interface ExampleFilter : NSObject

@property (nonatomic, assign) FastttFilterType filterType;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) UIImage *filterImage;

+ (instancetype)filterWithType:(FastttFilterType)filterType;

- (instancetype)nextFilter;

- (FastttFilterType)nextFilterType;

+ (UIImage *)imageForFilterType:(FastttFilterType)filterType;

+ (NSString *)nameForFilterType:(FastttFilterType)filterType;

@end
