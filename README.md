KINBarCodeScanner
=================

A barcode scanner module for your iOS apps.

![KINBarCodeScanner](http://i.imgur.com/hukcqz9.png)

Features
------------------------
* Supports barcodes and QR codes
* iOS 7 & 8 support for iPhone and iPad
* Customizable on-the-fly bar code format validation
* Touch to select from multiple codes
* Built-in Flashlight
* Portrait and landscape orientation support
* Customizable UI
* Optional vibration on code detection
* Installation with [CocoaPods](http://cocoapods.org/)

Example Project
------------------------
The KINBarCodeScanner example project contains a fully functional example of a KINBarCodeScanner implementation. Test it out using the graphic below.
![Example QR Codes](http://i.imgur.com/i4Pvr1y.png)

The example project provides a number of options to demonstrate KINCodeScanner's code validation capabilties.

Overview
------------------------
KINBarCodeScanner provides a UIViewController wrapper to AVCaptureSession's built-in ability to process barcodes and QR codes in iOS 7+.

KINBarCodeScanner consists of a single component:

`KINBarCodeScannerViewController` - a UIViewController that contains a full featured bar code scanner.

**Basic Example**

KINBarCodeScannerViewController should be presented modally.
```objective-c
KINBarCodeScannerViewController *barCodeScannerViewController = [[KINBarCodeScannerViewController alloc] init];
barCodeScannerViewController.delegate = self;
[self presentViewController:barCodeScannerViewController animated:YES completion:nil];
```

**Advanced Initialization Example**

KINBarCodeScannerViewController can be initialized to detect only specific code types. The following example configures KINBarCodeScannerViewController to only detect QR codes.

```objective-c
KINBarCodeScannerViewController *barCodeScannerViewController = [[KINBarCodeScannerViewController alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
```

`initWithMetadataObjectTypes` accepts an NSArray of [AVMetadataObjectType string constants](https://developer.apple.com/library/IOS/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/index.html#//apple_ref/doc/constant_group/Machine_Readable_Object_Types).


Installation With CocoaPods
------------------------
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the ["Getting Started" for more information](http://guides.cocoapods.org/using/getting-started.html).

#### Podfile

```ruby
platform :ios, '7.0'
pod 'KINBarCodeScanner'
```
