//
//  NotificationCentralManagerDelegate.h
//  Hangman
//
//  Created by Aaron Day on 4/9/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

extern NSString* const kCentralManagerAvailable;
extern NSString* const kCentralManagerUnavailable;

extern NSString* const kPeripheralDiscovered;
extern NSString* const kPeripheralConnected;
extern NSString* const kPeripheralFailedToConnect;
extern NSString* const kPeripheralDisconnected;

extern NSString* const kKeyAdvertisementData;
extern NSString* const kKeyRssi;
extern NSString* const kKeyError;

@interface NotificationCentralManagerDelegate : NSObject <CBCentralManagerDelegate>

@end
