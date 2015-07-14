//
//  MultipeerConnectivityHelper.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/9/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "MultipeerConnectivityHelper.h"

@interface MultipeerConnectivityHelper ()
@end

@implementation MultipeerConnectivityHelper

+ (instancetype)sharedMCHelper {
    static MultipeerConnectivityHelper *_sharedMCHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMCHelper = [[self alloc] init];
    });
    
    return _sharedMCHelper;
}

- (void)setupPeerWithDisplayName:(NSString *)displayName {
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}

-(void) setupSession {
    if (!self.session) {
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
    }
}

-(void) setupServiceBrowser {
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"WWS"];
}

-(void) advertiseSelf:(BOOL)advertise WithDiscoveryInfo:(NSDictionary *)discoveryInfo {
    if (advertise) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:discoveryInfo serviceType:@"WWS"];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
    } else {
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
    }
    
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
    if ([self.session.connectedPeers containsObject:peerID]) {
        invitationHandler(NO, nil);
        return;
    }
    
    invitationHandler(YES, self.session);
    [self.advertiser stopAdvertisingPeer];
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSDictionary *userInfo = @{ @"peerID": peerID,
                                @"state" : @(state) };
    
    if (state == MCSessionStateConnected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PeerConnected"
                                                                object:nil
                                                              userInfo:userInfo];
        });
        
    } else if (state == MCSessionStateNotConnected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PeerDisconnected"
                                                                object:nil
                                                              userInfo:userInfo];
        });
    }
    
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *userInfo = @{ @"data": data,
                                @"peerID": peerID };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived"
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}


@end
