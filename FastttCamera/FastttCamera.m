//
//  FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/5/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import AVFoundation;

#import "FastttCamera.h"
#import "IFTTTDeviceOrientation.h"
#import "UIImage+FastttCamera.h"

CGFloat const kFocusSquareSize = 50.f;

@interface FastttCamera ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) IFTTTDeviceOrientation *deviceOrientation;
@property (nonatomic, assign) BOOL isFocusing;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation FastttCamera

- (instancetype)init
{
    if ((self = [super init])) {
        
        [self _setupCaptureSession];
        
        _handlesTapFocus = YES;
        _showsFocusView = YES;
        _cropsImageToVisibleAspectRatio = YES;
        _scalesImage = YES;
        _maxScaledDimension = 0.f;
        _normalizesImageOrientations = YES;
        _returnsRotatedPreview = YES;
        _interfaceRotatesWithOrientation = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [self _teardownCaptureSession];
    
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - View Events

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _insertPreviewLayerInView:self.view];
    
    if (self.handlesTapFocus) {
        [self _setupTapFocusRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _startRunning];
    
    [self _setPreviewVideoOrientation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self _stopRunning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _previewLayer.frame = self.view.layer.bounds;
}

#pragma mark - Autorotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setPreviewVideoOrientation];
}

#pragma mark - Taking a Photo

- (void)takePicture
{
    [self _takePhoto];
}

#pragma mark - Processing a Photo

- (void)processImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension
{
    [self _processImage:image withCropRect:CGRectNull maxDimension:maxDimension fromCamera:NO needsPreviewRotation:NO];
}

- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect
{
    [self _processImage:image withCropRect:cropRect maxDimension:0.f fromCamera:NO needsPreviewRotation:NO];
}

- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect maxDimension:(CGFloat)maxDimension
{
    [self _processImage:image withCropRect:cropRect maxDimension:maxDimension fromCamera:NO needsPreviewRotation:NO];
}

#pragma mark - Camera State

+ (BOOL)isPointFocusAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self _cameraDevice:cameraDevice];
    if (device.focusPointOfInterestSupported) {
        return YES;
    }
    
    if (device.exposurePointOfInterestSupported) {
        return YES;
    }
    
    return NO;
}

- (void)focusAtPoint:(CGPoint)touchPoint
{
    AVCaptureDevice *device = [_session.inputs.lastObject device];
    
    if ([device lockForConfiguration:nil]) {
        CGPoint pointOfInterest = [_previewLayer captureDevicePointOfInterestForPoint:touchPoint];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        if (device.focusPointOfInterestSupported) {
            device.focusPointOfInterest = pointOfInterest;
        }
        
        if (device.exposurePointOfInterestSupported) {
            device.exposurePointOfInterest = pointOfInterest;
        }
        
        [device unlockForConfiguration];
    }
    
    [self _showFocusViewAtPoint:touchPoint];
}

+ (BOOL)isFlashAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self _cameraDevice:cameraDevice];
    
    if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
        return YES;
    }
    
    return NO;
}

- (void)setCameraFlashMode:(FastttCameraFlashMode)cameraFlashMode
{
    AVCaptureDevice *device = [_session.inputs.lastObject device];
    AVCaptureFlashMode mode;
    
    [device lockForConfiguration:nil];
    
    switch (cameraFlashMode) {
        case FastttCameraFlashModeOn:
            mode = AVCaptureFlashModeOn;
            break;
            
        case FastttCameraFlashModeOff:
            mode = AVCaptureFlashModeOff;
            break;
            
        case FastttCameraFlashModeAuto:
            mode = AVCaptureFlashModeAuto;
            break;
    }
    
    if ([device isFlashModeSupported:mode]) {
        device.flashMode = mode;
        _cameraFlashMode = cameraFlashMode;
    }
    
    [device unlockForConfiguration];
}

+ (BOOL)isCameraDeviceAvailable:(FastttCameraDevice)cameraDevice
{
    return [self _hasCameraDevice:cameraDevice];
}

- (void)setCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [self.class _cameraDevice:cameraDevice];
    
    if (!device) {
        return;
    }
    
    _cameraDevice = cameraDevice;
    
    AVCaptureDeviceInput *oldInput = [_session.inputs lastObject];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    [_session beginConfiguration];
    [_session removeInput:oldInput];
    [_session addInput:newInput];
    [_session commitConfiguration];

    if (![self.class isFlashAvailableForCameraDevice:cameraDevice]) {
        self.cameraFlashMode = FastttCameraFlashModeOff;
    }
}

#pragma mark - Capture Session Management

- (void)_startRunning
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session startRunning];
    });
}

- (void)_stopRunning
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session stopRunning];
    });
}

