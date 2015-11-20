//
//  FastttFocus.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttFocus.h"
#import "AVCaptureDevice+FastttCamera.h"

CGFloat const kFocusSquareSize = 50.f;
NSString * const kFocusKVOKey = @"adjustingFocus";
void * FocusKVOContext = &FocusKVOContext;
NSString * const kExposureKVOKey = @"adjustingExposure";
void * ExposureKVOContext = &ExposureKVOContext;
NSString * const kWhiteBalanceKVOKey = @"adjustingWhiteBalance";
void * WhiteBalanceKVOContext = &WhiteBalanceKVOContext;

@interface FastttFocus ()
{
    BOOL _animating;
}

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (atomic, assign) BOOL focusing;

//KVO
@property (nonatomic, assign) BOOL currentlyFocusing;
@property (nonatomic, assign) BOOL currentlyExposing;
@property (nonatomic, assign) BOOL currentlyBalancing;
@property (atomic, weak) NSTimer *focusTimer;

@end

@implementation FastttFocus

+ (instancetype)fastttFocusWithView:(UIView *)view gestureDelegate:(id <UIGestureRecognizerDelegate>)gestureDelegate
{
    if (!view) {
        return nil;
    }
    
    FastttFocus *fastFocus = [[self alloc] init];
    
    fastFocus.view = view;
    
    fastFocus.gestureDelegate = gestureDelegate;
    
    fastFocus.detectsTaps = YES;
    
    fastFocus.focusing = NO;
    
    return fastFocus;
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentlyFocusing = NO;
        _currentlyExposing = NO;
        _currentlyBalancing = NO;
        _animating = NO;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [self _teardownTapFocusRecognizer];
}

- (void)setDetectsTaps:(BOOL)detectsTaps
{
    if (_detectsTaps != detectsTaps) {
        _detectsTaps = detectsTaps;
        if (_detectsTaps) {
            [self _setupTapFocusRecognizer];
        } else {
            [self _teardownTapFocusRecognizer];
        }
    }
}

- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice
{
    if (_currentDevice != currentDevice) {
        if (self.detectsTaps && [self.delegate respondsToSelector:@selector(hasFinishedAdjustingFocusAndExposure)]) {
            if (_currentDevice) {
                [_currentDevice removeObserver:self
                                    forKeyPath:kFocusKVOKey
                                       context:&FocusKVOContext];
                [_currentDevice removeObserver:self
                                    forKeyPath:kExposureKVOKey
                                       context:&ExposureKVOContext];
                [_currentDevice removeObserver:self
                                    forKeyPath:kWhiteBalanceKVOKey
                                       context:&WhiteBalanceKVOContext];
            }
            if (currentDevice) {
                [currentDevice addObserver:self
                                forKeyPath:kFocusKVOKey
                                   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                   context:&FocusKVOContext];
                [currentDevice addObserver:self
                                forKeyPath:kExposureKVOKey
                                   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                   context:&ExposureKVOContext];
                [currentDevice addObserver:self
                                forKeyPath:kWhiteBalanceKVOKey
                                   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                   context:&WhiteBalanceKVOContext];
            }
        }
    }
    _currentDevice = currentDevice;
}

- (void)showFocusViewAtPoint:(CGPoint)location
{
    if (_animating) {
        return;
    }
    
    _animating = YES;
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
                                              _animating = NO;
                                          }];
                     }];
}

#pragma mark - Tap to Focus

- (void)_setupTapFocusRecognizer
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapFocus:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    self.tapGestureRecognizer.delegate = self.gestureDelegate;
}

