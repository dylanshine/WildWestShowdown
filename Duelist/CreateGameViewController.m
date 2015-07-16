//
//  CreateGameViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "CreateGameViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "SVProgressHUD.h"
#import "DuelViewController.h"
#import "SoundPlayer.h"

@interface CreateGameViewController() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@property (nonatomic) NSArray *gameTypes;
@property (nonatomic) NSArray *numberOfShots;
@property (nonatomic) NSString *randomStart;
@end

@implementation CreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    [self.mpcHelper setupSession];
    
    self.gameTypes = @[@"Standoff", @"Paces"];
    self.numberOfShots = @[@"1", @"3", @"6"];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
}

- (void)handleDisconnection:(NSNotification *)notification {
    if (self.isBeingPresented) {
        [SVProgressHUD showErrorWithStatus:@"Opponent Disconnected"];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupDuel)
                                                 name:@"PeerConnected"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDisconnection:)
                                                 name:@"PeerDisconnected"
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeerConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeerDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    [SVProgressHUD dismiss];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.gameTypes count];
    } else {
        return [self.numberOfShots count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.gameTypes objectAtIndex:row];
    }
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *tView = (UILabel*)view;
    
    if (!tView) {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"CoffeeTinInitials" size:30]];
        tView.numberOfLines=3;
    }
    
    if (component == 0) {
        tView.text=[self.gameTypes objectAtIndex:row];
    } else {
        NSString *bulletString = [NSString stringWithFormat:@"bullet%lu.png",row];
        UIImageView *bulletImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bulletString]];
        return bulletImageView;
    }
    return tView;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return 225;
    }
    return 60;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[SoundPlayer sharedPlayer] playSoundNamed:@"revolverClick" Type:@"mp3"];
}

- (IBAction)createButtonPressed:(id)sender {
    NSInteger row1 = [self.pickerView selectedRowInComponent:0];
    NSInteger row2 = [self.pickerView selectedRowInComponent:1];
    self.randomStart = [self randomStartTimeByGameType:self.gameTypes[row1]];
    NSDictionary *discoveryInfo = @{@"gameType":self.gameTypes[row1],
                                    @"shots":self.numberOfShots[row2],
                                    @"startTime": self.randomStart};
    [self.mpcHelper advertiseSelf:YES WithDiscoveryInfo:discoveryInfo];
    [SVProgressHUD showWithStatus:@"Waiting For Opponent ... \n Tap To Cancel"maskType:SVProgressHUDMaskTypeBlack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCreateGame:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];

}

- (void)cancelCreateGame:(NSNotification *)notification {
    [self.mpcHelper advertiseSelf:NO WithDiscoveryInfo:nil];
    [SVProgressHUD dismiss];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createGameSegue"]) {
        DuelViewController *destination = segue.destinationViewController;
        destination.gameType = self.gameTypes[[self.pickerView selectedRowInComponent:0]];
        destination.numberOfShots = self.numberOfShots[[self.pickerView selectedRowInComponent:1]];
        destination.playerNumber = @"1";
        destination.randomStart = [self.randomStart integerValue];
    }
}

- (void)setupDuel {
    [SVProgressHUD showSuccessWithStatus:@"Opponent Connected \n Setting Up Duel"];
    [self performSegueWithIdentifier:@"createGameSegue" sender:self];
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}



#pragma mark - Random Start Method

-(NSString *) randomStartTimeByGameType:(NSString *)gameType {
    NSUInteger lowerBound;
    NSUInteger upperBound;
    if ([gameType isEqualToString:@"Standoff"]) {
        lowerBound = 2;
        upperBound = 6;
    } else {
        lowerBound = 1;
        upperBound = 4;
    }
    NSUInteger randomValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return [NSString stringWithFormat:@"%lu",(unsigned long)randomValue];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
