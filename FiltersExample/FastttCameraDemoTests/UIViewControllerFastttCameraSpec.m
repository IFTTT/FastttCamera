//
//  UIViewControllerFastttCameraSpec.m
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#import <FastttCamera/UIViewController+FastttCamera.h>

SpecBegin(UIViewControllerFastttCamera)

describe(@"UIViewControllerFastttCamera", ^{
    __block UIViewController *childViewController;
    __block UIViewController *parentViewController;
    
    describe(@"Adding a child view controller", ^{
        beforeEach(^{
            parentViewController = [UIViewController new];
            [parentViewController loadView];
            parentViewController.view.frame = CGRectMake(0.f, 0.f, 100.f, 200.f);
            [parentViewController beginAppearanceTransition:YES animated:NO];
            [parentViewController endAppearanceTransition];
            
            childViewController = [UIViewController new];
        });
        
        it(@"adds the child's view to the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController];
            childViewController.view.frame = parentViewController.view.bounds;
            expect([parentViewController.view.subviews containsObject:childViewController.view]).to.beTruthy();
        });
        
        it(@"adds the child as a child of the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController];
            expect([parentViewController.childViewControllers containsObject:childViewController]).to.beTruthy();
        });
        
        afterEach(^{
            parentViewController = nil;
            childViewController = nil;
        });
    });
    
    describe(@"Adding a child view controller below a subview", ^{
        __block UIView *siblingView;
        beforeEach(^{
            parentViewController = [UIViewController new];
            [parentViewController loadView];
            parentViewController.view.frame = CGRectMake(0.f, 0.f, 100.f, 200.f);
            [parentViewController beginAppearanceTransition:YES animated:NO];
            [parentViewController endAppearanceTransition];
            
            childViewController = [UIViewController new];
            
            siblingView = [UIView new];
            
            [parentViewController.view addSubview:siblingView];
        });
        
        it(@"adds the child's view to the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController belowSubview:siblingView];
            childViewController.view.frame = parentViewController.view.bounds;
            expect([parentViewController.view.subviews containsObject:childViewController.view]).to.beTruthy();
        });
        
        it(@"adds the child's view to the parent view controller below the sibling view", ^{
            [parentViewController fastttAddChildViewController:childViewController belowSubview:siblingView];
            childViewController.view.frame = parentViewController.view.bounds;
            expect([parentViewController.view.subviews indexOfObject:siblingView]).to.beGreaterThan([parentViewController.view.subviews indexOfObject:childViewController.view]);
        });
        
        it(@"adds the child as a child of the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController belowSubview:siblingView];
            expect([parentViewController.childViewControllers containsObject:childViewController]).to.beTruthy();
        });
        
        afterEach(^{
            parentViewController = nil;
            childViewController = nil;
        });
    });
    
    describe(@"Removing a child view controller", ^{
        beforeEach(^{
            parentViewController = [UIViewController new];
            [parentViewController loadView];
            parentViewController.view.frame = CGRectMake(0.f, 0.f, 100.f, 200.f);
            [parentViewController beginAppearanceTransition:YES animated:NO];
            [parentViewController endAppearanceTransition];
            
            childViewController = [UIViewController new];
        });
        
        it(@"removes the child's view from the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController];
            [parentViewController fastttRemoveChildViewController:childViewController];
            expect([parentViewController.view.subviews containsObject:childViewController.view]).to.beFalsy();
        });
        
        it(@"removes the child as a child of the parent view controller", ^{
            [parentViewController fastttAddChildViewController:childViewController];
            [parentViewController fastttRemoveChildViewController:childViewController];
            expect([parentViewController.childViewControllers containsObject:childViewController]).to.beFalsy();
        });
        
        afterEach(^{
            parentViewController = nil;
            childViewController = nil;
        });
    });
});

SpecEnd
