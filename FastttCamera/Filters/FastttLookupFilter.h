//
//  FastttLookupFilter.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/25/15.
//
//

#import <GPUImage/GPUImageFilterGroup.h>

/**
 *  Private class to create a GPUImage lookup filter from a UIImage.
 */
@interface FastttLookupFilter : GPUImageFilterGroup

- (instancetype)initWithLookupImage:(UIImage *)lookupImage;

@end
