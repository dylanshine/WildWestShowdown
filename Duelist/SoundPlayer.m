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

@implementation SoundPlayer

+(instancetype)sharedPlayer {
    static SoundPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [[self alloc] init];
    });
    
    return _sharedPlayer;
}

-(void)setupPlayer {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"tumbleTownShorten" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.player.numberOfLoops = -1;
}

-(void)play {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"music"] boolValue]) {
        self.player.volume = 1.0;
    } else {
        self.player.volume = 0.0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

-(void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doVolumeFade];
    });
}

-(void)doVolumeFade
{
    if (self.player.volume > 0.1) {
        self.player.volume = self.player.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.2];
    } else {
        // Stop and get the sound ready for playing again
        [self.player stop];
        self.player.currentTime = 0;
        [self.player prepareToPlay];
        self.player.volume = 1.0;
    }
}

-(void)playSoundNamed:(NSString *)name Type:(NSString *)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"sfx"] boolValue]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}


@end
