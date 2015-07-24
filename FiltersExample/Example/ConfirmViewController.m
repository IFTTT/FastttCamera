//
//  ConfirmViewController.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "ConfirmViewController.h"
#import <Masonry/Masonry.h>
#import <FastttCamera/FastttCapturedImage.h>
@import AssetsLibrary;
@import MessageUI;

@interface ConfirmViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation ConfirmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _previewImageView = [[UIImageView alloc] initWithImage:self.capturedImage.rotatedPreviewImage];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.previewImageView];
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _backButton = [UIButton new];
    [self.backButton addTarget:self
                        action:@selector(dismissConfirmController)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.backButton setTitle:@"Back"
                     forState:UIControlStateNormal];
    
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.left.equalTo(self.view).offset(20.f);
    }];
    
    _confirmButton = [UIButton new];
    [self.confirmButton addTarget:self
                           action:@selector(confirmButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.confirmButton setTitle:@"Use Photo"
                        forState:UIControlStateNormal];
    
    if (!self.capturedImage.isNormalized) {
        self.confirmButton.enabled = NO;
    }
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
    }];
}

- (void)setImagesReady:(BOOL)imagesReady
{
    _imagesReady = imagesReady;
    if (imagesReady) {
        self.confirmButton.enabled = YES;
    }
}

#pragma mark - Actions

- (void)dismissConfirmController
{
    [self.delegate dismissConfirmController:self];
}

- (void)confirmButtonPressed
{
    [self emailPhoto];
    
    [self savePhotoToCameraRoll];
}

- (void)savePhotoToCameraRoll
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[self.capturedImage.fullImage CGImage]
                              orientation:(ALAssetOrientation)[self.capturedImage.fullImage imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if (error) {
                                  NSLog(@"Error saving photo: %@", error.localizedDescription);
                              } else {
                                  NSLog(@"Saved photo to saved photos album.");
                              }
                          }];
}

- (void)emailPhoto
{
    NSString *emailTitle = @"FastttCamera Photo";
    NSString *messageBody = @"Check out my FastttCamera photo!";
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCompose = [MFMailComposeViewController new];
        mailCompose.mailComposeDelegate = self;
        [mailCompose setSubject:emailTitle];
        [mailCompose setMessageBody:messageBody isHTML:NO];
        [mailCompose addAttachmentData:UIImageJPEGRepresentation(self.capturedImage.scaledImage, 0.85f)
                              mimeType:@"image/jpeg"
                              fileName:@"fast_camera_photo.jpg"];
        
        [self presentViewController:mailCompose animated:YES completion:nil];
    } else {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Mail not configured"
                                                       message:@"Cannot share this photo without mail configured."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self dismissConfirmController];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissConfirmController];
}

@end
