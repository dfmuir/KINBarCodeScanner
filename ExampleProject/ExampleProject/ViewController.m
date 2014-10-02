//
//  ViewController.m
//  ExampleProject
//
//  Created by David Muir on 9/30/14.
//  Copyright (c) 2014 Kinwa, Inc. All rights reserved.
//

#import "ViewController.h"

#import <KINBarCodeScanner/KINBarCodeScannerViewController.h>

@interface ViewController () <KINBarCodeScannerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)scanButtonPressed:(id)sender {
    KINBarCodeScannerViewController *barCodeScannerViewController = [[KINBarCodeScannerViewController alloc] init];
    barCodeScannerViewController.delegate = self;
    [self presentViewController:barCodeScannerViewController animated:YES completion:nil];
    
}

#pragma mark - KINBarCodeScannerDelegate

- (void)barCodeScanner:(KINBarCodeScannerViewController *)codeScanner didDetectCodeString:(NSString *)codeString {
    self.resultLabel.text = codeString;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelBarCodeScanner:(KINBarCodeScannerViewController *)codeScanner {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)barCodeScanner:(KINBarCodeScannerViewController *)barCodeScanner shouldDetectCodeString:(NSString *)codeString {
    
    if(self.segmentedControl.selectedSegmentIndex == 0) { // Decect any string
        return YES;
    }
    else if(self.segmentedControl.selectedSegmentIndex == 1) { // Detect URL strings
        return [self isValidURLString:codeString];
    }
    else if(self.segmentedControl.selectedSegmentIndex == 2) { // Detect email strings
        return [self isValidEmailString:codeString];
    }
    return NO;
}

#pragma mark - String Validation

- (BOOL)isValidURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    return (URL && URL.scheme && URL.host);
}

- (BOOL)isValidEmailString:(NSString *)emailString {
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:emailString];
}


@end
