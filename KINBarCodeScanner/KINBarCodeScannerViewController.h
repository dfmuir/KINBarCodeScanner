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

@class KINBarCodeScannerViewController;

@protocol KINBarCodeScannerDelegate <NSObject>

@required

/* Called when a valid code string is detected */
- (void)codeScanner:(KINBarCodeScannerViewController *)codeScanner didDetectCodeString:(NSString *)codeString;

/* Called when the user presses the cancel button before a code is detected */
- (void)didCancelCodeScanner:(KINBarCodeScannerViewController *)codeScanner;

@optional

/* 
    Called on the delegate to validate the detected code string
    Can be implemented to only allow detection of code strings matching requirments
    This method may be called frequently, so it must be efficient to prevent capture performance problems
*/
- (BOOL)codeScanner:(KINBarCodeScannerViewController *)codeScanner shouldDetectCodeString:(NSString *)codeString;


/*
    Returns to enable or disable vibration when barcode is detected
    If not specified, defaults to YES
*/
- (BOOL)shouldVibrateOnDetectionForCodeScanner:(KINBarCodeScannerViewController *)codeScanner;


/*  Returns array of AVMetadataObjectType strings to scan for
    Only codes in this array will be detected
    If not specified all supported code types will be detected
*/
- (NSArray *)detectableCodeTypesForCodeScanner:(KINBarCodeScannerViewController *)codeScanner;

@end



@interface KINBarCodeScannerViewController : UIViewController

@property (nonatomic, weak) id <KINBarCodeScannerDelegate> delegate;

@end

