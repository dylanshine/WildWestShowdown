//
//  BackgroundMusicPlayer.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "SoundPlayer.h"

@interface SoundPlayer()

@end


static const float kDuelMusicVolume = 0.1;
@implementation SoundPlayer

+(instancetype)sharedPlayer {
    static SoundPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [[self alloc] init];
    });
    
    return _sharedPlayer;
}

-(void)setupBackgroundMusicPlayer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tumbleTownShorten" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.backgroundPlayer.numberOfLoops = -1;
    self.backgroundPlayer.volume = [defaults floatForKey:@"music"];
}

-(void)setupDuelingMusicPlayer {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"duel" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.duelPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.duelPlayer.numberOfLoops = -1;
    self.duelPlayer.volume = kDuelMusicVolume;
}

-(void)playBackgroundMusic {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundPlayer play];
    });
}

-(void)playDuelingMusic {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"sfx"] boolValue]) {
        self.duelPlayer.volume = kDuelMusicVolume;
    } else {
        self.duelPlayer.volume = 0.0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.duelPlayer play];
    });
}

-(void)stopDuelingMusic {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.duelPlayer stop];
    });
}

-(void)stopBackgroundMusic {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doVolumeFadeBackgroundMusic];
    });
}

-(void)doVolumeFadeBackgroundMusic {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.backgroundPlayer.volume > 0.1) {
        self.backgroundPlayer.volume = self.backgroundPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFadeBackgroundMusic) withObject:nil afterDelay:0.2];
    } else {
        // Stop and get the sound ready for playing again
        [self.backgroundPlayer stop];
        self.backgroundPlayer.currentTime = 0;
        [self.backgroundPlayer prepareToPlay];
        self.backgroundPlayer.volume = [defaults floatForKey:@"music"];
    }
}

-(void)doVolumeFadeDuelingMusic {
    if (self.duelPlayer.volume > 0.1) {
        self.duelPlayer.volume = self.duelPlayer.volume - 0.05;
        [self performSelector:@selector(doVolumeFadeDuelingMusic) withObject:nil afterDelay:0.3];
    } else {
        // Stop and get the sound ready for playing again
        [self.duelPlayer stop];
        self.duelPlayer.currentTime = 0;
        [self.duelPlayer prepareToPlay];
        self.duelPlayer.volume = kDuelMusicVolume;
    }
}


-(void)playSoundNamed:(NSString *)name Type:(NSString *)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"sfx"]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}


@end
