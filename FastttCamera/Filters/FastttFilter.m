//
//  FastttFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttFilter.h"
#import <GPUImage/GPUImageFilterGroup.h>
#import "FastttLookupFilter.h"
#import "FastttEmptyFilter.h"

@interface FastttFilter ()

@property (readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@end

@implementation FastttFilter

+ (instancetype)filterWithLookupImage:(UIImage *)lookupImage
{
    FastttFilter *fastFilter = [[self alloc] init];
    
    if (lookupImage) {
        FastttLookupFilter *lookupFilter = [[FastttLookupFilter alloc] initWithLookupImage:lookupImage];
        fastFilter.filter = lookupFilter;
    } else {
        FastttEmptyFilter *emptyFilter = [[FastttEmptyFilter alloc] init];
        fastFilter.filter = emptyFilter;
    }
    
    return fastFilter;
}

+ (instancetype)plainFilter
{
    FastttFilter *fastFilter = [[self alloc] init];
    
    FastttEmptyFilter *emptyFilter = [[FastttEmptyFilter alloc] init];
    
    fastFilter.filter = emptyFilter;
    
    return fastFilter;
}

@end
