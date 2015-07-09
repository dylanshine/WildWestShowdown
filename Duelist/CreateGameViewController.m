//
//  CreateGameViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/9/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "CreateGameViewController.h"
#import "MultipeerConnectivityHelper.h"

@interface CreateGameViewController ()
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@end

@implementation CreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mpcHelper advertiseSelf:NO];
    [self.mpcHelper.session disconnect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createGameButtonPressed:(id)sender {
    [self.mpcHelper setupSession];
    [self.mpcHelper advertiseSelf:YES];
}

@end
