//
//  NotificationPeripheralDelegate.h
//  Hangman
//
//  Created by Aaron Day on 4/9/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

extern NSString* const kDiscoveredServices;
extern NSString* const kDiscoveredServicesForService;
extern NSString* const kDiscoveredCharacteristics;
extern NSString* const kDiscoveredDescriptors;
extern NSString* const kCharacteristicUpdated;
extern NSString* const kCharacteristicNotificationStateUpdated;

extern NSString* const kKeyService;
extern NSString* const kKeyCharacteristic;

@interface NotificationPeripheralDelegate : NSObject <CBPeripheralDelegate>

@end
