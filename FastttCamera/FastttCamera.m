//
//  FastttCamera.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/5/15.
//
//

#import <AVFoundation/AVFoundation.h>

#import "FastttCamera.h"
#import "IFTTTDeviceOrientation.h"
#import "UIImage+FastttCamera.h"
#import "AVCaptureDevice+FastttCamera.h"
#import "FastttFocus.h"
#import "FastttZoom.h"
#import "FastttCapturedImage+Process.h"

@interface FastttCamera () <FastttFocusDelegate, FastttZoomDelegate>

@property (nonatomic, strong) IFTTTDeviceOrientation *deviceOrientation;
@property (nonatomic, strong) FastttFocus *fastFocus;
@property (nonatomic, strong) FastttZoom *fastZoom;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, assign) BOOL deviceAuthorized;
@property (nonatomic, assign) BOOL isCapturingImage;
@property (nonatomic, strong) dispatch_queue_t sampleBufferQueue;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@end

@implementation FastttCamera

@synthesize delegate = _delegate,
            returnsRotatedPreview = _returnsRotatedPreview,
            showsFocusView = _showsFocusView,
            maxScaledDimension = _maxScaledDimension,
            normalizesImageOrientations = _normalizesImageOrientations,
            cropsImageToVisibleAspectRatio = _cropsImageToVisibleAspectRatio,
            interfaceRotatesWithOrientation = _interfaceRotatesWithOrientation,
            fixedInterfaceOrientation = _fixedInterfaceOrientation,
            handlesTapFocus = _handlesTapFocus,
            handlesZoom = _handlesZoom,
            maxZoomFactor = _maxZoomFactor,
            showsZoomView = _showsZoomView,
            gestureView = _gestureView,
            gestureDelegate = _gestureDelegate,
            scalesImage = _scalesImage,
            cameraDevice = _cameraDevice,
            cameraFlashMode = _cameraFlashMode,
            cameraTorchMode = _cameraTorchMode,
            mirrorsVideo = _mirrorsVideo,
            mirrorsTakePhoto = _mirrorsTakePhoto;

- (instancetype)init {
    if ((self = [super init])) {
        
        _sampleBufferQueue = dispatch_queue_create("com.xaphod.fastttcamera.samplebuffer", NULL);
        _handlesTapFocus = YES;
        _showsFocusView = YES;
        _handlesZoom = YES;
        _showsZoomView = YES;
        _cropsImageToVisibleAspectRatio = YES;
        _scalesImage = YES;
        _maxScaledDimension = 0.f;
        _maxZoomFactor = 1.f;
        _normalizesImageOrientations = YES;
        _returnsRotatedPreview = YES;
        _interfaceRotatesWithOrientation = YES;
        _fixedInterfaceOrientation = UIDeviceOrientationPortrait;
        _cameraDevice = FastttCameraDeviceRear;
        _cameraFlashMode = FastttCameraFlashModeOff;
        _cameraTorchMode = FastttCameraTorchModeOff;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    [self _checkDeviceAuthorizationWithCompletion:^(BOOL isAuthorized) {
        
        _deviceAuthorized = isAuthorized;
#else
        _deviceAuthorized = YES;
#endif
        
#if !TARGET_IPHONE_SIMULATOR
    }];
#endif
    return self;
}

- (void)dealloc
{
    _fastFocus = nil;
    _fastZoom = nil;
    
    [self _teardownCaptureSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Events

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupCaptureSession];
    [self _insertPreviewLayer];
    
    UIView *viewForGestures = self.view;
    
    if (self.gestureView) {
        viewForGestures = self.gestureView;
    }
    
    _fastFocus = [FastttFocus fastttFocusWithView:viewForGestures gestureDelegate:self.gestureDelegate];
    self.fastFocus.delegate = self;
    
    if (!self.handlesTapFocus) {
        self.fastFocus.detectsTaps = NO;
    }
    
    _fastZoom = [FastttZoom fastttZoomWithView:viewForGestures gestureDelegate:self.gestureDelegate];
    self.fastZoom.delegate = self;
    
    if (!self.handlesZoom) {
        self.fastZoom.detectsPinch = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startRunning];
    
    [self _insertPreviewLayer];
    
    [self _setPreviewVideoOrientation];
    [self _setPreviewVideoMirroring];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self stopRunning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _previewLayer.frame = self.view.layer.bounds;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self _setupCaptureSession];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.isViewLoaded && self.view.window) {
        [self startRunning];
        [self _insertPreviewLayer];
        [self _setPreviewVideoOrientation];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self stopRunning];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self _teardownCaptureSession];
}

