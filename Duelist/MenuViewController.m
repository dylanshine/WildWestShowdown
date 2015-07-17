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
@property (nonatomic) SoundPlayer *musicPlayer;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.musicPlayer = [SoundPlayer sharedPlayer];
    [self.musicPlayer setupBackgroundMusicPlayer];
    [self.musicPlayer setupDuelingMusicPlayer];
    
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:@"userHasOnboarded"];
    if (!userHasOnboarded) {
        [self presentOnboardingViewController];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userHasOnboarded"];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.musicPlayer.duelPlayer stop];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    [[MultipeerConnectivityHelper sharedMCHelper].session disconnect];
    
    [self.musicPlayer playBackgroundMusic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)howToPlayButtonPushed:(id)sender {
    [self presentOnboardingViewController];
}

- (IBAction)enlargeButtonAnimation:(UIButton *)sender {
    [UIView animateWithDuration:0.1f animations:^{
        sender.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }];
}

- (IBAction)backToSizeButtonAnimation:(UIButton *)sender {
    [UIView animateWithDuration:0.1f animations:^{
        sender.transform = CGAffineTransformIdentity;
    }];
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
