KINBarCodeScanner
=================

A barcode scanner for your iOS apps.

Features
------------------------
* Supports barcodes and QR codes
* iOS 7 & 8 support for iPhone and iPad
* Customizable UI
* Built-in Flashlight
* Portrait and landscape orientation support
* Customizable on-the-fly bar code format validation
* Optional vibration on code detection
* Installation with [CocoaPods](http://cocoapods.org/)

Overview
------------------------
KINBarCodeScanner consists of a single component:

`KINBarCodeScannerViewController` - a UIViewController that contains a full featured bar code scanner.

**KINBarCodeScannerViewController is Presented Modally:**
```objective-c
KINBarCodeScannerViewController *barCodeScannerViewController = [[KINBarCodeScannerViewController alloc] init];
barCodeScannerViewController.delegate = self;
[self presentViewController:barCodeScannerViewController animated:YES completion:nil];
```



Installation With CocoaPods
------------------------
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the ["Getting Started" for more information](http://guides.cocoapods.org/using/getting-started.html).

#### Podfile

```ruby
platform :ios, '7.0'
pod 'KINBarCodeScanner', '~> 0.0'
```