- (void)_teardownTapFocusRecognizer
{
    if ([self.view.gestureRecognizers containsObject:self.tapGestureRecognizer]) {
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    self.tapGestureRecognizer = nil;
    
    self.currentDevice = nil;
    
    [self.focusTimer invalidate];
}

- (void)_handleTapFocus:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if ([self.delegate handleTapFocusAtPoint:location]) {
        [self showFocusViewAtPoint:location];
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if (context == FocusKVOContext) {
        
        if ([change[NSKeyValueChangeOldKey] boolValue] == NO && [change[NSKeyValueChangeNewKey] boolValue] == YES) {
            self.currentlyFocusing = YES;
            [self _checkOverallFocusStatus];
        } else if ([change[NSKeyValueChangeOldKey] boolValue] == YES && [change[NSKeyValueChangeNewKey] boolValue] == NO) {
            self.currentlyFocusing = NO;
            [self _checkOverallFocusStatus];
        }
        
        return;
    }
    
    if (context == ExposureKVOContext) {
        
        if ([change[NSKeyValueChangeOldKey] boolValue] == NO && [change[NSKeyValueChangeNewKey] boolValue] == YES) {
            self.currentlyExposing = YES;
            [self _checkOverallFocusStatus];
        } else if ([change[NSKeyValueChangeOldKey] boolValue] == YES && [change[NSKeyValueChangeNewKey] boolValue] == NO) {
            self.currentlyExposing = NO;
            [self _checkOverallFocusStatus];
        }
        
        return;
    }
    
    if (context == WhiteBalanceKVOContext) {
        
        if ([change[NSKeyValueChangeOldKey] boolValue] == NO && [change[NSKeyValueChangeNewKey] boolValue] == YES) {
            self.currentlyBalancing = YES;
            [self _checkOverallFocusStatus];
        } else if ([change[NSKeyValueChangeOldKey] boolValue] == YES && [change[NSKeyValueChangeNewKey] boolValue] == NO) {
            self.currentlyBalancing = NO;
            [self _checkOverallFocusStatus];
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

- (void)_checkOverallFocusStatus
{
    /*
        Focus, exposure and balance operations happen sequentially. So what we get here is:
        
        startFocus (self.focusing == YES)
        endFocus (self.focusing == NO)
        startExposure (self.focusing == YES)
        endExposure (self.focusing == NO)
        startBalance (self.focusing == YES)
        endBalance (self.focusing == NO)
     
        However, we may not have yet finished processing the last call to _checkOverallFocusStatus 
        by the time a new call is made. So we synchronise everything to make sure we don't overprocess.
     
        Additionally, the behaviour we want is this:
     
        startFocus (self.focusing == YES)
        endFocus
        startExposure
        endExposure
        startBalance
        endBalance (self.focusing == NO)
     
        To achieve this, we defer processing the overall status by 0.4 sec when any of the three possible
        adjustments (focus, exposure and balance) report having finished.
    */
    @synchronized(self) {
        BOOL focusing = self.currentlyFocusing || self.currentlyExposing || self.currentlyBalancing;
        
        if (focusing != self.isFocusing) {
            self.focusing = focusing;
            
            if (self.detectsTaps) {
                
                if (!focusing) {
                    if (self.focusTimer) {
                        /*
                         According to Apple's docs, changing a timer's fire date is an expensive operation,
                         but less so than scheduling a new one.
                         @see https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/index.html#//apple_ref/occ/instp/NSTimer/fireDate
                         */
                        self.focusTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:.4];
                    } else {
                        self.focusTimer = [NSTimer scheduledTimerWithTimeInterval:.4
                                                                           target:self
                                                                         selector:@selector(_deferredOverallFocusStatusCheck:)
                                                                         userInfo:nil
                                                                          repeats:NO];
                    }
                } else {
                    [self.focusTimer invalidate];
                }
                
            }
        }
    }
}

- (void)_deferredOverallFocusStatusCheck:(NSTimer *)sender
{
    [sender invalidate];
    
    if (!self.focusing) {
        //Should notify the delegate
        /*
            We're always on the main thread, so no need to dispatch
            Also, we will only hit this point if the delegate implements `hasFinishedAdjustingFocusAndExposure`
         */
        [self.delegate hasFinishedAdjustingFocusAndExposure];
    }
}

@end
