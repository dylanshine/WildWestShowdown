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
    
    self.gameTypes = @[@"Standoff", @"Paces"];
    self.numberOfShots = @[@"1", @"3", @"6"];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupDuel)
                                                 name:@"PeerConnected"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    } else {
        return [self.numberOfShots objectAtIndex:row];
    }
}

- (IBAction)createButtonPressed:(id)sender {
    NSInteger row1 = [self.pickerView selectedRowInComponent:0];
    NSInteger row2 = [self.pickerView selectedRowInComponent:1];
    self.randomStart = [self randomStartTime];
    NSDictionary *discoveryInfo = @{@"gameType":self.gameTypes[row1],
                                    @"shots":self.numberOfShots[row2],
                                    @"startTime": self.randomStart};
    [self.mpcHelper setupSession];
    [self.mpcHelper advertiseSelf:YES WithDiscoveryInfo:discoveryInfo];
    [SVProgressHUD showWithStatus:@"Waiting For Opponent ... \n Tap To Cancel"maskType:SVProgressHUDMaskTypeBlack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCreateGame:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];

}

- (void)cancelCreateGame:(NSNotification *)notification {
    [self cancelMPC];
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



- (void)cancelMPC {
    [self.mpcHelper.session disconnect];
    [self.mpcHelper advertiseSelf:NO WithDiscoveryInfo:nil];
}


#pragma mark - Random Start Method

-(NSString *) randomStartTime {
    NSUInteger lowerBound = 2;
    NSUInteger upperBound = 6;
    NSUInteger randomValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return [NSString stringWithFormat:@"%lu",(unsigned long)randomValue];
}

@end
