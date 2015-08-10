//
//  UIImagePickerBenchmark.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "UIImagePickerBenchmark.h"
#import <Masonry/Masonry.h>
@import AVFoundation;
@import Accelerate;

NSInteger const kIFTTTImagePickerBenchmarkTestIterations = 20;

@interface UIImagePickerBenchmark () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerCamera;
@property (nonatomic, strong) UIButton *runTestButton;
@property (nonatomic, strong) UILabel *averageTimeLabel;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval totalTakePhotoTime;
@property (nonatomic, assign) NSTimeInterval totalCropPhotoTime;
@property (nonatomic, assign) NSTimeInterval totalScalePhotoTime;
@property (nonatomic, assign) NSTimeInterval totalTimeToRender;
@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation UIImagePickerBenchmark

- (instancetype)init
{
    if ((self = [super init])) {
        
        self.title = @"ImagePicker Test";
        self.tabBarItem.image = [UIImage imageNamed:@"BarChart"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imagePickerCamera = [UIImagePickerController new];
    self.imagePickerCamera.delegate = self;
    self.imagePickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerCamera.showsCameraControls = NO;
    self.imagePickerCamera.allowsEditing = NO;
    self.imagePickerCamera.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.imagePickerCamera.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    self.imagePickerCamera.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    [self.imagePickerCamera willMoveToParentViewController:self];
    [self.imagePickerCamera beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:self.imagePickerCamera];
    [self.view addSubview:self.imagePickerCamera.view];
    [self.imagePickerCamera didMoveToParentViewController:self];
    [self.imagePickerCamera endAppearanceTransition];
    
    [self.imagePickerCamera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CGFloat previewHeight = screenBounds.width * 4.f / 3.f;;
    CGFloat previewScale = screenBounds.height / previewHeight;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,
                                                                   (CGRectGetHeight([UIScreen mainScreen].bounds) - previewScale) / 2.0f);
    transform = CGAffineTransformScale(transform, previewScale, previewScale);
    self.imagePickerCamera.cameraViewTransform = transform;
    
    _previewImageView = [UIImageView new];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.previewImageView];
    
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _runTestButton = [UIButton new];
    [self.runTestButton addTarget:self
                           action:@selector(runBenchmarkTest)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.runTestButton setTitle:@"Run Test"
                        forState:UIControlStateNormal];
    
    [self.view addSubview:self.runTestButton];
    [self.runTestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
    }];
    
    _averageTimeLabel = [UILabel new];
    self.averageTimeLabel.textColor = [UIColor whiteColor];
    self.averageTimeLabel.text = @"Average Time: ";
    
    [self.view addSubview:self.averageTimeLabel];
    [self.averageTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
    }];
}

- (void)runBenchmarkTest
{
    NSLog(@"Will run test");
    self.averageTimeLabel.text = @"Running...";
    self.counter = 0;
    self.totalTakePhotoTime = 0.f;
    self.totalCropPhotoTime = 0.f;
    self.totalScalePhotoTime = 0.f;
    self.totalTimeToRender = 0.f;
    [self startBenchmarkTestIteration];
}

- (void)startBenchmarkTestIteration
{
    [NSThread sleepForTimeInterval:0.1f];
    
    self.counter += 1;
    self.startTime = CACurrentMediaTime();
    [self.imagePickerCamera takePicture];
}

- (void)takePhotoBenchmarkTestIteration
{
    self.totalTakePhotoTime += CACurrentMediaTime() - self.startTime;
}

- (void)cropPhotoBenchmarkTestIteration
{
    self.totalCropPhotoTime += CACurrentMediaTime() - self.startTime;
}

- (void)scalePhotoBenchmarkTestIteration
{
    self.totalScalePhotoTime += CACurrentMediaTime() - self.startTime;
}

- (void)renderPhotoBenchmarkTestIteration
{
    self.totalTimeToRender += CACurrentMediaTime() - self.startTime;
}

- (void)endBenchmarkTestIteration
{
    NSLog(@"run %@", @(self.counter));
    if (self.counter < kIFTTTImagePickerBenchmarkTestIterations) {
        [self startBenchmarkTestIteration];
    } else {
        [self finishBenchmarkTest];
    }
}

- (void)finishBenchmarkTest
{
    CGFloat averageTakePhotoTime = (CGFloat)(self.totalTakePhotoTime / kIFTTTImagePickerBenchmarkTestIterations);
    NSLog(@"Average Run Time for UIImagePickerController Take Photo: %@", @(averageTakePhotoTime));
    
    CGFloat averageRenderPhotoTime = (CGFloat)(self.totalTimeToRender / kIFTTTImagePickerBenchmarkTestIterations);
    NSLog(@"Average Run Time for UIImagePickerController Render Photo: %@", @(averageRenderPhotoTime));
    
    CGFloat averageCropPhotoTime = (CGFloat)(self.totalCropPhotoTime / kIFTTTImagePickerBenchmarkTestIterations);
    NSLog(@"Average Run Time for UIImagePickerController Crop Photo: %@", @(averageCropPhotoTime));
    
    CGFloat averageScalePhotoTime = (CGFloat)(self.totalScalePhotoTime / kIFTTTImagePickerBenchmarkTestIterations);
    NSLog(@"Average Run Time for UIImagePickerController Scale Photo: %@", @(averageScalePhotoTime));
    
    self.averageTimeLabel.text = [NSString stringWithFormat: @"Average Time: %@", @(averageScalePhotoTime)];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self takePhotoBenchmarkTestIteration];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    UIImage *previewImage;
    
    previewImage = [UIImage imageWithCGImage:image.CGImage
                                       scale:image.scale
                                 orientation:UIImageOrientationRight];
    
    self.previewImageView.image = previewImage;
    
    // forces the image view to render now so we can see the delay
    [self.previewImageView setNeedsDisplay];
    [CATransaction flush];

    [self renderPhotoBenchmarkTestIteration];
    
    previewImage = nil;

    UIImage *croppedImage = [self iftttImageByCroppingImage:image];

    croppedImage = [UIImage imageWithCGImage:croppedImage.CGImage
                                      scale:croppedImage.scale
                                orientation:UIImageOrientationUpMirrored];

    [self cropPhotoBenchmarkTestIteration];

    __unused UIImage *scaledImage;

    // Scale image to screen size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    if (croppedImage.size.width > croppedImage.size.height && screenSize.width < screenSize.height) {
       // screensize is in portrait while image is landscape, so flip the aspect ratio
       screenSize = CGSizeMake(screenSize.height, screenSize.width);
    }

    scaledImage = [self scaleImage:croppedImage toFillSize:CGSizeMake(screenSize.width * [UIScreen mainScreen].scale,
                                                                     screenSize.height * [UIScreen mainScreen].scale)];

    [self scalePhotoBenchmarkTestIteration];

    [self endBenchmarkTestIteration];

}

