//
//  ExampleViewController.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "ExampleViewController.h"
#import <FastttFilterCamera.h>
#import <Masonry.h>
#import "ConfirmViewController.h"
#import "ExampleFilter.h"

@interface ExampleViewController () <FastttCameraDelegate, ConfirmControllerDelegate>

@property (nonatomic, strong) FastttFilterCamera *fastCamera;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *changeFilterButton;
@property (nonatomic, strong) ExampleFilter *currentFilter;
@property (nonatomic, strong) ConfirmViewController *confirmController;
@property (nonatomic, weak) UIView *additionalPreviewView;
@property (nonatomic, weak) MASConstraint *additionalPreviewLeftConstraint;

@end

@implementation ExampleViewController

- (instancetype)init
{
    if ((self = [super init])) {
        
        self.title = @"Example Camera";
        self.tabBarItem.image = [UIImage imageNamed:@"TakePhoto"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentFilter = [ExampleFilter filterWithType:FastttCameraFilterRetro];
    _fastCamera = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
    self.fastCamera.delegate = self;
    self.fastCamera.maxScaledDimension = 600.f;
    
    [self fastttAddChildViewController:self.fastCamera];
    
    [self.fastCamera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.and.width.lessThanOrEqualTo(self.view.mas_width).with.priorityHigh();
        make.height.and.width.lessThanOrEqualTo(self.view.mas_height).with.priorityHigh();
        make.height.and.width.equalTo(self.view.mas_width).with.priorityLow();
        make.height.and.width.equalTo(self.view.mas_height).with.priorityLow();
    }];
    
    UIView * addonView = [_fastCamera createOutputView:(UIViewContentModeScaleAspectFill)];
    [self.view addSubview:addonView];
    self.additionalPreviewView = addonView;
    
    [addonView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.additionalPreviewLeftConstraint = make.left.equalTo(@20);
        make.top.equalTo(@20);
        make.width.and.height.equalTo(@100);
    }];
    
    
    _takePhotoButton = [UIButton new];
    [self.takePhotoButton addTarget:self
                             action:@selector(takePhotoButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.takePhotoButton setTitle:@"Take Photo"
                          forState:UIControlStateNormal];
    
    [self.view addSubview:self.takePhotoButton];
    [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
    }];
    
    _flashButton = [UIButton new];
    self.flashButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.flashButton.titleLabel.numberOfLines = 0;
    [self.flashButton addTarget:self
                         action:@selector(flashButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.flashButton setTitle:@"Flash Off"
                      forState:UIControlStateNormal];
    
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];
    
    [self.view addSubview:self.flashButton];
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.left.equalTo(self.view).offset(20.f);
    }];
    
    _switchCameraButton = [UIButton new];
    self.switchCameraButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.switchCameraButton.titleLabel.numberOfLines = 0;
    [self.switchCameraButton addTarget:self
                                action:@selector(switchCameraButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.switchCameraButton setTitle:@"Switch Camera"
                             forState:UIControlStateNormal];
    
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
        make.size.equalTo(self.flashButton);
    }];
    
    _torchButton = [UIButton new];
    self.torchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.torchButton.titleLabel.numberOfLines = 0;
    [self.torchButton addTarget:self
                         action:@selector(torchButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.torchButton setTitle:@"Torch Off"
                      forState:UIControlStateNormal];
    
    [self.fastCamera setCameraTorchMode:FastttCameraTorchModeOff];
    [self.view addSubview:self.torchButton];
    [self.torchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.left.equalTo(self.flashButton.mas_right).offset(20.f);
        make.right.equalTo(self.switchCameraButton.mas_left).offset(-20.f);
        make.size.equalTo(self.flashButton);
    }];
    
    _changeFilterButton = [UIButton new];
    [self.changeFilterButton addTarget:self
                                action:@selector(switchFilterButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];

    [self.changeFilterButton setTitle:@"Filter"
                             forState:UIControlStateNormal];

    [self.view addSubview:self.changeFilterButton];
    [self.changeFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20.f);
        make.right.equalTo(self.view).offset(-20.f);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.confirmController = nil;
    
    self.additionalPreviewLeftConstraint.offset = 100;
    [UIView animateWithDuration:3
                          delay:0
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^{
                            [self.additionalPreviewView layoutIfNeeded];
                        } completion:nil];
    [UIView animateWithDuration:5 animations:^{
        [self.additionalPreviewView layoutIfNeeded];
    }];
    
}

