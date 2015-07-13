//
//  BackgroundMusicPlayer.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "BackgroundMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface BackgroundMusicPlayer() <AVAudioPlayerDelegate>
@property (nonatomic) AVAudioPlayer *player;
@end

@implementation BackgroundMusicPlayer

+(instancetype)sharedPlayer {
    static BackgroundMusicPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [[self alloc] init];
    });
    
    return _sharedPlayer;
}

-(void)setupPlayer {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"TumbleweedTown" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.player.numberOfLoops = -1;
}

-(void)play {
    [self.player play];
}

-(void)stop {
    [self.player stop];
}

@end
