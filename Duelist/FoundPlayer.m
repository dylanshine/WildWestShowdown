//
//  FoundPlayer.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "FoundPlayer.h"

@implementation FoundPlayer

- (instancetype)initWithPeerID:(MCPeerID *)peerID DiscoveryInfo:(NSDictionary *)discoveryInfo {
    if (self = [super init]) {
        _peerID = peerID;
        _discoveryInfo = discoveryInfo;
    }
    
    return self;
}

- (instancetype)init {
    self = [self initWithPeerID:[[MCPeerID alloc] init] DiscoveryInfo:@{}];
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == nil) return NO;
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    } else if ([[object peerID] isEqual:self.peerID]) {
        return YES;
    }
    return NO;
};

@end
