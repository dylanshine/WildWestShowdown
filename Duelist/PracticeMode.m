//
//  PracticeMode.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/16/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "PracticeMode.h"

@interface PracticeMode()
@property (nonatomic) NSUInteger bullets;
@property (nonatomic) BOOL isCocked;
@property (nonatomic) BOOL isReloading;
@end

@implementation PracticeMode

-(instancetype)init {
    
    if (self = [super init]) {
        _bullets = 6;
        _isCocked = NO;
        _isReloading = NO;
    }
    
    return self;
    
}

-(void)fire {
    
    if (self.isCocked && self.bullets > 0) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [self flash];
        [[SoundPlayer sharedPlayer] playSoundNamed:@"fire1" Type:@"wav"];
        self.bullets--;
    } else if (self.isCocked) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"dryfire1" Type:@"wav"];
    }
    self.isCocked = NO;
}


-(void)pullHammer {
    if (!self.isCocked) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"pull1" Type:@"wav"];
        self.isCocked = YES;
    }
}

-(void)bulletsToSix {
    self.bullets = 6;
    self.isReloading = NO;
}


@end
