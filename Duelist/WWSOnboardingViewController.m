//
//  WWSOnboardingViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/14/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "WWSOnboardingViewController.h"

@interface WWSOnboardingViewController () {
    dispatch_block_t _handler;
}

@end

@implementation WWSOnboardingViewController

- (instancetype)initWithCompletionHandler:(dispatch_block_t)completionHandler {
    self = [super initWithBackgroundImage:nil contents:nil];
    
    if (!self) {
        return nil;
    }
    
    _handler = completionHandler;
    
    self.fontName = @"HelveticaNeue-Thin";
    self.shouldMaskBackground = NO;
    self.shouldBlurBackground = NO;
    self.backgroundImage = [UIImage imageNamed:@"background"];
    
    __weak typeof(self) weakSelf = self;
    
    NSString *page1Title = @"Organize";
    NSString *page1Body = @"Everything has its place. We take care of the housekeeping for you.";
    NSString *page1ButtonTxt = @"Demo Async";
    OnboardingContentViewController *firstPage = [[OnboardingContentViewController alloc] initWithTitle:page1Title body:page1Body image:nil buttonText:page1ButtonTxt action:^{
        [weakSelf doSomethingWithCompletionHandler:^{
            [weakSelf moveNextPage];
        }];
    }];
    
    OnboardingContentViewController *secondPage = [[OnboardingContentViewController alloc] initWithTitle:@"Relax" body:@"Grab a nice beverage, sit back, and enjoy the experience." image:nil buttonText:nil action:nil];
    
    OnboardingContentViewController *thirdPage = [[OnboardingContentViewController alloc] initWithTitle:@"Rock Out" body:@"Import your favorite tunes and jam out while you browse." image:nil buttonText:nil action:nil];
    
    OnboardingContentViewController *fourthPage = [[OnboardingContentViewController alloc] initWithTitle:@"Experiment" body:@"Try new things, explore different combinations, and see what you come up with!" image:nil buttonText:@"Let's Get Started" action:completionHandler];
    
    self.viewControllers = @[firstPage, secondPage, thirdPage, fourthPage];
    
    return self;
}

- (void)doSomethingWithCompletionHandler:(dispatch_block_t)handler {
    handler();
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