- (void)takePhotoButtonPressed
{
    NSLog(@"take photo button pressed");
    
    [self.fastCamera takePicture];
}

- (void)flashButtonPressed
{
    NSLog(@"flash button pressed");
    
    FastttCameraFlashMode flashMode;
    NSString *flashTitle;
    switch (self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            flashTitle = @"Flash Off";
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            flashTitle = @"Flash On";
            break;
    }
    if ([self.fastCamera isFlashAvailableForCurrentDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle forState:UIControlStateNormal];
    }
}

- (void)torchButtonPressed
{
    NSLog(@"torch button pressed");
    
    FastttCameraTorchMode torchMode;
    NSString *torchTitle;
    switch (self.fastCamera.cameraTorchMode) {
        case FastttCameraTorchModeOn:
            torchMode = FastttCameraTorchModeOff;
            torchTitle = @"Torch Off";
            break;
        case FastttCameraTorchModeOff:
        default:
            torchMode = FastttCameraTorchModeOn;
            torchTitle = @"Torch On";
            break;
    }
    if ([self.fastCamera isTorchAvailableForCurrentDevice]) {
        [self.fastCamera setCameraTorchMode:torchMode];
        [self.torchButton setTitle:torchTitle forState:UIControlStateNormal];
    }
}

- (void)switchCameraButtonPressed
{
    NSLog(@"switch camera button pressed");
    
    FastttCameraDevice cameraDevice;
    switch (self.fastCamera.cameraDevice) {
        case FastttCameraDeviceFront:
            cameraDevice = FastttCameraDeviceRear;
            break;
        case FastttCameraDeviceRear:
        default:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    if ([FastttFilterCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
        if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
            [self.flashButton setTitle:@"Flash Off" forState:UIControlStateNormal];
        }
    }
}

- (void)switchFilterButtonPressed
{
    NSLog(@"switch filter button pressed");

    self.currentFilter = [self.currentFilter nextFilter];
    
    self.fastCamera.filterImage = self.currentFilter.filterImage;
    
    NSLog(@"%@", self.currentFilter.filterName);
}

#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    NSLog(@"A photo was taken");
    
    _confirmController = [ConfirmViewController new];
    self.confirmController.capturedImage = capturedImage;
    self.confirmController.delegate = self;
    
    UIView *flashView = [UIView new];
    flashView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    flashView.alpha = 0.f;
    [self.view addSubview:flashView];
    [flashView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.fastCamera.view);
    }];
    
    [UIView animateWithDuration:0.15f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         flashView.alpha = 1.f;
                     }
                     completion:^(BOOL finished) {
                         
                         [self fastttAddChildViewController:self.confirmController belowSubview:flashView];

                         [self.confirmController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                             make.edges.equalTo(self.view);
                         }];
                         
                         [UIView animateWithDuration:0.15f
                                               delay:0.05f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              flashView.alpha = 0.f;
                                          }
                                          completion:^(BOOL finished2) {
                                              [flashView removeFromSuperview];
                                          }];
                     }];
}

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    NSLog(@"Photos are ready");
    
    self.confirmController.imagesReady = YES;
}

#pragma mark - ConfirmControllerDelegate

- (void)dismissConfirmController:(ConfirmViewController *)controller
{
    [self fastttRemoveChildViewController:controller];
}

@end
