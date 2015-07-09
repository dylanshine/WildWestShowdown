//
//  GameKitHelper.m
//  Duelist
//
//  Created by Dylan Shine on 7/8/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameKitHelper.h"



NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
@interface GameKitHelper()


@property (nonatomic) BOOL enableGameCenter;

@end

@implementation GameKitHelper

+ (instancetype)sharedGameKitHelper {
    static GameKitHelper *_sharedGameKitHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGameKitHelper = [[self alloc] init];
    });
    
    return _sharedGameKitHelper;
}


- (instancetype)init {
    if (self = [super init]) {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLastError:error];
        
        if (viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            self.enableGameCenter = YES;
        } else {
            self.enableGameCenter = NO;
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController {
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
        
    }

}

- (void)setLastError:(NSError *)error {
    _lastError  = [error copy];
    NSLog(@"GameKitHelper Error: %@", [[_lastError userInfo] description]);
}

@end