- (void)_insertPreviewLayerInView:(UIView *)rootView
{
    CALayer *rootLayer = [rootView layer];
    rootLayer.masksToBounds = YES;
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _previewLayer.frame = rootLayer.bounds;
    
    [rootLayer insertSublayer:_previewLayer atIndex:0];
}

- (void)_setupCaptureSession
{
    _session = [AVCaptureSession new];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device lockForConfiguration:nil]) {
        if([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        [device unlockForConfiguration];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_session addInput:deviceInput];
    
    switch (device.position) {
        case AVCaptureDevicePositionBack:
            _cameraDevice = FastttCameraDeviceRear;
            break;
            
        case AVCaptureDevicePositionFront:
            _cameraDevice = FastttCameraDeviceFront;
            break;
            
        default:
            break;
    }
#endif
    
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    
    _stillImageOutput = [AVCaptureStillImageOutput new];
    _stillImageOutput.outputSettings = outputSettings;
    
    [_session addOutput:_stillImageOutput];
    
    _deviceOrientation = [IFTTTDeviceOrientation new];
}

- (void)_teardownCaptureSession
{
    _deviceOrientation = nil;

    if ([_session isRunning]) {
        [_session stopRunning];
    }
    
    for (AVCaptureDeviceInput *input in [_session inputs]) {
        [_session removeInput:input];
    }
    
    [_session removeOutput:_stillImageOutput];
    _stillImageOutput = nil;
    
    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
    
    _session = nil;
}

#pragma mark - Tap to Focus

- (void)_setupTapFocusRecognizer
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapFocus:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_handleTapFocus:(UITapGestureRecognizer *)recognizer
{
    if (self.isFocusing) {
        return;
    }
        
    CGPoint location = [recognizer locationInView:self.view];
    
    [self focusAtPoint:location];
}

- (void)_showFocusViewAtPoint:(CGPoint)location
{
    if (self.isFocusing) {
        return;
    }
    
    self.isFocusing = YES;
    
    if (self.showsFocusView) {
        // show focus rectangle
        UIView *focusView = [UIView new];
        focusView.layer.borderColor = [UIColor yellowColor].CGColor;
        focusView.layer.borderWidth = 2.f;
        focusView.frame = [self _centeredRectForSize:CGSizeMake(kFocusSquareSize * 2.f,
                                                                kFocusSquareSize * 2.f)
                                       atCenterPoint:location];
        focusView.alpha = 0.f;
        [self.view addSubview:focusView];
        
        [UIView animateWithDuration:0.3f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             focusView.frame = [self _centeredRectForSize:CGSizeMake(kFocusSquareSize,
                                                                                     kFocusSquareSize)
                                                            atCenterPoint:location];
                             focusView.alpha = 1.f;
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:0.2f
                                              animations:^{
                                                  focusView.alpha = 0.f;
                                              } completion:^(BOOL finishedFadeout){
                                                  [focusView removeFromSuperview];
                                                  self.isFocusing = NO;
                                              }];
                         }];
        
    } else {
        self.isFocusing = NO;
    }
}

- (CGRect)_centeredRectForSize:(CGSize)size atCenterPoint:(CGPoint)center
{
    return CGRectInset(CGRectMake(center.x,
                                  center.y,
                                  0.f,
                                  0.f),
                       -size.width / 2.f,
                       -size.height / 2.f);
}

#pragma mark - Capturing a Photo

- (void)_takePhoto
{
    BOOL needsPreviewRotation = ![self.deviceOrientation deviceOrientationMatchesInterfaceOrientation];
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [_stillImageOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self _currentCaptureVideoOrientationForDevice]];
    }
    
    if ([videoConnection isVideoMirroringSupported]) {
        [videoConnection setVideoMirrored:(_cameraDevice == FastttCameraDeviceFront)];
    }
    
#if TARGET_IPHONE_SIMULATOR
    [self _insertPreviewLayerInView:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *fakeImage = [UIImage fastttFakeTestImage];
        [self _processCameraPhoto:fakeImage needsPreviewRotation:needsPreviewRotation];
    });
#else
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (!imageDataSampleBuffer) {
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             
             UIImage *image = [UIImage imageWithData:imageData];
             
             [self _processCameraPhoto:image needsPreviewRotation:needsPreviewRotation];
         });
     }];
#endif
}

#pragma mark - Processing a Photo

- (void)_processCameraPhoto:(UIImage *)image needsPreviewRotation:(BOOL)needsPreviewRotation
{
    [self _processImage:image withCropRect:CGRectNull maxDimension:self.maxScaledDimension fromCamera:YES needsPreviewRotation:needsPreviewRotation];
}

