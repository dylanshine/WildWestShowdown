//
//  GameLogic.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameLogic.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MultipeerConnectivityHelper.h"

@interface GameLogic()
@property (nonatomic) BOOL isCocked;
@property (nonatomic) NSUInteger bullets;
@property (nonatomic) NSUInteger startTime;
@end

@implementation GameLogic

-(instancetype)initWithLives:(NSUInteger)opponentLives StartTime:(NSUInteger)startTime{
    if (self = [super init]) {
        _bullets = 6;
        _isCocked = NO;
        _opponentLives = opponentLives;
        _startTime = startTime;
    }
    return self;
}

-(instancetype)init {
    self = [self initWithLives:3 StartTime:2];
    return self;
}

-(void)fireAtPlayer:(NSUInteger)player {
    if (self.isCocked && self.bullets > 0) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [self flash];
        [self playSound:[[NSBundle mainBundle] pathForResource:@"fire1" ofType:@"wav"]];
        self.bullets--;
        self.shotsTaken++;
        if (player > 0) {
            self.shotsLanded++;
            self.opponentLives--;
        }
    } else if (self.isCocked) {
        [self playSound:[[NSBundle mainBundle] pathForResource:@"dryfire1" ofType:@"wav"]];
    }
    
    if ([self opponentIsDead]) {
        [self playerKilledMessage];
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

-(BOOL)opponentIsDead {
    if (self.opponentLives == 0) {
        return YES;
    }
    return NO;
}

- (void)playerKilledMessage {
    self.result = @"Winner";
    NSData *data = [@"Killed" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [[[MultipeerConnectivityHelper sharedMCHelper] session] sendData:data
                             toPeers:[[[MultipeerConnectivityHelper sharedMCHelper] session] connectedPeers]
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)startDuelAtRandomTimeWithCompletion:(void (^)())completion {
    for (NSUInteger i = 0; i <= self.startTime; i++) {
        [self heartBeat];
    }
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self playSound:[[NSBundle mainBundle] pathForResource:@"draw" ofType:@"wav"]];

    completion();
}


#pragma mark - Sound and Flash

-(void)playSound:(NSString *)soundPath {
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)heartBeat {
    [self playSound:[[NSBundle mainBundle] pathForResource:@"heartbeat" ofType:@"wav"]];
    sleep(1);
}

- (void)flash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
    }
}

#pragma mark - Calculations

-(NSString *)accuracyString {
    if (self.shotsTaken == 0.0) {
        return @"0%";
    } else {
        NSString *accuracyString = [NSString stringWithFormat:@"Accuracy: %.02f%%", (self.shotsLanded / self.shotsTaken) * 100.0];
        return accuracyString;
    }
}

@end