- (UIImage*)scaleImage:(UIImage *)image toFillSize:(CGSize)newSize
{
    size_t destWidth = (size_t)(newSize.width * image.scale);
    size_t destHeight = (size_t)(newSize.height * image.scale);
    if (image.imageOrientation == UIImageOrientationLeft
        || image.imageOrientation == UIImageOrientationLeftMirrored
        || image.imageOrientation == UIImageOrientationRight
        || image.imageOrientation == UIImageOrientationRightMirrored)
    {
        size_t temp = destWidth;
        destWidth = destHeight;
        destHeight = temp;
    }
    
    /// Create an ARGB bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, destWidth, destHeight, 8, destWidth * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipFirst);
    
    if (!bmContext) {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Draw the image in the bitmap context
    
    UIGraphicsPushContext(bmContext);
    CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, destWidth, destHeight), image.CGImage);
    UIGraphicsPopContext();
    
    /// Create an image object from the context
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef scale:image.scale orientation:image.imageOrientation];
    
    /// Cleanup
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(scaledImageRef);
    CGContextRelease(bmContext);
    
    return scaled;
}

CG_INLINE CGFLOAT_TYPE iftttDegreesFromImageOrientation(UIImageOrientation orientation)
{
    // the iPhone treats "Up" as the up if the phone were landscape left
    // So, the right side of the screen is "up" when a photo is taken
    // Here, we correct that to the actual direction that should be "up"
    switch (orientation) {
        case UIImageOrientationUp: // image captured in landscape left
            return 0.f;
        case UIImageOrientationDown: // image captured in landscape right
            return 180.f;
        case UIImageOrientationLeft: // image captured in portrait upside down
            return -90.f;
        case UIImageOrientationRight: // image captured in portrait
            return 90.f;
        default:
            return 0.f;
    }
}

- (UIImage *)iftttImageByCroppingImage:(UIImage *)image
{
    UIImage *rotatedImage = [self rotateImage:image inDegrees:-(float)iftttDegreesFromImageOrientation(image.imageOrientation)];
    
    UIImage *fixedImage = [UIImage imageWithCGImage:rotatedImage.CGImage
                                              scale:rotatedImage.scale
                                        orientation:UIImageOrientationUp];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (fixedImage.size.width > fixedImage.size.height && screenSize.width < screenSize.height) {
        // screensize is in portrait while image is landscape, so flip the aspect ratio
        screenSize = CGSizeMake(screenSize.height, screenSize.width);
    }
    
    CGRect cropRect = CGRectIntegral(AVMakeRectWithAspectRatioInsideRect(screenSize,
                                                                         CGRectMake(0,
                                                                                    0,
                                                                                    fixedImage.size.width,
                                                                                    fixedImage.size.height)));
    
    fixedImage = nil;
    
    // Crop the captured image to an aspect ratio matching the physical screen size
    
    UIImage *croppedImage = [self iftttImage:rotatedImage byCroppingToRect:cropRect];
    
    rotatedImage = nil;
    
    return croppedImage;
}

- (UIImage *)iftttImage:(UIImage *)image byCroppingToRect:(CGRect)rect
{
    CGFloat scale = image.scale;
    CGRect cropRect = CGRectMake(rect.origin.x * scale,
                                 rect.origin.y * scale,
                                 rect.size.width * scale,
                                 rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

- (UIImage*)rotateImage:(UIImage *)image inDegrees:(float)degrees
{
    return [self rotateImage:image pixelsInRadians:(float)(degrees * 0.017453293)];
}

- (UIImage*)rotateImage:(UIImage *)image pixelsInRadians:(float)radians
{
    /// Create an ARGB bitmap context
    const size_t width = (size_t)(image.size.width * image.scale);
    const size_t height = (size_t)(image.size.height * image.scale);
    const size_t bytesPerRow = width * 4;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorspace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, width, height), image.CGImage);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
    
    if (!data) {
        CGColorSpaceRelease(colorspace);
        CGContextRelease(bmContext);
        return nil;
    }
    
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {data, height, width, bytesPerRow};
    Pixel_8888 bgColor = {0, 0, 0, 0};
    vImageRotate_ARGB8888(&src, &dest, NULL, radians, bgColor, kvImageBackgroundColorFill);
    
    CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef scale:image.scale orientation:image.imageOrientation];
    
    /// Cleanup
    CGColorSpaceRelease(colorspace);
    CGImageRelease(rotatedImageRef);
    CGContextRelease(bmContext);
    
    return rotated;
}

@end
