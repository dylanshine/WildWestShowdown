//
//  BackgroundMusicPlayer.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundMusicPlayer : NSObject
+(instancetype)sharedPlayer;
-(void)setupPlayer;
-(void)play;
-(void)stop;
@end
