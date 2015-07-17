//
//  SettingsViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundPlayer.h"

@interface SettingsViewController()
@property (nonatomic) SoundPlayer *soundPlayer;
@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property (weak, nonatomic) IBOutlet UISwitch *sfxSwitch;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.soundPlayer = [SoundPlayer sharedPlayer];
    [self setupMusicSlider];
    self.sfxSwitch.on = [defaults boolForKey:@"sfx"];
    self.flashSwitch.on = [defaults boolForKey:@"flash"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupMusicSlider];
}

- (IBAction)sfxSwitchToggled:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [defaults setBool:YES forKey:@"sfx"];
    } else {
        [defaults setBool:NO forKey:@"sfx"];
    }
    [defaults synchronize];

}

- (IBAction)flashSwitchToggled:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [defaults setBool:YES forKey:@"flash"];
    } else {
        [defaults setBool:NO forKey:@"flash"];
    }
    [defaults synchronize];
}

- (IBAction)musicSlider:(UISlider *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.soundPlayer.backgroundPlayer.volume = sender.value;
    [defaults setFloat:sender.value forKey:@"music"];
    [defaults synchronize];
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

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)setupMusicSlider {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.musicSlider.value = [defaults floatForKey:@"music"];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
