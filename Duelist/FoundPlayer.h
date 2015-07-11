//
//  FoundPlayer.h
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface FoundPlayer : NSObject
@property (nonatomic) MCPeerID *peerID;
@property (nonatomic) NSDictionary *discoveryInfo;

- (instancetype)initWithPeerID:(MCPeerID *)peerID DiscoveryInfo:(NSDictionary *)discoveryInfo;
@end
