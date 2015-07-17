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

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerResultLabel;

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentResultLabel;

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLabels) name:@"StatsReceived" object:nil];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(backToMenu)];
    [self.view addGestureRecognizer:singleFingerTap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.game.opponentName) {
        [self setLabels];
    } else {
        [SVProgressHUD showWithStatus:@"Loading Duel Stats" maskType:SVProgressHUDMaskTypeBlack];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StatsReceived" object:nil];
}

-(void) setLabels {
    [SVProgressHUD dismiss];
    self.playerNameLabel.text = self.game.playerName;
    self.playerAccuracyLabel.text = self.game.playerAccuracy;
    self.playerResultLabel.text = self.game.playerResult;
    self.opponentNameLabel.text = self.game.opponentName;
    self.opponentAccuracyLabel.text = self.game.opponentAccuracy;
    self.opponentResultLabel.text = self.game.opponentResult;
}


-(void) backToMenu {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}
@end