#pragma mark - Autorotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setPreviewVideoOrientation];
}

#pragma mark - Taking a Photo

- (BOOL)isReadyToCapturePhoto
{
    if (!_deviceAuthorized) {
        if ([self.delegate respondsToSelector:@selector(userDeniedCameraPermissionsForCameraController:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate userDeniedCameraPermissionsForCameraController:self];
            });
        }
        return NO;
    }

    return !self.isCapturingImage;
}

- (void)takePicture:(void(^)(UIImage*))completionBlock {
    if (!_deviceAuthorized) {
        if ([self.delegate respondsToSelector:@selector(userDeniedCameraPermissionsForCameraController:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate userDeniedCameraPermissionsForCameraController:self];
            });
        }
        if (completionBlock)
            completionBlock(nil);
        return;
    }

    [self _takePhoto:completionBlock];
}

- (void)cancelImageProcessing
{
    if (_isCapturingImage) {
        _isCapturingImage = NO;
    }
}

#pragma mark - Processing a Photo

- (void)processImage:(UIImage *)image withMaxDimension:(CGFloat)maxDimension {
    [self _processImage:image withCropRect:CGRectNull maxDimension:maxDimension fromCamera:NO needsPreviewRotation:NO previewOrientation:UIDeviceOrientationUnknown completionBlock:nil];
}

- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect {
    [self _processImage:image withCropRect:cropRect maxDimension:0.f fromCamera:NO needsPreviewRotation:NO previewOrientation:UIDeviceOrientationUnknown completionBlock:nil];
}

- (void)processImage:(UIImage *)image withCropRect:(CGRect)cropRect maxDimension:(CGFloat)maxDimension {
    [self _processImage:image withCropRect:cropRect maxDimension:maxDimension fromCamera:NO needsPreviewRotation:NO previewOrientation:UIDeviceOrientationUnknown completionBlock:nil];
}

#pragma mark - Camera State

+ (BOOL)isPointFocusAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    return [AVCaptureDevice isPointFocusAvailableForCameraDevice:cameraDevice];
}

- (BOOL)focusAtPoint:(CGPoint)touchPoint
{
    CGPoint pointOfInterest = [self _focusPointOfInterestForTouchPoint:touchPoint];
    
    return [self _focusAtPointOfInterest:pointOfInterest];
}

- (BOOL)zoomToScale:(CGFloat)scale
{
    return [[self _currentCameraDevice] zoomToScale:scale];
}

- (BOOL)isFlashAvailableForCurrentDevice
{
    AVCaptureDevice *device = [self _currentCameraDevice];
    
    if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isFlashAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    return [AVCaptureDevice isFlashAvailableForCameraDevice:cameraDevice];
}

