//
//  GameLogic.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameLogic : NSObject
@property (nonatomic) BOOL isCocked;
@property (nonatomic) NSUInteger bullets;
@property (nonatomic) NSUInteger opponentLives;

-(instancetype)initWithNumberOfShots:(NSUInteger)shots;
-(void)fire;
-(void)reload;
-(void)pullHammer;
-(void)opponentHit;
@end
