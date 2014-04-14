//
//  MainView.h
//  Hangman
//
//  Created by Aaron Day on 11/27/13.
//  Copyright (c) 2013 Aaron Day. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

extern NSString* const MPHangmanServiceUUID;
extern NSString* const MPHangmanStateCharacteristicUUID;
extern NSString* const MPHangmanCurrentWordCharacteristicUUID;
extern NSString* const MPHangmanGuessLetterCharacteristicUUID;
extern NSString* const MPHangmanGuessedLettersCharacteristicUUID;
extern NSString* const MPHangmanRemainingGuessesCharacteristicUUID;

typedef NS_OPTIONS(UInt8, MPHangmanState) {
    MPHangmanStateNew   = 0x00,
    MPHangmanStateRight = 0x01,
    MPHangmanStateWrong = 0x02,
    MPHangmanStateWin   = 0x03,
    MPHangmanStateLoss  = 0x04
};

@interface MainView : NSView <CBPeripheralManagerDelegate>
{
    NSMutableArray *_guessedLetters;
    MPHangmanState _state;
}

@property IBOutlet NSTextField *secretWordInput;
@property IBOutlet NSButton *beginButton;
@property IBOutlet NSButton *resetButton;
@property IBOutlet NSTextField *currentWordView;
@property IBOutlet NSTextField *guessedLettersView;
@property IBOutlet NSImageView *hangmanView;

- (IBAction) beginGame:(NSButton*)button;
- (IBAction) resetGame:(NSButton*)button;
- (IBAction) serectWordChanged:(NSTextField*)textField;

@property (strong) CBPeripheralManager *peripheralManager;
@property (strong) CBMutableService *hangmanService;
@property (strong) CBMutableCharacteristic *stateCharacteristic;
@property (strong) CBMutableCharacteristic *currentWordCharacteristic;
@property (strong) CBMutableCharacteristic *guessLetterCharacteristic;
@property (strong) CBMutableCharacteristic *guessedLettersCharacteristic;
@property (strong) CBMutableCharacteristic *remainingGuessesCharacteristic;

@end