- (BOOL)isTorchAvailableForCurrentDevice
{
    AVCaptureDevice *device = [self _currentCameraDevice];
    
    if ([device isTorchModeSupported:AVCaptureTorchModeOn]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isTorchAvailableForCameraDevice:(FastttCameraDevice)cameraDevice
{
    return [AVCaptureDevice isTorchAvailableForCameraDevice:cameraDevice];
}

+ (BOOL)isCameraDeviceAvailable:(FastttCameraDevice)cameraDevice
{
    return ([AVCaptureDevice cameraDevice:cameraDevice] != nil);
}

- (void)setCameraDevice:(FastttCameraDevice)cameraDevice
{
    AVCaptureDevice *device = [AVCaptureDevice cameraDevice:cameraDevice];
    
    if (!device) {
        return;
    }
    
    if (_cameraDevice != cameraDevice) {
        _cameraDevice = cameraDevice;
        
        AVCaptureDeviceInput *oldInput = [_session.inputs lastObject];
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        [_session beginConfiguration];
        [_session removeInput:oldInput];
        [_session addInput:newInput];
        [_session commitConfiguration];
    }
    
    [self setCameraFlashMode:_cameraFlashMode];
    [self _resetZoom];
}

- (void)setCameraFlashMode:(FastttCameraFlashMode)cameraFlashMode
{
    AVCaptureDevice *device = [self _currentCameraDevice];
    
    if ([AVCaptureDevice isFlashAvailableForCameraDevice:self.cameraDevice]) {
        _cameraFlashMode = cameraFlashMode;
        [device setCameraFlashMode:cameraFlashMode];
        return;
    }
    
    _cameraFlashMode = FastttCameraFlashModeOff;
}

- (void)setCameraTorchMode:(FastttCameraTorchMode)cameraTorchMode
{
    AVCaptureDevice *device = [self _currentCameraDevice];
    
    if ([AVCaptureDevice isTorchAvailableForCameraDevice:self.cameraDevice]) {
        _cameraTorchMode = cameraTorchMode;
        [device setCameraTorchMode:cameraTorchMode];
        return;
    }
    
    _cameraTorchMode = FastttCameraTorchModeOff;
}

#pragma mark - Capture Session Management

- (void)startRunning
{
    if (!_deviceAuthorized) {
        if ([self.delegate respondsToSelector:@selector(userDeniedCameraPermissionsForCameraController:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate userDeniedCameraPermissionsForCameraController:self];
            });
        }
        return;
    }

    if (![_session isRunning]) {
        [_session startRunning];
    }
}

- (void)stopRunning
{
    if ([_session isRunning]) {
        [_session stopRunning];
    }
}

- (void)_insertPreviewLayer
{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif

    if (!_deviceAuthorized || !_session) {
        return;
    }
    
    if ([_previewLayer superlayer] == [self.view layer]
        && [_previewLayer session] == _session) {
        return;
    }
    
    [self _removePreviewLayer];
    
    CALayer *rootLayer = [self.view layer];
    rootLayer.masksToBounds = YES;
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _previewLayer.frame = rootLayer.bounds;
    
    [rootLayer insertSublayer:_previewLayer atIndex:0];
}

- (void)_removePreviewLayer
{
    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
}

- (void)_setupCaptureSession
{
    if (_session) {
        return;
    }
    
    NSAssert([NSThread currentThread].isMainThread, @"ERROR must be main thread here");

    _session = [AVCaptureSession new];

#if !TARGET_IPHONE_SIMULATOR
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice cameraDevice:self.cameraDevice];
    
    if (!device) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if ([device lockForConfiguration:nil]) {
        if([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        [device unlockForConfiguration];
    }
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!deviceInput) {
        _session = nil;
        return;
    }
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
    
    [self setCameraFlashMode:_cameraFlashMode];
    
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    
    _stillImageOutput = [AVCaptureStillImageOutput new];
    _stillImageOutput.outputSettings = outputSettings;
    _stillImageOutput.highResolutionStillImageOutputEnabled = YES;
    [_session addOutput:_stillImageOutput];
    
    _deviceOrientation = [IFTTTDeviceOrientation new];
    
    if (self.sendIndividualVideoFrames) {
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.videoOutput.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
        [self.videoOutput setSampleBufferDelegate:self queue:self.sampleBufferQueue];
        [_session addOutput:self.videoOutput];
    }
#endif

    if (self.isViewLoaded && self.view.window) {
        [self startRunning];
        [self _insertPreviewLayer];
        [self _setPreviewVideoOrientation];
        [self _resetZoom];
    }
}

- (void)_teardownCaptureSession
{
    if (!_session) {
        return;
    }
    
    _deviceOrientation = nil;
    
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    
    for (AVCaptureDeviceInput *input in [_session inputs]) {
        [_session removeInput:input];
    }
    
    [_session removeOutput:_stillImageOutput];
    _stillImageOutput = nil;
    
    if (self.videoOutput) {
        [_session removeOutput:self.videoOutput];
        self.videoOutput = nil;
    }
    
    [self _removePreviewLayer];
    
    _session = nil;
}

#pragma mark - Capturing a Photo

- (void)_takePhoto:(void(^)(UIImage*))completionBlock {
    if (self.isCapturingImage || !_session.isRunning) {
        if (completionBlock)
            completionBlock(nil);
        return;
    }
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        self.isCapturingImage = NO;
        NSLog(@"FastttCamera: must be UIApplicationStateActive to take photo");
        if (completionBlock)
            completionBlock(nil);
        return;
    }

    AVCaptureConnection *videoConnection = [self _currentCaptureConnection];
    if (!videoConnection.isActive || !videoConnection.isEnabled) {
        if (completionBlock)
            completionBlock(nil);
        return;
    }
    
    BOOL stillImageOutputConnected = NO;
    for (AVCaptureConnection *conn in _stillImageOutput.connections) {
        if (conn == videoConnection) {
            stillImageOutputConnected = YES;
        }
    }
    if (!stillImageOutputConnected) {
        if (completionBlock)
            completionBlock(nil);
        return;
    }
    
    self.isCapturingImage = YES;
    
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:[self _currentCaptureVideoOrientationForDevice]];
    }
    
    if ([videoConnection isVideoMirroringSupported]) {
        [videoConnection setVideoMirrored:self.mirrorsTakePhoto];
    }

    BOOL needsPreviewRotation = ![self.deviceOrientation deviceOrientationMatchesInterfaceOrientation];
    
