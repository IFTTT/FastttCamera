//
//  FastttEmptyFilter.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <GPUImage/GPUImageFilter.h>

/**
 *  Private class to create an empty filter, necessary for GPUImage
 *  to capture an unfiltered photo when using FastttFilterCamera.
 */
@interface FastttEmptyFilter : GPUImageFilter

@end
