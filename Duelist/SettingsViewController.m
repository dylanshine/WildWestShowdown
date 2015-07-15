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
@property (weak, nonatomic) IBOutlet UISwitch *musicSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sfxSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.musicSwitch.on = [[defaults objectForKey:@"music"] boolValue];
    self.sfxSwitch.on = [[defaults objectForKey:@"sfx"] boolValue];
}

- (IBAction)musicSwitchToggled:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        
        [defaults setBool:YES forKey:@"music"];
        [SoundPlayer sharedPlayer].player.volume = 1.0;
    } else {
        [defaults setBool:NO forKey:@"music"];
        [SoundPlayer sharedPlayer].player.volume = 0.0;
    }
    [defaults synchronize];
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

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
