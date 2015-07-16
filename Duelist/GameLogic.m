//
//  GameLogic.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameLogic.h"
#import "MultipeerConnectivityHelper.h"

@interface GameLogic()
@property (nonatomic) BOOL isCocked;
@property (nonatomic) NSUInteger bullets;
@property (nonatomic) NSUInteger startTime;
@property (nonatomic) NSDate *gameBegin;
@end

@implementation GameLogic

-(instancetype)initWithLives:(NSUInteger)opponentLives StartTime:(NSUInteger)startTime GameType:(NSString *)gameType {
    if (self = [super init]) {
        _bullets = 6;
        _isCocked = NO;
        _opponentLives = opponentLives;
        _startTime = startTime;
        _gameType = gameType;
    }
    return self;
}


-(instancetype)init {
    self = [self initWithLives:3 StartTime:2 GameType:@"Standoff"];
    return self;
}

-(void)fireAtPlayer:(NSUInteger)player {
    if (self.isCocked && self.bullets > 0) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [self flash];
        [[SoundPlayer sharedPlayer] playSoundNamed:@"fire1" Type:@"wav"];
        self.bullets--;
        self.shotsTaken++;
        if (player > 0) {
            self.shotsLanded++;
            self.opponentLives--;
        }
    } else if (self.isCocked) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"dryfire1" Type:@"wav"];
    }
    
    if ([self opponentIsDead]) {
        [self playerKilledMessage];
    }
    self.isCocked = NO;
}

-(void)pullHammer {
    if (!self.isCocked) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"pull1" Type:@"wav"];
        self.isCocked = YES;
    }
}

-(void)reload {
    if (self.bullets == 0) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"reload" Type:@"mp3"];
        [self performSelector:@selector(bulletsToSix) withObject:nil afterDelay:3.7];
    }
}

-(void)bulletsToSix {
    self.bullets = 6;
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
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    for(NSUInteger i = 0; i < self.startTime; i++) {
        [queue addOperationWithBlock:^{
            [self playGameTypeSound];
            if ([self.gameType isEqualToString:@"Standoff"]) {
                [NSThread sleepForTimeInterval:1];
            } else {
                [NSThread sleepForTimeInterval:2];
            }
            
        }];
    }
    
    [queue addOperationWithBlock:^{
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [[SoundPlayer sharedPlayer] playSoundNamed:@"draw" Type:@"wav"];
        self.gameBegin = [NSDate date];
        
        dispatch_async(dispatch_get_main_queue(), completion);
    }];
}

#pragma mark - Sound and Flash

-(void)playGameTypeSound {
    if ([self.gameType isEqualToString:@"Standoff"]) {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"heartbeat" Type:@"wav"];
    } else {
        [[SoundPlayer sharedPlayer] playSoundNamed:@"boots" Type:@"wav"];
    }
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

-(float)gameDurationTime {
    return [self.gameBegin timeIntervalSinceNow] * -1.0;
}

@end





