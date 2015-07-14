//
//  ViewController.m
//  Duelist
//
//  Created by Dylan Shine on 7/8/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "MenuViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "SoundPlayer.h"

@interface MenuViewController ()
@property (nonatomic) SoundPlayer *backgroundMusicPlayer;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundMusicPlayer = [SoundPlayer sharedPlayer];
    [self.backgroundMusicPlayer setupPlayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.backgroundMusicPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
