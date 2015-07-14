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

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;


@end

@implementation SettingsViewController
- (IBAction)musicSwitchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        [SoundPlayer sharedPlayer].player.volume = 1.0;
    } else {
        [SoundPlayer sharedPlayer].player.volume = 0.0;
    }
}

@end
