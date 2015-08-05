//
//  UIImage+FastttFilters.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/3/15.
//
//

#import <GPUImage/GPUImage.h>
#import "FastttFilter.h"
#import "UIImage+FastttFilters.h"

@implementation UIImage (FastttFilters)

- (UIImage *)fastttFilteredImageWithFilter:(UIImage *)filterImage
{
    FastttFilter *fastFilter = [FastttFilter filterWithLookupImage:filterImage];
    return [fastFilter.filter imageByFilteringImage:self];
}

@end
