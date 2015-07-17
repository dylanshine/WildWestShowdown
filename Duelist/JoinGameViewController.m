//
//  JoinGameViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "JoinGameViewController.h"
#import "MultipeerConnectivityHelper.h"
#import "DuelViewController.h"
#import "SVProgressHUD.h"
#import "FoundPlayer.h"

@interface JoinGameViewController() <MCNearbyServiceBrowserDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@property (nonatomic) MCNearbyServiceBrowser *serviceBrowser;
@property (nonatomic) NSMutableOrderedSet *foundPlayers;
@property (nonatomic) FoundPlayer *playerToConnect;
@end

@implementation JoinGameViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.foundPlayers = [[NSMutableOrderedSet alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    [self.mpcHelper setupServiceBrowser];
    
    self.serviceBrowser = self.mpcHelper.serviceBrowser;
    self.serviceBrowser.delegate = self;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.foundPlayers removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupDuel)
                                                 name:@"PeerConnected"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDisconnection:)
                                                 name:@"PeerDisconnected"
                                               object:nil];
    
    [self.serviceBrowser startBrowsingForPeers];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeerConnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeerDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDDidReceiveTouchEventNotification object:nil];

    [self.serviceBrowser stopBrowsingForPeers];
    [SVProgressHUD dismiss];
}

- (void)handleDisconnection:(NSNotification *)notification {
    [SVProgressHUD showErrorWithStatus:@"Opponent Disconnected"];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    FoundPlayer *player = [[FoundPlayer alloc] initWithPeerID:peerID DiscoveryInfo:info];
    
    if (![self.foundPlayers containsObject:player]) {
        [self.foundPlayers addObject:player];
        [self.tableView reloadData];
        
    }
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    [self.foundPlayers removeObject:[self foundPlayerWithPeerID:peerID]];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.foundPlayers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell" forIndexPath:indexPath];
    
    FoundPlayer *player = self.foundPlayers[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = player.peerID.displayName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", player.discoveryInfo[@"gameType"], player.discoveryInfo[@"shots"]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.playerToConnect = self.foundPlayers[indexPath.row];
    [self.mpcHelper setupSession];
    [self.mpcHelper.serviceBrowser invitePeer:self.playerToConnect.peerID toSession:self.mpcHelper.session withContext:nil timeout:6];
    [SVProgressHUD showWithStatus:@"Setting Up Duel ..."maskType:SVProgressHUDMaskTypeBlack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCreateGame:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
}


- (void)cancelCreateGame:(NSNotification *)notification {
    [self.mpcHelper.session disconnect];
    [SVProgressHUD dismiss];
}


- (FoundPlayer *)foundPlayerWithPeerID:(MCPeerID *)peerID {
    for (FoundPlayer *player in self.foundPlayers) {
        if (player.peerID == peerID) {
            return player;
            break;
        }
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"joinGameSegue"]) {
        DuelViewController *destination = segue.destinationViewController;
        FoundPlayer *player = self.playerToConnect;
        destination.gameType = player.discoveryInfo[@"gameType"];
        destination.numberOfShots = player.discoveryInfo[@"shots"];
        destination.randomStart = [player.discoveryInfo[@"startTime"] integerValue];
        destination.playerNumber = @"2";
    }
}

- (void)setupDuel {
    [SVProgressHUD showSuccessWithStatus:@"Opponent Connected \n Setting Up Duel"];
    [self performSegueWithIdentifier:@"joinGameSegue" sender:self];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
