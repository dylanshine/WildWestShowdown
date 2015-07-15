//
//  DuelViewController.m
//  Wild West Showdown
//
//  Created by Dylan Shine on 7/11/15.
//  Copyright (c) 2015 Dylan Shine. All rights reserved.
//

#import "DuelViewController.h"
#import "MultipeerConnectivityHelper.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHud.h"
#import "SFCountdownView.h"
#import "GameOverViewController.h"
#import "SoundPlayer.h"
#import "GameLogic.h"

@interface DuelViewController() <AVCaptureVideoDataOutputSampleBufferDelegate, SFCountdownViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet SFCountdownView *countDownView;

@property (nonatomic) MultipeerConnectivityHelper *mpcHelper;
@property (nonatomic) BOOL playerReady;
@property (nonatomic) BOOL opponentReady;
@property (nonatomic) GameLogic *game;
@property (nonatomic) double gameClock;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIImage *borderImage;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic) NSInteger face;
@end

@implementation DuelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mpcHelper = [MultipeerConnectivityHelper sharedMCHelper];
    self.countDownView.delegate = self;
    self.countDownView.backgroundAlpha = 0.2;
    self.countDownView.countdownColor = [UIColor blackColor];
    self.countDownView.countdownFrom = 3;
    [self.countDownView updateAppearance];
    [self setupAVCapture];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MessageReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDisconnection:)
                                                 name:@"PeerDisconnected"
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[SoundPlayer sharedPlayer] stop];
}

#pragma mark - NSNotifications
- (void)handleReceivedDataWithNotification:(NSNotification *)notification {
    NSDictionary *userInfoDict = [notification userInfo];
    NSData *receivedData = [userInfoDict objectForKey:@"data"];
    NSString *message = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if ([message isEqualToString:@"Ready"]) {
        self.opponentReady = YES;
    } else if ([message isEqualToString:@"Ready Cancelled"]) {
        self.opponentReady = NO;
    } else if ([message isEqualToString:@"Killed"]) {
        self.game.result = @"Loser";
        [self performSegueWithIdentifier:@"gameOverSegue" sender:self];
    } else {
        NSTimeInterval timeToStartFloat = [message doubleValue];
        NSDate *timeToStart = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:timeToStartFloat];
        [self startDuelAtDate:timeToStart];
    }
}

