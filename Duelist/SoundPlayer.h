//
//  BackgroundMusicPlayer.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer : NSObject  <AVAudioPlayerDelegate>
+(instancetype)sharedPlayer;
@property (nonatomic) AVAudioPlayer *backgroundPlayer;
@property (nonatomic) AVAudioPlayer *duelPlayer;
-(void)setupBackgroundMusicPlayer;
-(void)setupDuelingMusicPlayer;
-(void)playBackgroundMusic;
-(void)playDuelingMusic;
-(void)stopBackgroundMusic;
-(void)stopDuelingMusic;
-(void)playSoundNamed:(NSString *)name Type:(NSString *)type;
@end
