//
//  WWSOnboardingViewController.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/14/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "OnboardingViewController.h"

@interface WWSOnboardingViewController : OnboardingViewController
- (instancetype)initWithCompletionHandler:(dispatch_block_t)completionHandler;
@end
