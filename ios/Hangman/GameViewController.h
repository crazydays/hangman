//
//  GameViewController.h
//  Hangman
//
//  Created by Aaron Day on 4/8/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString* const kGameViewControllerIdentifier;

typedef NS_OPTIONS(UInt8, MPHangmanState) {
    MPHangmanStateNew   = 0x00,
    MPHangmanStateRight = 0x01,
    MPHangmanStateWrong = 0x02,
    MPHangmanStateWin   = 0x03,
    MPHangmanStateLoss  = 0x04
};

@interface GameViewController : UIViewController <UITextFieldDelegate>

@property CBCentralManager *centralManager;
@property CBPeripheral *peripheral;
@property CBService *hangmanService;
@property CBCharacteristic *stateCharacteristic;
@property CBCharacteristic *currentWordCharacteristic;
@property CBCharacteristic *guessLetterCharacteristic;
@property CBCharacteristic *guessedLettersCharacteristic;
@property CBCharacteristic *remainingGuessesCharacteristic;

@end
