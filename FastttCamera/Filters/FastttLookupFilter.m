//
//  FastttLookupFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/25/15.
//
//

#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageLookupFilter.h>
#import "FastttLookupFilter.h"

@interface FastttLookupFilter ()

@property (nonatomic, strong) GPUImagePicture *lookupImageSource;

@end

@implementation FastttLookupFilter

- (instancetype)initWithLookupImage:(UIImage *)lookupImage
{
    if ((self = [super init])) {
        _lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupImage];
        GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        
        [_lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [_lookupImageSource processImage];
        
        self.initialFilters = @[lookupFilter];
        self.terminalFilter = lookupFilter;
    }
    
    return self;
}

@end
