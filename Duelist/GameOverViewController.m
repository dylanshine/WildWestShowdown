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

@interface GameOverViewController()
@property (weak, nonatomic) IBOutlet UILabel *gameTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameOfPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    self.gameTimeLabel.text = [self formatGameTime];
    self.nameOfPlayerLabel.text = self.mpcHelper.peerID.displayName;
    self.accuracyLabel.text = self.accuracy;
    self.resultLabel.text = self.result;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(backToMenu)];
    [self.view addGestureRecognizer:singleFingerTap];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
