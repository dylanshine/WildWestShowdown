//
//  GameLobbyViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/15/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "GameLobbyViewController.h"

@interface GameLobbyViewController ()

@end

@implementation GameLobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
