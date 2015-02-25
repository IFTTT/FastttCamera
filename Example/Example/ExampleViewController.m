//
//  ExampleViewController.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "ExampleViewController.h"
#import <FastttCamera.h>
#import <Masonry.h>
#import "ConfirmViewController.h"

@interface ExampleViewController () <FastttCameraDelegate, ConfirmControllerDelegate>

@property (nonatomic, strong) FastttCamera *fastCamera;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) ConfirmViewController *confirmController;

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
        
    _fastCamera = [FastttCamera new];
    self.fastCamera.delegate = self;
    
    [self.fastCamera willMoveToParentViewController:self];
    [self.fastCamera beginAppearanceTransition:YES animated:NO];
    [self addChildViewController:self.fastCamera];
    [self.view addSubview:self.fastCamera.view];
    [self.fastCamera didMoveToParentViewController:self];
    [self.fastCamera endAppearanceTransition];
    
    [self.fastCamera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.and.width.lessThanOrEqualTo(self.view.mas_width).with.priorityHigh();
        make.height.and.width.lessThanOrEqualTo(self.view.mas_height).with.priorityHigh();
        make.height.and.width.equalTo(self.view.mas_width).with.priorityLow();
        make.height.and.width.equalTo(self.view.mas_height).with.priorityLow();
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
    }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.confirmController = nil;
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
    if ([FastttCamera isFlashAvailableForCameraDevice:self.fastCamera.cameraDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle forState:UIControlStateNormal];
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
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
    }
}

#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(FastttCamera *)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
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
        make.edges.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:0.15f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         flashView.alpha = 1.f;
                     }
                     completion:^(BOOL finished) {
                         
                         [self.confirmController willMoveToParentViewController:self];
                         [self.confirmController beginAppearanceTransition:YES animated:NO];
                         [self addChildViewController:self.confirmController];
                         [self.view insertSubview:self.confirmController.view belowSubview:flashView];
                         [self.confirmController didMoveToParentViewController:self];
                         [self.confirmController endAppearanceTransition];
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

- (void)cameraController:(FastttCamera *)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    NSLog(@"Photos are ready");
    
    self.confirmController.imagesReady = YES;
}

#pragma mark - ConfirmControllerDelegate

- (void)dismissConfirmController:(ConfirmViewController *)controller
{
    [controller willMoveToParentViewController:nil];
    [controller beginAppearanceTransition:NO animated:NO];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    [controller didMoveToParentViewController:nil];
    [controller endAppearanceTransition];
}

@end
