//
//  KINBarCodeScannerViewController.m
//
//  KINBarCodeScanner
//
//  Created by David F. Muir V
//  dfmuir@gmail.com
//  Co-Founder & Engineer at Kinwa, Inc.
//  http://www.kinwa.co
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 David Muir
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "KINBarCodeScannerViewController.h"

@interface KINBarCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) NSArray *metadataObjectTypes;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CALayer *highlightLayer;
@property (nonatomic, strong) NSArray *validCodeObjects;
@property (nonatomic, strong) NSArray *invalidCodeObjects;
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *selectedCodeObject;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) BOOL flashlightOn;

@end


@implementation KINBarCodeScannerViewController

#pragma mark - Initialization

- (id)init {
    return [self initWithMetadataObjectTypes:nil];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes {
    self = [super init];
    if(self) {
        
        _metadataObjectTypes = metadataObjectTypes;
        
        // Assign default values
        self.vibratesOnDetection = YES;
        self.detectableHighlightColor = [UIColor greenColor];
        self.undetectableHighlightColor = [UIColor redColor];
        self.hightlightStrokeWidth = @4.0f;
        self.delayAfterDetection = @1.0f;
        self.shouldHighlightUndetectableCodes = YES;
        
        // Create cancel button
        self.cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"cancel_button" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
        
        self.flashlightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"flashlight_off_button" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(flashlightButtonPressed:)];
        
        self.toolbar = [[UIToolbar alloc] init];
        self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.toolbar];
        
        UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpaceItem.width = self.cancelButton.width;
        
        UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.toolbar.items = @[flexibleSpaceItem, self.cancelButton, flexibleSpaceItem, self.flashlightButton];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeBottom relatedBy:0 toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeWidth relatedBy:0 toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        
    }
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error = nil;
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if([self.captureSession canAddInput:self.deviceInput]) {
        [self.captureSession addInput:self.deviceInput];
    }
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if([self.captureSession canAddOutput:self.output]) {
        [self.captureSession addOutput:self.output];
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    
    self.highlightLayer = [CALayer layer];
    self.highlightLayer.delegate = self;
    self.highlightLayer.frame = self.previewLayer.bounds;
    [self.view.layer addSublayer:self.highlightLayer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDetectTapGesture:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.highlightLayer.delegate = nil;
    
    [self.captureSession removeInput:self.deviceInput];
    [self.captureSession removeOutput:self.output];
    [self stopScanning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
    self.highlightLayer.frame = self.previewLayer.bounds;
}

#pragma mark - Public Interface

- (void)startScanning {
    [self updateCodeTypes];
    [self.captureSession startRunning];
}

- (void)stopScanning {
    [self.captureSession stopRunning];
}

#pragma mark - Detection

- (void)detectCodeObject:(AVMetadataMachineReadableCodeObject *)codeObject {
    [self.captureSession stopRunning];
    
    self.selectedCodeObject = codeObject;
    self.validCodeObjects = nil;
    self.invalidCodeObjects = nil;
    [self.highlightLayer setNeedsDisplay];
    
    if(self.vibratesOnDetection) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if([self.delegate respondsToSelector:@selector(barCodeScanner:didDetectCodeString:)]) {
        // Delay to allow user to see the highlighted code and experience the vibration before dismissing the view
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [self.delayAfterDetection doubleValue] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.delegate barCodeScanner:self didDetectCodeString:codeObject.stringValue];
        });
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSMutableArray *validCodes = [[NSMutableArray alloc] init];
    NSMutableArray *invalidCodes = [[NSMutableArray alloc] init];
    
    for (AVMetadataObject *metadataObject in metadataObjects) {
        
        AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        
        if(codeObject) {
            if([self isValidCodeObject:codeObject]) {
                [validCodes addObject:codeObject];
            }
            else {
                [invalidCodes addObject:codeObject];
            }
        }
    }
    
    self.validCodeObjects = [NSArray arrayWithArray:validCodes];
    self.invalidCodeObjects = [NSArray arrayWithArray:invalidCodes];
    
    [self.highlightLayer setNeedsDisplay];
    
    if([self.validCodeObjects count] == 1) {
        [self detectCodeObject:self.validCodeObjects[0]];
    }
}

