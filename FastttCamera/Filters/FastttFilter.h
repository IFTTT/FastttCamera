//
//  FastttFilter.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImageOutput.h>

/**
 *  Private class that contains either a lookup filter or an empty filter,
 *  used internally to filter the live camera preview in FastttFilterCamera.
 */
@interface FastttFilter : NSObject

@property (readonly, nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

+ (instancetype)filterWithLookupImage:(UIImage *)lookupImage;

+ (instancetype)plainFilter;

@end