#if TARGET_IPHONE_SIMULATOR
    [self _insertPreviewLayer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *fakeImage = [UIImage fastttFakeTestImage];
        [self _processCameraPhoto:fakeImage needsPreviewRotation:needsPreviewRotation previewOrientation:UIDeviceOrientationPortrait completionBlock:completionBlock];
    });
#else    
    UIDeviceOrientation previewOrientation = [self _currentPreviewDeviceOrientation];

    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (!imageDataSampleBuffer || !self.isCapturingImage) {
             self.isCapturingImage = NO;
             if (completionBlock)
                 completionBlock(nil);
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         if ([self.delegate respondsToSelector:@selector(cameraController:didFinishCapturingImageData:)]) {
             [self.delegate cameraController:self didFinishCapturingImageData:imageData];
         }

         UIImage *image = [UIImage imageWithData:imageData];
         [self _processCameraPhoto:image needsPreviewRotation:needsPreviewRotation previewOrientation:previewOrientation completionBlock:completionBlock];
     }];
#endif
}

#pragma mark - Processing a Photo

- (void)_processCameraPhoto:(UIImage *)image needsPreviewRotation:(BOOL)needsPreviewRotation previewOrientation:(UIDeviceOrientation)previewOrientation completionBlock:(void(^)(UIImage*))completionBlock {

    CGRect cropRect = CGRectNull;
    if (self.cropsImageToVisibleAspectRatio) {
        cropRect = [image fastttCropRectFromPreviewLayer:_previewLayer];
    }
    
    [self _processImage:image withCropRect:cropRect maxDimension:self.maxScaledDimension fromCamera:YES needsPreviewRotation:(needsPreviewRotation || !self.interfaceRotatesWithOrientation) previewOrientation:previewOrientation completionBlock:completionBlock];
}

