//
//  MainView.m
//  Hangman
//
//  Created by Aaron Day on 11/27/13.
//  Copyright (c) 2013 Aaron Day. All rights reserved.
//

#import "MainView.h"
#import <IOBluetooth/IOBluetooth.h>

NSString* const MPHangmanServiceUUID = @"F64954AC-90A1-406F-813A-349EC9BE8106";
NSString* const MPHangmanStateCharacteristicUUID = @"F67F348F-ED86-4577-90DC-FA793AC5E967";
NSString* const MPHangmanCurrentWordCharacteristicUUID = @"39219AA3-BFD4-410F-AC05-EC489351C339";
NSString* const MPHangmanGuessLetterCharacteristicUUID = @"3278C646-1F5E-4DF4-AD53-90C78B49955E";
NSString* const MPHangmanGuessedLettersCharacteristicUUID = @"C974AF7A-6613-4337-8AB4-721DADF45DDF";
NSString* const MPHangmanRemainingGuessesCharacteristicUUID = @"D888B7C1-ADD5-44B9-B503-C581D8D55F1C";

@implementation MainView

- (id) initWithCoder:(NSCoder*)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setupPeripheralManager];
    }
    return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

#pragma mark -
#pragma mark CBPeripheralManager

- (void) setupPeripheralManager
{
    if (!self.peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void) setupGuessedLetters
{
    _guessedLetters = [[NSMutableArray alloc] init];
}

- (void) setupCharacteristics
{
    self.stateCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:MPHangmanStateCharacteristicUUID] properties:(CBCharacteristicPropertyRead|CBCharacteristicPropertyNotify) value:nil permissions:CBAttributePermissionsReadable];
    self.currentWordCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:MPHangmanCurrentWordCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    self.guessLetterCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:MPHangmanGuessLetterCharacteristicUUID] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
    self.guessedLettersCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:MPHangmanGuessedLettersCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    self.remainingGuessesCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:MPHangmanRemainingGuessesCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
}

- (void) setupHangmanService
{
    self.hangmanService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:MPHangmanServiceUUID] primary:YES];
    self.hangmanService.characteristics = @[self.stateCharacteristic, self.currentWordCharacteristic, self.guessLetterCharacteristic, self.guessedLettersCharacteristic, self.remainingGuessesCharacteristic];
}

- (void) addHangmanServiceToPeripheralManager
{
    [self.peripheralManager addService:self.hangmanService];
}

#pragma mark -
#pragma mark UI Updates

- (void) updateBeginButton
{
    self.beginButton.enabled = [self isPeripheralManagerReady] && ([self hasSecretWord] && ![self isGameActive]);
}

- (void) updateResetButton
{
    self.resetButton.enabled = [self isGameActive];
}

- (void) lockSecretWord
{
    self.secretWordInput.enabled = NO;
}

- (void) resetGuessedLetters
{
    [_guessedLetters removeAllObjects];
}

- (void) clearSecretWord
{
    [self.secretWordInput setStringValue:@""];
    self.secretWordInput.enabled = YES;
}

- (void) updateViews
{
    [self.currentWordView setStringValue:[self currentWord]];
    [self.guessedLettersView setStringValue:[[self guessedLetters] componentsJoinedByString:@""]];
    
    NSImage *image = nil;
    switch ([self remainingGuesses]) {
        case 0:
            image = [NSImage imageNamed:@"hangman_06"];
            break;
        case 1:
            image = [NSImage imageNamed:@"hangman_05"];
            break;
        case 2:
            image = [NSImage imageNamed:@"hangman_04"];
            break;
        case 3:
            image = [NSImage imageNamed:@"hangman_03"];
            break;
        case 4:
            image = [NSImage imageNamed:@"hangman_02"];
            break;
        case 5:
            image = [NSImage imageNamed:@"hangman_01"];
            break;
        case 6:
            image = [NSImage imageNamed:@"hangman_00"];
            break;
    }
    
    if (image) {
        self.hangmanView.image = image;
    }
}

#pragma mark -
#pragma mark State

- (BOOL) isPeripheralManagerReady
{
    return self.peripheralManager.state == CBPeripheralManagerStatePoweredOn;
}

- (BOOL) hasSecretWord
{
    return [self.secretWordInput.stringValue length] > 0;
}

