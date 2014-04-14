//
//  GameViewController.m
//  Hangman
//
//  Created by Aaron Day on 4/8/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import "NotificationCentralManagerDelegate.h"
#import "NotificationPeripheralDelegate.h"

#import "GameViewController.h"

NSString* const kGameViewControllerIdentifier = @"GameViewController";

NSString* const MPHangmanServiceUUID = @"F64954AC-90A1-406F-813A-349EC9BE8106";
NSString* const MPHangmanStateCharacteristicUUID = @"F67F348F-ED86-4577-90DC-FA793AC5E967";
NSString* const MPHangmanCurrentWordCharacteristicUUID = @"39219AA3-BFD4-410F-AC05-EC489351C339";
NSString* const MPHangmanGuessLetterCharacteristicUUID = @"3278C646-1F5E-4DF4-AD53-90C78B49955E";
NSString* const MPHangmanGuessedLettersCharacteristicUUID = @"C974AF7A-6613-4337-8AB4-721DADF45DDF";
NSString* const MPHangmanRemainingGuessesCharacteristicUUID = @"D888B7C1-ADD5-44B9-B503-C581D8D55F1C";

@interface GameViewController ()

@property IBOutlet UIActivityIndicatorView *activityIndicator;
@property IBOutlet UILabel *currentWordLabel;
@property IBOutlet UIImageView *hangmanView;
@property IBOutlet UILabel *guessedLettersLabel;

@property UITextField *hiddenField;

@end

@implementation GameViewController

- (id) initWithCoder:(NSCoder*)decoder
{
    if (self = [super initWithCoder:decoder]) {
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setupHiddenField];
}

- (void) setupHiddenField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.hiddenField = textField;
    self.hiddenField.hidden = YES;
    self.hiddenField.delegate = self;
    self.hiddenField.keyboardType = UIKeyboardTypeAlphabet;
    [self.view addSubview:self.hiddenField];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setupNotifications];
    [super viewDidAppear:animated];
    [self connect];
}

- (void) connect
{
    [self.activityIndicator startAnimating];
    [self.centralManager connectPeripheral:self.peripheral options:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self disconnect];
    [super viewDidDisappear:animated];
    [self teardownNotifications];
}

- (void) disconnect
{
    [self.centralManager cancelPeripheralConnection:self.peripheral];
}

#pragma mark -
#pragma mark Notifications

- (void) setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected:) name:kPeripheralConnected object:self.peripheral];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:kPeripheralDisconnected  object:self.peripheral];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveredServices:) name:kDiscoveredServices object:self.peripheral];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveredCharacteristics:) name:kDiscoveredCharacteristics object:self.peripheral];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCharacteristic:) name:kCharacteristicUpdated object:self.peripheral];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCharacteristicNotificationState:) name:kCharacteristicNotificationStateUpdated object:self.peripheral];
}

- (void) teardownNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPeripheralConnected object:self.peripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPeripheralDisconnected object:self.peripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDiscoveredServices object:self.peripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDiscoveredCharacteristics object:self.peripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCharacteristicUpdated object:self.peripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCharacteristicNotificationStateUpdated object:self.peripheral];
}

- (void) connected:(NSNotification*)notification
{
    NSLog(@"Connected");
    [self discoverServices];
}

- (void) disconnected:(NSNotification*)notification
{
    // service and characteristics stale
    self.hangmanService = nil;
    self.stateCharacteristic = nil;
    self.currentWordCharacteristic = nil;
    self.guessLetterCharacteristic = nil;
    self.guessedLettersCharacteristic = nil;
    self.remainingGuessesCharacteristic = nil;
    
    NSError *error = notification.userInfo[kKeyError];
    if (error) {
        NSLog(@"Disconnect: %@", error);
        [self connect];
    }
}

