//
//  CapturePreviewView.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/13/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "CapturePreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CapturePreviewView

+(Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

@end