- (void)_processImage:(UIImage *)image withCropRect:(CGRect)cropRect maxDimension:(CGFloat)maxDimension fromCamera:(BOOL)fromCamera needsPreviewRotation:(BOOL)needsPreviewRotation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        FastttCapturedImage *capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];

        if (fromCamera && self.cropsImageToVisibleAspectRatio) {
            capturedImage.fullImage = [capturedImage.fullImage fastttCroppedToPreviewLayerBounds:_previewLayer];
        } else if (!CGRectEqualToRect(cropRect, CGRectNull)) {
            capturedImage.fullImage = [capturedImage.fullImage fastttCroppedToRect:cropRect];
        }
        
        if (fromCamera && self.returnsRotatedPreview) {
            UIImage *previewImage;
            if (needsPreviewRotation || !self.interfaceRotatesWithOrientation) {
                previewImage = [capturedImage.fullImage fastttRotatedToMatchCameraView];
            } else {
                previewImage = capturedImage.fullImage;
            }
            capturedImage.rotatedPreviewImage = previewImage;
        }
        
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishCapturingImage:)]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate cameraController:self didFinishCapturingImage:capturedImage];
            });
        }
        
        if (maxDimension > 0.f) {
            [self _scaleCapturedImage:capturedImage toMaxDimension:maxDimension];
        } else if (fromCamera && self.scalesImage) {
            [self _scaleCapturedImageToViewBounds:capturedImage];
        }
        
        if (self.normalizesImageOrientations) {
            [self _normalizeCapturedImage:capturedImage];
        }
    });
}

- (void)_scaleCapturedImage:(FastttCapturedImage *)capturedImage toMaxDimension:(CGFloat)maxDimension
{
    capturedImage.scaledImage = [capturedImage.fullImage fastttScaledToMaxDimension:maxDimension];
    
    [self _didScaleCapturedImage:capturedImage];
}

- (void)_scaleCapturedImageToViewBounds:(FastttCapturedImage *)capturedImage
{
    capturedImage.scaledImage = [capturedImage.fullImage fastttScaledToSize:self.view.bounds.size];
    
    [self _didScaleCapturedImage:capturedImage];
}

- (void)_didScaleCapturedImage:(FastttCapturedImage *)capturedImage
{
    if ([self.delegate respondsToSelector:@selector(cameraController:didFinishScalingCapturedImage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.delegate cameraController:self didFinishScalingCapturedImage:capturedImage];
        });
    }
}

- (void)_normalizeCapturedImage:(FastttCapturedImage *)capturedImage
{
    UIImage *normalizedFullImage = [capturedImage.fullImage fastttNormalizeOrientation];
    UIImage *normalizedScaledImage = [capturedImage.scaledImage fastttNormalizeOrientation];
    
    capturedImage.fullImage = normalizedFullImage;
    capturedImage.scaledImage = normalizedScaledImage;
    capturedImage.isNormalized = YES;
    
    if ([self.delegate respondsToSelector:@selector(cameraController:didFinishNormalizingCapturedImage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.delegate cameraController:self didFinishNormalizingCapturedImage:capturedImage];
        });
    }
}

#pragma mark - AV Orientation

- (void)_setPreviewVideoOrientation
{
    AVCaptureConnection *videoConnection = [_previewLayer connection];
    
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self _currentPreviewVideoOrientationForDevice]];
    }
}

- (AVCaptureVideoOrientation)_currentCaptureVideoOrientationForDevice
{
    return [self.class _videoOrientationForDeviceOrientation:self.deviceOrientation.orientation];
}

- (AVCaptureVideoOrientation)_currentPreviewVideoOrientationForDevice
{
    return [self.class _videoOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]];
}

+ (AVCaptureVideoOrientation)_videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            
        default:
            break;
    }
    
    return AVCaptureVideoOrientationPortrait;
}

#pragma mark - FastttCameraDevice

+ (AVCaptureDevicePosition)_avPositionForDevice:(FastttCameraDevice)cameraDevice
{
    switch (cameraDevice) {
        case FastttCameraDeviceFront:
            return AVCaptureDevicePositionFront;

        case FastttCameraDeviceRear:
            return AVCaptureDevicePositionBack;

        default:
            break;
    }
    
    return AVCaptureDevicePositionUnspecified;
}

+ (AVCaptureDevice *)_cameraDevice:(FastttCameraDevice)cameraDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == [self _avPositionForDevice:cameraDevice]) {
            return device;
        }
    }
    
    return nil;
}

+ (BOOL)_hasCameraDevice:(FastttCameraDevice)cameraDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == [self _avPositionForDevice:cameraDevice]) {
            return YES;
        }
    }

    return NO;
}

@end
