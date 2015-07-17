//
//  GameLogic.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundPlayer.h"

@interface GameLogic : NSObject
@property (nonatomic) NSUInteger opponentLives;
@property (nonatomic) float shotsLanded;
@property (nonatomic) float shotsTaken;

@property (nonatomic) NSString *playerName;
@property (nonatomic) NSString *opponentName;
@property (nonatomic) NSString *playerResult;
@property (nonatomic) NSString *opponentResult;
@property (nonatomic) NSString *playerAccuracy;
@property (nonatomic) NSString *opponentAccuracy;

@property (nonatomic) NSString *gameType;
-(NSString *)accuracyString;
-(instancetype)initWithLives:(NSUInteger)opponentLives StartTime:(NSUInteger)startTime GameType:(NSString *)gameType PlayerName:(NSString *)name;
-(void)fireAtPlayer:(NSUInteger)player;
-(void)pullHammer;
-(void)reload;
-(void)startDuelAtRandomTimeWithCompletion:(void (^)())completion;
-(BOOL)opponentIsDead;
-(float)gameDurationTime;
- (void)flash;
-(void) statsMessage;
@end
