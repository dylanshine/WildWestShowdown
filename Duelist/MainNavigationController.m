//
//  WWSViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/8/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "MainNavigationController.h"
#import "MultipeerConnectivityHelper.h"
#import "GameKitHelper.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    if ([GameKitHelper sharedGameKitHelper].isEnabled) {
        [[MultipeerConnectivityHelper sharedMCHelper] setupPeerWithDisplayName:[GKLocalPlayer localPlayer].displayName];
    } else {
        [[MultipeerConnectivityHelper sharedMCHelper] setupPeerWithDisplayName:[UIDevice currentDevice].name];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PresentAuthenticationViewController object:nil];
}

- (void)showAuthenticationViewController {
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self.topViewController presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
