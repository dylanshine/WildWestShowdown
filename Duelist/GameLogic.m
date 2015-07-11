//
//  GameLogic.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameLogic.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation GameLogic
-(instancetype)initWithNumberOfShots:(NSUInteger)shots {
    if (self = [super init]) {
        _opponentLives = shots;
        _bullets = 6;
        _isCocked = NO;
    }
    return self;
}

-(instancetype)init {
    self = [self initWithNumberOfShots:3];
    return self;
}

-(void)fire {
    if (self.isCocked && self.bullets > 0) {
        [self playSound:[[NSBundle mainBundle] pathForResource:@"fire1" ofType:@"wav"]];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        self.bullets--;
        [self opponentHit];
        
    } else if (self.isCocked) {
        [self playSound:[[NSBundle mainBundle] pathForResource:@"dryfire1" ofType:@"wav"]];
    }
    
    self.isCocked = NO;
}

-(void)pullHammer {
    if (!self.isCocked) {
        [self playSound:[[NSBundle mainBundle] pathForResource:@"pull1" ofType:@"wav"]];
        self.isCocked = YES;
    }
}

-(void)reload {
    if (self.bullets == 0) {
        [self playSound:[[NSBundle mainBundle] pathForResource:@"reload" ofType:@"mp3"]];
        self.bullets = 6;
    }
}

-(void)opponentHit {
    self.opponentLives--;
}

-(void)playSound:(NSString *)soundPath {
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
