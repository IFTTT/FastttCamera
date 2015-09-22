//
//  FastttFocus.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import "FastttFocus.h"

CGFloat const kFocusSquareSize = 50.f;

@interface FastttFocus ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) BOOL isFocusing;

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
    
    return fastFocus;
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

- (void)showFocusViewAtPoint:(CGPoint)location
{
    if (self.isFocusing) {
        return;
    }
    
    self.isFocusing = YES;
    
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
}

- (void)_handleTapFocus:(UITapGestureRecognizer *)recognizer
{
    if (self.isFocusing) {
        return;
    }
    
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

@end
