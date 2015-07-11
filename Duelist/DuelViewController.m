//
//  DuelViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "DuelViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "GameLogic.h"

@interface DuelViewController()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *fireButton;
@property (weak, nonatomic) IBOutlet UIButton *pullHammerButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@property (nonatomic) GameLogic *game;
@property (nonatomic) BOOL playerReady;
@property (nonatomic) BOOL opponentReady;
@end

@implementation DuelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MessageReceived"
                                               object:nil];
    
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification {
    NSDictionary *userInfoDict = [notification userInfo];
    NSData *receivedData = [userInfoDict objectForKey:@"data"];
    NSString *message = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if ([message isEqualToString:@"Ready"]) {
        self.opponentReady = YES;
    } else if ([message isEqualToString:@"Killed"]) {
        NSLog(@"Killed!");
        self.statusLabel.text = @"Dead!";
    }
}

- (void)playerKilledMessage {
    NSData *data = [@"Killed" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [self.mpcHelper.session sendData:data
                             toPeers:self.mpcHelper.session.connectedPeers
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)setupGame {
    self.fireButton.hidden = NO;
    self.pullHammerButton.hidden = NO;
    self.reloadButton.hidden = NO;
    self.game = [[GameLogic alloc] initWithNumberOfShots:[self.numberOfShots integerValue]];
    self.statusLabel.text = @"Draw!";
}

- (void)setPlayerReady:(BOOL)playerReady {
    _playerReady = playerReady;
    self.readyButton.hidden = YES;
    self.statusLabel.text = @"Waiting for opponent...";
    
    if (_playerReady && self.opponentReady) {
        [self setupGame];
    }
}

- (void)setOpponentReady:(BOOL)opponentReady {
    _opponentReady = opponentReady;
    
    if (_opponentReady && self.playerReady) {
        [self setupGame];
    }
}

- (IBAction)readyButtonPressed:(id)sender {
    self.playerReady = YES;
    
    NSData *data = [@"Ready" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [self.mpcHelper.session sendData:data
                             toPeers:self.mpcHelper.session.connectedPeers
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (IBAction)fireButtonPressed:(id)sender {
    [self.game fire];
    if (self.game.opponentLives == 0) {
        [self playerKilledMessage];
    }
    
}

- (IBAction)pullHammerButtonPressed:(id)sender {
    [self.game pullHammer];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self.game reload];
}

@end
