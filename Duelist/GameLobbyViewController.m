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

- (IBAction)enlargeButtonAnimation:(UIButton *)sender {
    [UIView animateWithDuration:0.1f animations:^{
        sender.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }];
}

- (IBAction)backToSizeButtonAnimation:(UIButton *)sender {
    [UIView animateWithDuration:0.1f animations:^{
        sender.transform = CGAffineTransformIdentity;
    }];
}

@end
