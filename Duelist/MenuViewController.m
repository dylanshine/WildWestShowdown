//
//  ViewController.m
//  Duelist
//
//  Created by Dylan Shine on 7/8/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "MenuViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "WWSOnboardingViewController.h"
#import "SoundPlayer.h"
#import "SVProgressHUD.h"

@interface MenuViewController ()
@property (nonatomic) SoundPlayer *backgroundMusicPlayer;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundMusicPlayer = [SoundPlayer sharedPlayer];
    [self.backgroundMusicPlayer setupPlayer];
    
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:@"userHasOnboarded"];
    if (!userHasOnboarded) {
        [self presentOnboardingViewController];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userHasOnboarded"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    [[MultipeerConnectivityHelper sharedMCHelper].session disconnect];
    [self.backgroundMusicPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)howToPlayButtonPushed:(id)sender {
    [self presentOnboardingViewController];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)presentOnboardingViewController {
    [self presentViewController:[[WWSOnboardingViewController alloc] initWithCompletionHandler:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }] animated:YES completion:nil];
}

@end
