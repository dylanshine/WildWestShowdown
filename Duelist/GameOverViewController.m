//
//  GameLobbyViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameOverViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "MenuViewController.h"
#import "SVProgressHud.h"

@interface GameOverViewController()
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;

@property (weak, nonatomic) IBOutlet UILabel *playerOneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerTwoNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *accuracyLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabelTwo;

@property (weak, nonatomic) IBOutlet UILabel *resultOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultTwoLabel;

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];

    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(backToMenu)];
    [self.view addGestureRecognizer:singleFingerTap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MessageReceived"
                                               object:nil];
    
    
    
    NSDictionary *dictionary = @{
                                 @"opponentNumber":self.playerNumber,
                                 @"opponentName":self.mpcHelper.peerID.displayName,
                                 @"opponentAccuracy":self.accuracy,
                                 @"opponentResult":self.result};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSError *error = nil;
    [self.mpcHelper.session sendData:data
                             toPeers:self.mpcHelper.session.connectedPeers
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [SVProgressHUD showWithStatus:@"Loading Duel Results" maskType:SVProgressHUDMaskTypeBlack];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageReceived" object:nil];
}


#pragma mark - NSNotifications
- (void)handleReceivedDataWithNotification:(NSNotification *)notification {
    NSDictionary *userInfoDict = [notification userInfo];
    NSData *receivedData = [userInfoDict objectForKey:@"data"];
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    NSLog(@"%@",dictionary);
    
    NSLog(@"%@", [dictionary[@"opponentNumber"] class]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([dictionary[@"opponentNumber"] isEqualToString:@"1"]) {
            self.playerOneNameLabel.text = dictionary[@"opponentName"];
            self.accuracyLabelOne.text = dictionary[@"opponentAccuracy"];
            self.resultOneLabel.text = dictionary[@"opponentResult"];
            self.playerTwoNameLabel.text = self.mpcHelper.peerID.displayName;
            self.accuracyLabelTwo.text = self.accuracy;
            self.resultTwoLabel.text = self.result;
        } else {
            self.playerTwoNameLabel.text = dictionary[@"opponentName"];
            self.accuracyLabelTwo.text = dictionary[@"opponentAccuracy"];
            self.resultTwoLabel.text = dictionary[@"opponentResult"];
            self.playerOneNameLabel.text = self.mpcHelper.peerID.displayName;
            self.accuracyLabelOne.text = self.accuracy;
            self.resultOneLabel.text = self.result;
        }
        [self.view updateConstraintsIfNeeded];
        [SVProgressHUD dismiss];
    });
}

-(NSString *)formatGameTime {
    NSString *time = [NSString stringWithFormat:@"Game Time: %.02f Seconds",self.gameTime];
    return time;
}


-(void) backToMenu {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
