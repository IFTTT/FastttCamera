//
//  ConfirmViewController.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import UIKit;
@class FastttCapturedImage;
@protocol ConfirmControllerDelegate;

@interface ConfirmViewController : UIViewController

@property (nonatomic, weak) id <ConfirmControllerDelegate> delegate;
@property (nonatomic, strong) FastttCapturedImage *capturedImage;
@property (nonatomic, assign) BOOL imagesReady;

@end

@protocol ConfirmControllerDelegate <NSObject>

- (void)dismissConfirmController:(ConfirmViewController *)controller;

@end