- (BOOL) isGameActive
{
    return ![self.secretWordInput isEnabled];
}

- (void) guessLetter:(NSString*)letter
{
    NSLog(@"guessLetter: %@", letter);

    if (![_guessedLetters containsObject:letter]) {
        [_guessedLetters addObject:letter];
    }

    NSLog(@"_guessedLetters: %@", _guessedLetters);
    
    if ([self inSecret:letter]) {
        if ([self isWin]) {
            [self notifyWin];
        } else {
            [self notifyRight];
        }
    } else {
        if ([self isLoss]) {
            [self notifyLoss];
        } else {
            [self notifyWrong];
        }
    }
}

- (BOOL) inSecret:(NSString*)letter
{
    return ! ([self.secretWordInput.stringValue rangeOfString:letter].location == NSNotFound);
}

- (NSString*) currentWord
{
    NSMutableString *currentWord = [[NSMutableString alloc] initWithCapacity:[self.secretWordInput.stringValue length]];
    for (int i = 0; i < [self.secretWordInput.stringValue length]; i++) {
        NSString *current = [NSString stringWithFormat:@"%c", [self.secretWordInput.stringValue characterAtIndex:i]];
        NSString *next = nil;
        
        if ([current isEqualToString:@" "]) {
            next = @" ";
        } else if ([_guessedLetters containsObject:current]) {
            next = current;
        } else {
            next = @"_";
        }
        
        [currentWord appendString:next];
    }
    
    NSLog(@"secretWord: %@ currentWord: %@ _guessedLetters: %@", self.secretWordInput.stringValue, currentWord, _guessedLetters);
    
    return currentWord;
}

- (BOOL) isWin
{
    return [[self currentWord] rangeOfString:@"_"].location == NSNotFound;
}

- (BOOL) isLoss
{
    return [self remainingGuesses] == 0;
}

- (NSArray*) guessedLetters
{
    return [_guessedLetters sortedArrayUsingSelector:@selector(compare:)];
}

- (UInt8) remainingGuesses
{
    UInt8 missed = 0;
    
    for (NSString* letter in [self guessedLetters]) {
        missed += [self inSecret:letter] ? 0 : 1;
    }
    
    return 6 - missed;
}

#pragma mark -
#pragma mark Read & Write Values

- (NSData*) readValueForState
{
    NSData *data = [NSData dataWithBytes:&_state length:sizeof(_state)];
    NSLog(@"readValueForState: %@", data);
    return data;
}

- (NSData*) readValueForCurrentWord
{
    NSData *data = [[self currentWord] dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"readValueForCurrentWord: %@", data);
    return data;
}

- (NSData*) readValueForGuessedLetters
{
    NSData *data = [[[self guessedLetters] componentsJoinedByString:@""] dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"readValueForGuessedLetters: %@", data);
    return data;
}

- (NSData*) readValueForRemainingGuesses
{
    int remaining = [self remainingGuesses];
    NSData *data = [NSData dataWithBytes:&remaining length:sizeof(remaining)];
    NSLog(@"readValueForRemainingGuesses: %@", data);
    return data;
}

- (NSData*) writeGuessLetter:(NSData*)letter
{
    NSLog(@"writeGuessLetter: %@", letter);
    [self guessLetter:[[NSString alloc] initWithData:letter encoding:NSUTF8StringEncoding]];
    return letter;
}

#pragma mark -
#pragma mark Notification

- (void) notifyNew
{
    _state = MPHangmanStateNew;
    [self notifyUpdatedState];
}

- (void) notifyRight
{
    _state = MPHangmanStateRight;
    [self notifyUpdatedState];
}

- (void) notifyWrong
{
    _state = MPHangmanStateWrong;
    [self notifyUpdatedState];
}

- (void) notifyWin
{
    _state = MPHangmanStateWin;
    [self notifyUpdatedState];
}

- (void) notifyLoss
{
    _state = MPHangmanStateLoss;
    [self notifyUpdatedState];
}

- (BOOL) notifyUpdatedState
{
    return [self.peripheralManager updateValue:[self stateAsData] forCharacteristic:self.stateCharacteristic onSubscribedCentrals:nil];
}

- (NSData*) stateAsData
{
    NSData *data = [NSData dataWithBytes:&_state length:sizeof(_state)];
    
    return data;
}

#pragma mark -
#pragma mark Actions

