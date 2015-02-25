![FastttCamera Logo](https://raw.githubusercontent.com/IFTTT/FastttCamera/master/Docs/fastttcamera-logo.jpg)

[![Build Status](https://travis-ci.org/IFTTT/FastttCamera.svg?branch=master)](https://travis-ci.org/IFTTT/FastttCamera) [![Coverage Status](https://coveralls.io/repos/IFTTT/FastttCamera/badge.svg)](https://coveralls.io/r/IFTTT/FastttCamera)

`FastttCamera` is a wrapper around `AVFoundation` that allows you to build your own powerful custom camera app without all the headaches of using `AVFoundation` directly.

![FastttCamera](https://raw.githubusercontent.com/IFTTT/FastttCamera/master/Docs/fastttcamera-portrait.gif)

`FastttCamera` powers the camera in the new [Do Camera](https://ifttt.com/products/do/camera) app for iOS from [IFTTT](https://ifttt.com/wtf).

[![App Store](https://raw.githubusercontent.com/IFTTT/FastttCamera/master/Docs/Download_on_the_App_Store_Badge.svg)](https://itunes.apple.com/us/app/do-camera-by-ifttt/id905998167)

#### Major headaches that `FastttCamera` automatically handles for you:

##### `AVFoundation` Headaches
* Configuring and managing an `AVCaptureSession`.
* Displaying the `AVCaptureVideoPreviewLayer` in a sane way relative to your camera's view.
* Configuring the state of the `AVCaptureDevice` and safely changing its properties as needed, such as setting the flash mode and switching between the front and back cameras.
* Adjusting the camera's focus and exposure in response to tap gestures.
* Capturing a full-resolution photo from the `AVCaptureStillImageOutput`.

##### Device Orientation Headaches
* Changing the `AVCaptureConnection`'s orientation appropriately when the device is rotated.
* Detecting the actual orientation of the device when a photo is taken _even if orientation lock is on_ by using the accelerometer, so that landscape photos are always rotated correctly.
* _(Optional)_ Returning a preview version of the image rotated to match the orientation of what was displayed by the camera preview, even if the user has orientation lock on.
* _(Optional)_ Asynchronously returning an orientation-normalized version of the captured image rotated so that the image orientation is always UIImageOrientationUp, useful for reliably displaying images correctly on web services that might not respect EXIF image orientation tags.

##### Image Processing Headaches
* _(Optional)_ Cropping the captured image to the visible bounds of your camera's view.
* _(Optional)_ Returning a scaled-down version of the captured image.
* Processing high-resolution images quickly and efficiently without overloading the device's memory or creating app-terminating memory leaks.


`FastttCamera` does many operations faster than `UIImagePickerController`'s camera, such as switching between the front and back camera, and provides you the captured photos in the format you need, returning a cropped full-resolution image as quickly as `UIImagePickerController` returns the raw captured image on most devices. It allows all of the flexibility of `AVFoundation` without the need to reinvent the wheel, so you can focus on making a beautiful custom UI and doing awesome things with photos.

While both `UIImagePickerController`'s camera and `AVFoundation` give you raw images that may not even be cropped the same as the live camera preview your users see, `FastttCamera` gives you a full-resolution image cropped to the same aspect ratio as your live preview's viewport as well as a preview image scaled to the pixel dimesions of that viewport, whether you want a square camera, a camera sized to the full screen, or something else.

`FastttCamera` also is smart at handling image orientation, a notoriously tricky part of images from both `AVFoundation` and `UIImagePickerController`. The orientation of the camera is magically detected correctly even if the user is taking landscape photos with orientation lock turned on, because `FastttCamera` checks the accelerometer to determine the real device orientation.

## Installation

FastttCamera is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```
pod "FastttCamera"
```

## Example Project

To run the example project, clone the repo, and run `pod install` from the `Example` directory.

## Usage

Add an instance of `FastttCamera` as a child of your view controller. Adjust the size and layout of `FastttCamera`'s view however you'd like, and `FastttCamera` will automatically adjust the camera's preview window and crop captured images to match what is visible within its bounds.

```objc
#import "ExampleViewController.h"
#import <FastttCamera.h>

@interface ExampleViewController () <FastttCameraDelegate>
@property (nonatomic, strong) FastttCamera *fastCamera;
@end

@implementation ExampleViewController

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
    
    self.fastCamera.view.frame = self.view.frame;  
}
```
Switch between the front and back cameras.

```objc
if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
	[self.fastCamera setCameraDevice:cameraDevice];
}
```
Set the camera's flash mode.

```objc
if ([FastttCamera isFlashAvailableForCameraDevice:self.fastCamera.cameraDevice]) {
	[self.fastCamera setCameraFlashMode:flashMode];
}
```
Tell `FastttCamera` to take a photo.

```objc
[self.fastCamera takePicture];
```
Use `FastttCamera`'s delegate methods to retrieve the captured image object after taking a photo.

```objc
#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(FastttCamera *)cameraController
 didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
	/**
 	*  Here, capturedImage.fullImage contains the full-resolution captured
 	*  image, while capturedImage.rotatedPreviewImage contains the full-resolution
 	*  image with its rotation adjusted to match the orientation in which the
 	*  image was captured.
 	*/
}

- (void)cameraController:(FastttCamera *)cameraController
 didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage
{
	/**
 	*  Here, capturedImage.scaledImage contains the scaled-down version
 	*  of the image.
 	*/
}

- (void)cameraController:(FastttCamera *)cameraController
 didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
	/**
 	*  Here, capturedImage.fullImage and capturedImage.scaledImage have
 	*  been rotated so that they have image orientations equal to
 	*  UIImageOrientationUp. These images are ready for saving and uploading,
 	*  as they should be rendered more consistently across different web
 	*  services than images with non-standard orientations.
 	*/
}
```

## Author

[Laura Skelton](https://github.com/lauraskelton)

## License

FastttCamera is available under the MIT license. See the LICENSE file for more info.

Copyright 2015 IFTTT Inc.