- (void)_processImage:(UIImage *)image withCropRect:(CGRect)cropRect maxDimension:(CGFloat)maxDimension fromCamera:(BOOL)fromCamera needsPreviewRotation:(BOOL)needsPreviewRotation previewOrientation:(UIDeviceOrientation)previewOrientation completionBlock:(void(^)(UIImage*))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (fromCamera && !self.isCapturingImage) {
            if (completionBlock)
                completionBlock(nil);
            return;
        }
        
        FastttCapturedImage *capturedImage = [FastttCapturedImage fastttCapturedFullImage:image];
        
        [capturedImage cropToRect:cropRect
                   returnsPreview:(fromCamera && self.returnsRotatedPreview)
             needsPreviewRotation:needsPreviewRotation
           withPreviewOrientation:previewOrientation
                     withCallback:^(FastttCapturedImage *capturedImage){
                         if (fromCamera && !self.isCapturingImage) {
                             if (completionBlock)
                                 completionBlock(nil);
                             return;
                         }
                         if ([self.delegate respondsToSelector:@selector(cameraController:didFinishCapturingImage:)]) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.delegate cameraController:self didFinishCapturingImage:capturedImage];
                             });
                         }
                     }];
        
        void (^scaleCallback)(FastttCapturedImage *capturedImage) = ^(FastttCapturedImage *capturedImage) {
            if (fromCamera && !self.isCapturingImage) {
                if (completionBlock)
                    completionBlock(nil);
                return;
            }
            if ([self.delegate respondsToSelector:@selector(cameraController:didFinishScalingCapturedImage:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate cameraController:self didFinishScalingCapturedImage:capturedImage];
                });
            }
        };
        
        if (fromCamera && !self.isCapturingImage) {
            if (completionBlock)
                completionBlock(nil);
            return;
        }
        
        if (maxDimension > 0.f) {
            [capturedImage scaleToMaxDimension:maxDimension
                                  withCallback:scaleCallback];
        } else if (fromCamera && self.scalesImage) {
            [capturedImage scaleToSize:self.view.bounds.size
                          withCallback:scaleCallback];
        }
        
        if (fromCamera && !self.isCapturingImage) {
            if (completionBlock)
                completionBlock(nil);
            return;
        }
        
        if (self.normalizesImageOrientations) {
            [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
                if (fromCamera && !self.isCapturingImage) {
                    if (completionBlock)
                        completionBlock(nil);
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(cameraController:didFinishNormalizingCapturedImage:)]) {
                        [self.delegate cameraController:self didFinishNormalizingCapturedImage:capturedImage];
                    }
                    if (completionBlock)
                        completionBlock(capturedImage.fullImage);
                });
            }];
        }
        
        self.isCapturingImage = NO;
    });
}

#pragma mark - AV Orientation

- (void)_setPreviewVideoOrientation
{
    AVCaptureConnection *videoConnection = [_previewLayer connection];
    AVCaptureVideoOrientation orientation = [self _currentPreviewVideoOrientationForDevice];
    
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:orientation];
    }
    
    if (self.sendIndividualVideoFrames) {
        AVCaptureConnection* connection = self.videoOutput.connections.firstObject;
        if ([connection isVideoOrientationSupported]) {
            [connection setVideoOrientation:orientation];
        }
    }
}

- (void)_setPreviewVideoMirroring {
    AVCaptureConnection *videoConnection = [_previewLayer connection];
    videoConnection.automaticallyAdjustsVideoMirroring = NO;
    if ([videoConnection isVideoMirroringSupported]) {
        [videoConnection setVideoMirrored:self.mirrorsVideo];
    }

    if (self.sendIndividualVideoFrames) {
        AVCaptureConnection* connection = self.videoOutput.connections.firstObject;
        connection.automaticallyAdjustsVideoMirroring = NO;
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:self.mirrorsVideo];
        }
    }
}

- (AVCaptureVideoOrientation)_currentCaptureVideoOrientationForDevice
{
    UIDeviceOrientation actualOrientation = self.deviceOrientation.orientation;
    
    if (actualOrientation == UIDeviceOrientationFaceDown
        || actualOrientation == UIDeviceOrientationFaceUp
        || actualOrientation == UIDeviceOrientationUnknown) {
        return [self _currentPreviewVideoOrientationForDevice];
    }
    
    return [self.class _videoOrientationForDeviceOrientation:actualOrientation];
}

- (UIDeviceOrientation)_currentPreviewDeviceOrientation
{
    if (!self.interfaceRotatesWithOrientation) {
        return self.fixedInterfaceOrientation;
    }
    
    return [[UIDevice currentDevice] orientation];
}

