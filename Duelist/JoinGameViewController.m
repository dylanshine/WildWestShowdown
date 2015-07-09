//
//  JoinGameViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/9/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "JoinGameViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "GameKitHelper.h"

@interface JoinGameViewController () <MCBrowserViewControllerDelegate>
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@end

@implementation JoinGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    [self.mpcHelper setupSession];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.mpcHelper.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.mpcHelper.browser dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)joinGameButtonPressed:(id)sender {
    if (self.mpcHelper.session != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peerChangedStateWithNotification:)
                                                     name:@"WWS_DidChangeStateNotification"
                                                   object:nil];
        
        [self.mpcHelper setupBrowser];
        [[self.mpcHelper browser] setDelegate:self];
        
        [self presentViewController:self.mpcHelper.browser
                           animated:YES
                         completion:nil];
    }

}

- (void)peerChangedStateWithNotification:(NSNotification *)notification {
    // Get the state of the peer.
    int state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    // We care only for the Connected and the Not Connected states.
    // The Connecting state will be simply ignored.
    if (state != MCSessionStateConnecting) {
        // We'll just display all the connected peers (players) to the text view.
        NSString *allPlayers = @"Other players connected with:\n\n";
        
        for (int i = 0; i < self.mpcHelper.session.connectedPeers.count; i++) {
            NSString *displayName = [[self.mpcHelper.session.connectedPeers objectAtIndex:i] displayName];
            
            allPlayers = [allPlayers stringByAppendingString:@"\n"];
            allPlayers = [allPlayers stringByAppendingString:displayName];
        }
        
        NSLog(@"Players: %@", allPlayers);
    }
}

@end
