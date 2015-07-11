//
//  MultipeerConnectivityHelper.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/9/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MultipeerConnectivityHelper : NSObject <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic) MCNearbyServiceBrowser *serviceBrowser;

+(instancetype)sharedMCHelper;

- (void)setupPeerWithDisplayName:(NSString *)displayName;
- (void)setupSession;
- (void)setupServiceBrowser;
- (void) advertiseSelf:(BOOL)advertise WithDiscoveryInfo:(NSDictionary *)discoveryInfo;

@end
