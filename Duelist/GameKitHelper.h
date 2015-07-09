//
//  GameKitHelper.h
//  Duelist
//
//  Created by Dylan Shine on 7/8/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>



extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject
@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, readonly) BOOL isEnabled;

+(instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;

@end