- (AVCaptureVideoOrientation)_currentPreviewVideoOrientationForDevice
{
    UIDeviceOrientation deviceOrientation = [self _currentPreviewDeviceOrientation];

    return [self.class _videoOrientationForDeviceOrientation:deviceOrientation];
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
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            return [self.class _videoOrientationFromStatusBarOrientation];
            
        default:
            break;
    }
    
    return AVCaptureVideoOrientationPortrait;
}

+ (AVCaptureVideoOrientation)_videoOrientationFromStatusBarOrientation {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;

        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;

        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}

#pragma mark - Camera Permissions

- (void)_checkDeviceAuthorizationWithCompletion:(void (^)(BOOL isAuthorized))completion
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (completion) {
            completion(granted);
        }
    }];
}

#pragma mark - FastttCameraDevice

- (AVCaptureDevice *)_currentCameraDevice
{
    return [_session.inputs.lastObject device];
}

- (AVCaptureConnection *)_currentCaptureConnection
{
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
    
    return videoConnection;
}

- (CGPoint)_focusPointOfInterestForTouchPoint:(CGPoint)touchPoint
{
    return [_previewLayer captureDevicePointOfInterestForPoint:touchPoint];
}

- (BOOL)_focusAtPointOfInterest:(CGPoint)pointOfInterest
{
    return [[self _currentCameraDevice] focusAtPointOfInterest:pointOfInterest];
}

- (void)_resetZoom
{
    [self.fastZoom resetZoom];
    
    self.fastZoom.maxScale = [[self _currentCameraDevice] videoMaxZoomFactor];
    
    self.maxZoomFactor = self.fastZoom.maxScale;
}

#pragma mark - FastttFocusDelegate

- (BOOL)handleTapFocusAtPoint:(CGPoint)touchPoint
{
    if ([AVCaptureDevice isPointFocusAvailableForCameraDevice:self.cameraDevice]) {
        
        CGPoint pointOfInterest = [self _focusPointOfInterestForTouchPoint:touchPoint];
        
        return ([self _focusAtPointOfInterest:pointOfInterest] && self.showsFocusView);
    }
    
    return NO;
}

#pragma mark - FastttZoomDelegate

- (BOOL)handlePinchZoomWithScale:(CGFloat)zoomScale
{
    return ([self zoomToScale:zoomScale] && self.showsZoomView);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.sendIndividualVideoFrames && self.delegate) {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        // Get the number of bytes per row for the pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // Create an image object from the Quartz image
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        FastttCapturedImage *capturedImage = [FastttCapturedImage fastttCapturedFullImage: image];

        // Release the Quartz image
        CGImageRelease(quartzImage);
        
        [capturedImage normalizeWithCallback:^(FastttCapturedImage *capturedImage){
            if (capturedImage) {
                [self.delegate cameraController:self didCaptureVideoFrame:capturedImage.fullImage];
            }
        }];
    }
}

// if the property for sending invidiual video frames changes, then the session needs to be rebuilt
- (void)setSendIndividualVideoFrames:(BOOL)sendIndividualVideoFrames {
    if (_session) {
        NSLog(@"FastttCamera: updating existing session for change to sendIndividualVideoFrames");
        if (sendIndividualVideoFrames) {
            // turn it on
            for (AVCaptureOutput *output in _session.outputs) {
                if ([output isKindOfClass:AVCaptureVideoDataOutput.class]) {
                    if (output == self.videoOutput) {
                        NSLog(@"FastttCamera: ... no-op");
                        return;
                    } else {
                        NSAssert(false, @"ERROR");
                        [_session removeOutput:output];
                    }
                }
            }
            self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
            self.videoOutput.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
            [self.videoOutput setSampleBufferDelegate:self queue:self.sampleBufferQueue];
            [_session addOutput:self.videoOutput];
        } else {
            // turn it off
            self.videoOutput = nil;
            for (AVCaptureOutput *output in _session.outputs) {
                if ([output isKindOfClass:AVCaptureVideoDataOutput.class]) {
                    [(AVCaptureVideoDataOutput*)output setSampleBufferDelegate:nil queue:nil];
                    [_session removeOutput:output];
                    break;
                }
            }
        }
    }
    
    _sendIndividualVideoFrames = sendIndividualVideoFrames;
}

@end
