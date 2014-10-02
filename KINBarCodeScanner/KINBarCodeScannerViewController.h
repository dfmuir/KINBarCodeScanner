//
//  KINBarCodeScannerViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class KINBarCodeScannerViewController;

@protocol KINBarCodeScannerDelegate <NSObject>

@required

/*
 Called when a valid code string is detected
 */
- (void)barCodeScanner:(KINBarCodeScannerViewController *)barCodeScanner didDetectCodeString:(NSString *)codeString;


/*
 Called when the user presses the cancel button before a code is detected
 */
- (void)didCancelBarCodeScanner:(KINBarCodeScannerViewController *)codeScanner;

@optional

/*
 Called on the delegate to determine if codeString is detectable
 
 If not implemented, all code strings will be detectable
 
 This method may be called frequently, so it must be efficient to prevent capture performance problems
 */
- (BOOL)barCodeScanner:(KINBarCodeScannerViewController *)barCodeScanner shouldDetectCodeString:(NSString *)codeString;

@end


@interface KINBarCodeScannerViewController : UIViewController

@property (nonatomic, weak) id <KINBarCodeScannerDelegate> delegate;

/* Enable/disable vibration on code detection */
@property (nonatomic, assign) BOOL vibratesOnDetection;

/* Color of highlight box around code that is detectable */
@property (nonatomic, strong) UIColor *detectableHighlightColor;

/* Color of highlight box around code that is not detectable */
@property (nonatomic, strong) UIColor *undetectableHighlightColor;

/* Stroke width of the highlight box around codes */
@property (nonatomic, strong) NSNumber *hightlightStrokeWidth;

/* Delay in seconds after detection before returning to allow user to see highlighted code and (possibly) experience vibration */
@property (nonatomic, strong) NSNumber *delayAfterDetection;

/* Enable/disable highlighting of codes that are undetectable */
@property (nonatomic, assign) BOOL shouldHighlightUndetectableCodes;

/* The cancel button can be configured */
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

/* The flashlight button can be configured */
@property (nonatomic, strong) UIBarButtonItem *flashlightButton;

/* The toolbar can be configured */
@property (nonatomic, strong) UIToolbar *toolbar;


/* Initialize with an NSArray of AVMetadataObjectType strings */
- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes;

@end

