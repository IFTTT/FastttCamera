//
//  FastttCapturedImage.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//
//

#import "FastttCapturedImage.h"

@implementation FastttCapturedImage

- (instancetype) initWithFullImage:(UIImage *)fullImage
{
    if ((self = [super init])) {
        _fullImage = fullImage;
    }
    
    return self;
}

+ (instancetype) fastttCapturedFullImage:(UIImage *)fullImage
{
    return [[FastttCapturedImage alloc] initWithFullImage:fullImage];
}

@end