#pragma mark - CALayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
    if(self.selectedCodeObject) {
        CGContextSetLineWidth(ctx, [self.hightlightStrokeWidth doubleValue]*2.0f);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.selectedCodeObject.bounds];
        CGContextAddPath(ctx, path.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [self.detectableHighlightColor CGColor]);
        CGContextStrokePath(ctx);
    }
    else {
        CGContextSetLineWidth(ctx, [self.hightlightStrokeWidth doubleValue]);
        for (AVMetadataMachineReadableCodeObject *codeObject in self.validCodeObjects) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:codeObject.bounds];
            CGContextAddPath(ctx, path.CGPath);
        }
        CGContextSetStrokeColorWithColor(ctx, [self.detectableHighlightColor CGColor]);
        CGContextStrokePath(ctx);
        
        if(self.shouldHighlightUndetectableCodes) {
            for (AVMetadataMachineReadableCodeObject *codeObject in self.invalidCodeObjects) {
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:codeObject.bounds];
                CGContextAddPath(ctx, path.CGPath);
            }
            CGContextSetStrokeColorWithColor(ctx, [self.undetectableHighlightColor CGColor]);
            CGContextStrokePath(ctx);
        }
    }
}

#pragma mark - UIButton Actions

- (void)cancelButtonPressed:(id)sender {
    if(sender == self.cancelButton) {
        if([self.delegate respondsToSelector:@selector(didCancelBarCodeScanner:)]) {
            [self.delegate didCancelBarCodeScanner:self];
        }
    }
}

- (void)flashlightButtonPressed:(id)sender {
    if(sender == self.flashlightButton) {
        self.flashlightOn = !self.flashlightOn;
    }
}

#pragma mark - Flashlight

- (void)setFlashlightOn:(BOOL)flashlightOn {
    
    _flashlightOn = flashlightOn;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: self.flashlightOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
    NSString *imageName = self.flashlightOn ? @"flashlight_on_button" : @"flashlight_off_button";
    [self.flashlightButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:imageName ofType:@"png"]]];
}

#pragma mark - Tap Gesture Recognizer

- (void)didDetectTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer == self.tapGestureRecognizer) {
        CGPoint tapPoint = [self.tapGestureRecognizer locationInView:self.view];
        for (AVMetadataMachineReadableCodeObject *codeObject in self.validCodeObjects) {
            if(CGRectContainsPoint(codeObject.bounds, tapPoint)) {
                [self detectCodeObject:codeObject];
            }
        }
    }
}

#pragma mark - Code Types

- (void)updateCodeTypes {
    
    NSMutableSet *metadataObjectTypesSet;
    if(self.metadataObjectTypes && [self.metadataObjectTypes count] > 0) {
        metadataObjectTypesSet = [NSMutableSet setWithArray:self.metadataObjectTypes];
        // Remove any unavailable metadata object types from specified array
        [metadataObjectTypesSet intersectSet:[NSSet setWithArray:self.output.availableMetadataObjectTypes]];
    }
    else {
        metadataObjectTypesSet = [NSMutableSet setWithArray:self.output.availableMetadataObjectTypes];
    }
    
    // Disable face detction. Faces are not codes.
    [metadataObjectTypesSet removeObject:AVMetadataObjectTypeFace];
    
    // This assertion could fail because _metadataObjectTypes is not specified properly, or because AVCaptureMetadataOutput does not support any of the specified codes in this version of iOS
    NSAssert([metadataObjectTypesSet count] > 0, @"No available code types specified in detectableCodeTypesForCodeScanner:");
    
    self.output.metadataObjectTypes = [metadataObjectTypesSet allObjects];
}

#pragma mark - Delegate Helpers

- (BOOL)isValidCodeObject:(AVMetadataMachineReadableCodeObject *)codeObject {
    if(codeObject && codeObject.stringValue) {
        if(![self.delegate respondsToSelector:@selector(barCodeScanner:shouldDetectCodeString:)] || [self.delegate barCodeScanner:self shouldDetectCodeString:codeObject.stringValue]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Interface Orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
