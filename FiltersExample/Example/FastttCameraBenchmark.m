//
//  FastttCameraBenchmark.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "FastttCameraBenchmark.h"
#import <FastttCamera/FastttFilterCamera.h>
#import <Masonry/Masonry.h>

NSInteger const kIFTTTFastttBenchmarkTestIterations = 20;

@interface FastttCameraBenchmark () <FastttCameraDelegate>

@property (nonatomic, strong) FastttFilterCamera *fastCamera;
@property (nonatomic, strong) UIButton *runTestButton;
@property (nonatomic, strong) UILabel *averageTimeLabel;
@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, assign) NSInteger cropCounter;
@property (nonatomic, assign) NSInteger scaleCounter;
@property (nonatomic, assign) NSInteger renderCounter;
@property (nonatomic, assign) NSInteger normalizeCounter;

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval totalCropPhotoTime;
@property (nonatomic, assign) NSTimeInterval totalScalePhotoTime;
@property (nonatomic, assign) NSTimeInterval totalTimeToRender;
@property (nonatomic, assign) NSTimeInterval totalTimeToNormalize;
@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation FastttCameraBenchmark

- (instancetype)init
{
    if ((self = [super init])) {
        
        self.title = @"FastttCamera Test";
        self.tabBarItem.image = [UIImage imageNamed:@"LightningFast"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _fastCamera = [FastttFilterCamera cameraWithFilterImage:[UIImage imageNamed:@"YellowRetro"]];
    self.fastCamera.delegate = self;
    
    [self fastttAddChildViewController:self.fastCamera];
    
    [self.fastCamera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    
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
    self.cropCounter = 0;
    self.scaleCounter = 0;
    self.renderCounter = 0;
    self.normalizeCounter = 0;
    self.totalCropPhotoTime = 0.f;
    self.totalScalePhotoTime = 0.f;
    self.totalTimeToRender = 0.f;
    self.totalTimeToNormalize = 0.f;
    [self startBenchmarkTestIteration];
}

- (void)startBenchmarkTestIteration
{
    [NSThread sleepForTimeInterval:0.1f];
    
    self.counter += 1;
    
    self.startTime = CACurrentMediaTime();
    [self.fastCamera takePicture];
}

- (void)cropPhotoBenchmarkTestIteration
{
    self.cropCounter += 1;
    self.totalCropPhotoTime += CACurrentMediaTime() - self.startTime;
}

- (void)renderPhotoBenchmarkTestIteration
{
    self.renderCounter += 1;
    self.totalTimeToRender += CACurrentMediaTime() - self.startTime;
}

- (void)scalePhotoBenchmarkTestIteration
{
    self.scaleCounter += 1;
    self.totalScalePhotoTime += CACurrentMediaTime() - self.startTime;
}

- (void)normalizePhotoBenchmarkTestIteration
{
    self.normalizeCounter += 1;
    self.totalTimeToNormalize += CACurrentMediaTime() - self.startTime;
}

- (void)endBenchmarkTestIteration
{
    NSLog(@"run %@", @(self.counter));
    if (self.counter < kIFTTTFastttBenchmarkTestIterations) {
        [self startBenchmarkTestIteration];
    } else {
        [self finishBenchmarkTest];
    }
}

- (void)finishBenchmarkTest
{
    CGFloat averageCropPhotoTime = (CGFloat)(self.totalCropPhotoTime / self.cropCounter);
    NSLog(@"Average Run Time for FastttCamera Crop Photo: %@", @(averageCropPhotoTime));
    
    CGFloat averageRenderPhotoTime = (CGFloat)(self.totalTimeToRender / self.renderCounter);
    NSLog(@"Average Run Time for FastttCamera Render Photo: %@", @(averageRenderPhotoTime));
    
    CGFloat averageScalePhotoTime = (CGFloat)(self.totalScalePhotoTime / self.scaleCounter);
    NSLog(@"Average Run Time for FastttCamera Scale Photo: %@", @(averageScalePhotoTime));
    
    CGFloat averageNormalizePhotoTime = (CGFloat)(self.totalTimeToNormalize / self.normalizeCounter);
    NSLog(@"Average Run Time for FastttCamera Normalize Photo: %@", @(averageNormalizePhotoTime));
    
    self.averageTimeLabel.text = [NSString stringWithFormat: @"Average Time: %@", @(averageNormalizePhotoTime)];
}

#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(id <FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    [self cropPhotoBenchmarkTestIteration];
    
    self.previewImageView.image = capturedImage.rotatedPreviewImage;
    
    // forces the image view to render now so we can see the delay
    [self.previewImageView setNeedsDisplay];
    [CATransaction flush];
    
    [self renderPhotoBenchmarkTestIteration];
    
    capturedImage.rotatedPreviewImage = nil;
}

- (void)cameraController:(id <FastttCameraInterface>)cameraController didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage
{
    [self scalePhotoBenchmarkTestIteration];
}

- (void)cameraController:(id <FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    [self normalizePhotoBenchmarkTestIteration];
    
    [self endBenchmarkTestIteration];
    
}

@end