- (void) discoveredServices:(NSNotification*)notification
{
    for (CBService *service in self.peripheral.services) {
        if ([[service.UUID UUIDString] isEqualToString:MPHangmanServiceUUID]) {
            self.hangmanService = service;
        }
    }
    
    if (self.hangmanService) {
        NSLog(@"Discovered Service");
        [self discoverCharacteristics];
    } else {
        NSLog(@"This is not the game we are looking for. /handwave");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) discoveredCharacteristics:(NSNotification*)notification
{
    NSLog(@"Discovered Characteristics");

    for (CBCharacteristic *characteristic in self.hangmanService.characteristics) {
        if ([[characteristic.UUID UUIDString] isEqualToString:MPHangmanStateCharacteristicUUID]) {
            self.stateCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [self.peripheral readValueForCharacteristic:characteristic];
        } else if ([[characteristic.UUID UUIDString] isEqualToString:MPHangmanCurrentWordCharacteristicUUID]) {
            self.currentWordCharacteristic = characteristic;
        } else if ([[characteristic.UUID UUIDString] isEqualToString:MPHangmanGuessLetterCharacteristicUUID]) {
            self.guessLetterCharacteristic = characteristic;
        } else if ([[characteristic.UUID UUIDString] isEqualToString:MPHangmanGuessedLettersCharacteristicUUID]) {
            self.guessedLettersCharacteristic = characteristic;
        } else if ([[characteristic.UUID UUIDString] isEqualToString:MPHangmanRemainingGuessesCharacteristicUUID]) {
            self.remainingGuessesCharacteristic = characteristic;
        }
    }
    
    [self.activityIndicator stopAnimating];
}

- (void) updatedCharacteristic:(NSNotification*)notification
{
    CBCharacteristic *characteristic = notification.userInfo[kKeyCharacteristic];

    if (characteristic == self.stateCharacteristic) {
        uint8_t state = 0;
        [characteristic.value getBytes:&state length:sizeof(state)];
        [self updateState:state];
    } else if (characteristic == self.currentWordCharacteristic) {
        NSString *currentWord = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        [self updateCurrentWord:currentWord];
    } else if (characteristic == self.guessedLettersCharacteristic) {
        NSString *guessedLetters = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        [self updateGuessedLetters:guessedLetters];
    } else if (characteristic == self.remainingGuessesCharacteristic) {
        uint8_t remainingGuesses = 0;
        [characteristic.value getBytes:&remainingGuesses length:sizeof(remainingGuesses)];
        [self updateRemainingGuesses:remainingGuesses];
    }
}

- (void) updatedCharacteristicNotificationState:(NSNotification*)notification
{
    [self.peripheral readValueForCharacteristic:self.currentWordCharacteristic];
    [self.peripheral readValueForCharacteristic:self.guessedLettersCharacteristic];
    [self.peripheral readValueForCharacteristic:self.remainingGuessesCharacteristic];
}

#pragma mark -
#pragma mark Bluetooth

- (void) discoverServices
{
    NSLog(@"Discover Services");
    [self.peripheral discoverServices:nil];
}

- (void) discoverCharacteristics
{
    NSLog(@"Discover Characteristics");
    [self.peripheral discoverCharacteristics:@[ [[NSUUID alloc] initWithUUIDString:MPHangmanStateCharacteristicUUID], [[NSUUID alloc] initWithUUIDString:MPHangmanCurrentWordCharacteristicUUID], [[NSUUID alloc] initWithUUIDString:MPHangmanGuessLetterCharacteristicUUID], [[NSUUID alloc] initWithUUIDString:MPHangmanGuessedLettersCharacteristicUUID], [[NSUUID alloc] initWithUUIDString:MPHangmanRemainingGuessesCharacteristicUUID]  ] forService:self.hangmanService];
}

#pragma mark -
#pragma mark Gameplay

- (void) guessLetter:(NSString*)letter
{
    NSLog(@"Guess Letter: %@", letter);
    [self.peripheral writeValue:[letter dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.guessLetterCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) updateState:(MPHangmanState)state
{
    NSLog(@"Updated State: %d", state);
    
    switch (state) {
        case MPHangmanStateNew:
            NSLog(@"Read: currentWordCharacteristic, remainingGuessesCharacteristic");
            [self.peripheral readValueForCharacteristic:self.currentWordCharacteristic];
            [self.peripheral readValueForCharacteristic:self.remainingGuessesCharacteristic];
            [self updateGuessedLetters:@""];
            [self showKeyboard];
            break;
        case MPHangmanStateRight:
            NSLog(@"Read: currentWordCharacteristic, guessedLettersCharacteristic");
            [self.peripheral readValueForCharacteristic:self.currentWordCharacteristic];
            [self.peripheral readValueForCharacteristic:self.guessedLettersCharacteristic];
            [self showKeyboard];
            break;
        case MPHangmanStateWrong:
            NSLog(@"Read: remainingGuessesCharacteristic, guessedLettersCharacteristic");
            [self.peripheral readValueForCharacteristic:self.remainingGuessesCharacteristic];
            [self.peripheral readValueForCharacteristic:self.guessedLettersCharacteristic];
            [self showKeyboard];
            break;
        case MPHangmanStateWin:
            NSLog(@"Read: currentWordCharacteristic, guessedLettersCharacteristic");
            [self.peripheral readValueForCharacteristic:self.currentWordCharacteristic];
            [self.peripheral readValueForCharacteristic:self.guessedLettersCharacteristic];
            [self hideKeyboard];
            break;
        case MPHangmanStateLoss:
            NSLog(@"Read: remainingGuessesCharacteristic, guessedLettersCharacteristic");
            [self.peripheral readValueForCharacteristic:self.remainingGuessesCharacteristic];
            [self.peripheral readValueForCharacteristic:self.guessedLettersCharacteristic];
            [self hideKeyboard];
            break;
    }
}

- (void) updateCurrentWord:(NSString*)currentWord
{
    NSLog(@"Updated Current Word: %@", currentWord);
    self.currentWordLabel.text = currentWord;
}

- (void) updateRemainingGuesses:(uint8_t)remainingGuesses
{
    NSLog(@"Updated Remaining Guesses: %d", remainingGuesses);
    switch (remainingGuesses) {
        case 0:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_06"];
            break;
        case 1:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_05"];
            break;
        case 2:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_04"];
            break;
        case 3:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_03"];
            break;
        case 4:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_02"];
            break;
        case 5:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_01"];
            break;
        case 6:
            self.hangmanView.image = [UIImage imageNamed:@"hangman_00"];
            break;
    }
}

- (void) updateGuessedLetters:(NSString*)guessedLetters
{
    NSLog(@"Updated Guessed Letters: %@", guessedLetters);
    self.guessedLettersLabel.text = guessedLetters;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL) textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString *lower = [string lowercaseString];
    for (int i = 0; i < lower.length; i++) {
        [self guessLetter:[lower substringWithRange:NSMakeRange(i, 1)]];
    }
    return NO;
}

- (void) showKeyboard
{
    [self.hiddenField becomeFirstResponder];
}

- (void) hideKeyboard
{
    [self.hiddenField resignFirstResponder];
}

@end