- (IBAction) beginGame:(NSButton*)button
{
    [self lockSecretWord];
    [self resetGuessedLetters];
    [self updateBeginButton];
    [self updateResetButton];
    [self startAdvertising];
    [self notifyNew];
}

- (IBAction) resetGame:(NSButton*)button
{
    [self stopAdvertising];
    [self clearSecretWord];
    [self updateBeginButton];
    [self updateResetButton];
}

- (IBAction) serectWordChanged:(NSTextField*)textField
{
    [self updateBeginButton];
}

#pragma mark -
#pragma mark Bluetoothy Stuff

- (void) startAdvertising
{
    NSDictionary *options = @{
      CBAdvertisementDataServiceUUIDsKey:@[ self.hangmanService.UUID ],
      CBAdvertisementDataLocalNameKey:@"MarcoPolo"
    };
    
    NSLog(@"startAdvertising: %@", options);
    [self.peripheralManager startAdvertising:options];
}

- (void) stopAdvertising
{
    NSLog(@"stopAdvertising");
    [self.peripheralManager stopAdvertising];
}

#pragma mark -
#pragma mark - CBPeripheralManagerDelegate

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheralManager
{
    switch (peripheralManager.state) {
        case CBPeripheralManagerStateUnknown:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStateUnknown");
            break;
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStateUnsupported");
            break;
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStatePoweredOn");
            [self setupGuessedLetters];
            [self setupCharacteristics];
            [self setupHangmanService];
            [self addHangmanServiceToPeripheralManager];
            break;
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStateUnauthorized");
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStatePoweredOff");
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"CBPeripheralManager.state == CBPeripheralManagerStateResetting");
            break;
    }
}

- (void) peripheralManager:(CBPeripheralManager*)peripheralManager didAddService:(CBService*)service error:(NSError*)error
{
    NSLog(@"peripheralManager:didAddService: %@ error: %@", service, error);
    [self updateBeginButton];
}

- (void) peripheralManagerDidStartAdvertising:(CBPeripheralManager*)peripheralManager error:(NSError*)error
{
    NSLog(@"peripheralManagerDidStartAdvertising:error: %@", error);
}

- (void) peripheralManager:(CBPeripheralManager*)peripheralManager central:(CBCentral*)central didSubscribeToCharacteristic:(CBCharacteristic*)characteristic
{
    NSLog(@"peripheralManager:central: %@ didSubscribeToCharacteristic: %@", central, characteristic);
}

- (void) peripheralManager:(CBPeripheralManager*)peripheralManager central:(CBCentral*)central didUnsubscribeFromCharacteristic:(CBCharacteristic*)characteristic
{
    NSLog(@"peripheralManager:central: %@ didUnsubscribeFromCharacteristic: %@", central, characteristic);
}

- (void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)peripheralManager
{
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers:");
}

- (void) peripheralManager:(CBPeripheralManager*)peripheralManager didReceiveReadRequest:(CBATTRequest*)request
{
    NSLog(@"peripheralManager:didReceiveReadRequest: %@", request);
    
    if ([request.characteristic isEqual:self.stateCharacteristic]) {
        request.value = [self readValueForState];
    } else if ([request.characteristic isEqual:self.currentWordCharacteristic]) {
        request.value = [self readValueForCurrentWord];
    } else if ([request.characteristic isEqual:self.guessedLettersCharacteristic]) {
        request.value = [self readValueForGuessedLetters];
    } else if ([request.characteristic isEqual:self.remainingGuessesCharacteristic]) {
        request.value = [self readValueForRemainingGuesses];
    }
    
    if (request.value) {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    } else {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorAttributeNotFound];
    }
    
    [self updateViews];
}

- (void) peripheralManager:(CBPeripheralManager*)peripheralManager didReceiveWriteRequests:(NSArray*)requests
{
    NSLog(@"peripheralManager:didReceiveWriteRequests: %@", requests);
    
    CBATTError error = CBATTErrorAttributeNotFound;
    CBATTRequest *first = [requests firstObject];
    
    for (CBATTRequest *request in requests) {
        if ([request.characteristic isEqual:self.guessLetterCharacteristic]) {
            [self guessLetter:[[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding]];
            error = CBATTErrorSuccess;
        }
    }
    
    [self.peripheralManager respondToRequest:first withResult:error];
}

@end
