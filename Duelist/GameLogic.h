//
//  GameLogic.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameLogic : NSObject
@property (nonatomic) NSUInteger opponentLives;
@property (nonatomic) float shotsLanded;
@property (nonatomic) float shotsTaken;
@property (nonatomic) NSString *result;
@property (nonatomic) NSString *gameType;
-(instancetype)initWithLives:(NSUInteger)opponentLives StartTime:(NSUInteger)startTime GameType:(NSString *)gameType;
-(void)fireAtPlayer:(NSUInteger)player;
-(void)pullHammer;
-(void)reload;
-(NSString *)accuracyString;
-(void)startDuelAtRandomTimeWithCompletion:(void (^)())completion;
-(BOOL)opponentIsDead;
-(float)gameDurationTime;
@end
