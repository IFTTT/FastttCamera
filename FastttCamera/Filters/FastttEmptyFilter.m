//
//  FastttEmptyFilter.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttEmptyFilter.h"

@implementation FastttEmptyFilter

NSString *const kGPUImageEmptyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageEmptyFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