- (void)handleDisconnection:(NSNotification *)notification {
    if (self.isBeingPresented) {
        [SVProgressHUD showErrorWithStatus:@"Opponent Disconnected"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GameOverViewController *destination = segue.destinationViewController;
    destination.gameTime = [self.game gameDurationTime];
    destination.result = self.game.result;
    destination.accuracy = [self.game accuracyString];
}

#pragma mark - Ready

- (IBAction)readyButtonPressed:(id)sender {
    self.playerReady = YES;
    NSData *data = [@"Ready" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [self.mpcHelper.session sendData:data
                             toPeers:self.mpcHelper.session.connectedPeers
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
}

- (void)cancelReadyGame:(NSNotification *)notification {
    self.playerReady = NO;
    self.readyButton.hidden = NO;
    NSData *data = [@"Ready Cancelled" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [self.mpcHelper.session sendData:data
                             toPeers:self.mpcHelper.session.connectedPeers
                            withMode:MCSessionSendDataReliable
                               error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [SVProgressHUD dismiss];
}


- (void)setPlayerReady:(BOOL)playerReady {
    _playerReady = playerReady;
    self.readyButton.hidden = YES;
    [SVProgressHUD showWithStatus:@"Waiting For Opponent ... \n Tap To Cancel" maskType:SVProgressHUDMaskTypeBlack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelReadyGame:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    
    if (self.opponentReady) {
        NSDate *timeToStart = [[NSDate date] dateByAddingTimeInterval:3];
        NSTimeInterval timeToStartFloat = [timeToStart timeIntervalSinceReferenceDate];
        NSString *timeToStartString = [NSString stringWithFormat:@"%f", timeToStartFloat];
        NSLog(@"float: %f / \"%@\"", timeToStartFloat, timeToStartString);
        NSData *data = [timeToStartString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        [self.mpcHelper.session sendData:data
                                 toPeers:self.mpcHelper.session.connectedPeers
                                withMode:MCSessionSendDataReliable
                                   error:&error];
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [self startDuelAtDate:timeToStart];
        
    }
}

#pragma mark - SFCountDown

-(void)startDuelAtDate:(NSDate *)date {
    [SVProgressHUD showWithStatus:@"Starting Duel"maskType:SVProgressHUDMaskTypeBlack];
    NSLog(@"will start duel at %@", date);
    NSTimer *startTimer = [[NSTimer alloc] initWithFireDate:date interval:0 target:self selector:@selector(setupDuel) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:startTimer forMode:NSDefaultRunLoopMode];
}

-(void)setupDuel {
    NSLog(@"setupDuel timer fired @ %@", [NSDate date]);
    [SVProgressHUD dismiss];
    [self.countDownView start];
}

- (void) countdownFinished:(SFCountdownView *)view {
    [self.countDownView removeFromSuperview];
    [self.view setNeedsDisplay];
    [self.game startDuelAtRandomTimeWithCompletion:^{
        self.borderImage = [UIImage imageNamed:@"revolverReticle"];
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(fireTap)];
        [self.view addGestureRecognizer:singleFingerTap];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pullHammerSwipe)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipeDown];
    }];

}

#pragma mark - Game Action Gestures
- (void)fireTap {
    [self.game fireAtPlayer:self.face];
    if ([self.game opponentIsDead]) {
        [self performSegueWithIdentifier:@"gameOverSegue" sender:self];
    }
}

- (void)pullHammerSwipe {
    [self.game pullHammer];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.game reload];
}

#pragma mark - AVCaptureSession

- (void)setupAVCapture {
    NSError *error = nil;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!error) {
        
        if ( [session canAddInput:deviceInput] ){
            [session addInput:deviceInput];
        }
        
        
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked

        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
        
        if ( [session canAddOutput:self.videoDataOutput] ){
            [session addOutput:self.videoDataOutput];
        }
        
        // get the output for doing face detection.
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
        
        self.previewLayer = (AVCaptureVideoPreviewLayer *)self.containerView.layer;
        self.previewLayer.session = session;
        self.previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [session startRunning];
        
    }
    session = nil;
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  [NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self teardownAVCapture];
    }
}

- (void)teardownAVCapture {
    self.videoDataOutput = nil;
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
}

+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity
                          frameSize:(CGSize)frameSize
                       apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

- (void)drawFaces:(NSArray *)features
      forVideoBox:(CGRect)clearAperture
      orientation:(UIDeviceOrientation)orientation
{
    NSArray *sublayers = [NSArray arrayWithArray:[self.previewLayer sublayers]];
    NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
    NSInteger featuresCount = [features count], currentFeature = 0;
    self.face = [features count];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    // hide all the face layers
    for ( CALayer *layer in sublayers ) {
        if ( [[layer name] isEqualToString:@"FaceLayer"] )
            [layer setHidden:YES];
    }
    
    if ( featuresCount == 0 ) {
        [CATransaction commit];
        return; // early bail.
    }
    
    CGSize parentFrameSize = [self.view frame].size;
    NSString *gravity = [self.previewLayer videoGravity];
    BOOL isMirrored = self.previewLayer.connection.isVideoMirrored;
    CGRect previewBox = [DuelViewController videoPreviewBoxForGravity:gravity
                                                        frameSize:parentFrameSize
                                                     apertureSize:clearAperture.size];
    
    for ( CIFaceFeature *ff in features ) {
        CGRect faceRect = [ff bounds];
        CGFloat temp = faceRect.size.width;
        faceRect.size.width = faceRect.size.height;
        faceRect.size.height = temp;
        temp = faceRect.origin.x;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = temp;
        CGFloat widthScaleBy = previewBox.size.width / clearAperture.size.height;
        CGFloat heightScaleBy = previewBox.size.height / clearAperture.size.width;
        faceRect.size.width *= widthScaleBy;
        faceRect.size.height *= heightScaleBy;
        faceRect.origin.x *= widthScaleBy;
        faceRect.origin.y *= heightScaleBy;
        
        if ( isMirrored )
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
        else
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
        
        CALayer *featureLayer = nil;
        
        while ( !featureLayer && (currentSublayer < sublayersCount) ) {
            CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
            if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
                featureLayer = currentLayer;
                [currentLayer setHidden:NO];
            }
        }
        
        if ( !featureLayer ) {
            featureLayer = [[CALayer alloc]init];
            featureLayer.contents = (id)self.borderImage.CGImage;
            [featureLayer setName:@"FaceLayer"];
            [self.previewLayer addSublayer:featureLayer];
            featureLayer = nil;
        }
        [featureLayer setFrame:faceRect];
        
        currentFeature++;
    }
    
    [CATransaction commit];
}

- (NSNumber *) exifOrientation {
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    int exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
    
    return [NSNumber numberWithInt:exifOrientation];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation]
                                                             forKey:CIDetectorImageOrientation];
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:imageOptions];
    if ([features firstObject]) {
       features = @[[features firstObject]];
    }
    
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self drawFaces:features
            forVideoBox:cleanAperture
            orientation:curDeviceOrientation];
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Lazy Instantiation

-(GameLogic *)game {
    if(!_game) {
        _game = [[GameLogic alloc] initWithLives:[self.numberOfShots integerValue] StartTime:self.randomStart GameType:self.gameType];
    }
    return _game;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
