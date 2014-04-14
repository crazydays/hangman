//
//  NotificationCentralManagerDelegate.m
//  Hangman
//
//  Created by Aaron Day on 4/9/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import "NotificationCentralManagerDelegate.h"

NSString* const kCentralManagerAvailable = @"CentralManagerAvailable";
NSString* const kCentralManagerUnavailable = @"CentralManagerAvailable";

NSString* const kPeripheralDiscovered = @"PeripheralDiscovered";
NSString* const kPeripheralConnected = @"PeripheralConnected";
NSString* const kPeripheralFailedToConnect = @"PeripheralFailedToConnect";
NSString* const kPeripheralDisconnected = @"PeripheralDisconnected";

NSString* const kKeyAdvertisementData = @"AdvertisementData";
NSString* const kKeyRssi = @"Rssi";
NSString* const kKeyError = @"Error";

@implementation NotificationCentralManagerDelegate

#pragma mark -
#pragma mark CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager*)centralManager
{
    NSLog(@"centralManagerDidUpdateState:");
    
    NSString *notificationName = nil;
    
    switch (centralManager.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"state: CBCentralManagerStatePoweredOff");
            notificationName = kCentralManagerUnavailable;
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"state: CBCentralManagerStatePoweredOn");
            notificationName = kCentralManagerAvailable;
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"state: CBCentralManagerStatePoweredOff");
            notificationName = kCentralManagerUnavailable;
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"state: CBCentralManagerStateResetting");
            notificationName = kCentralManagerUnavailable;
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"state: CBCentralManagerStateUnauthorized");
            notificationName = kCentralManagerUnavailable;
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"state: CBCentralManagerStateUnsupported");
            notificationName = kCentralManagerUnavailable;
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:centralManager];
}

- (void) centralManager:(CBCentralManager*)centralManager didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    NSLog(@"centralManager:didDiscoverPeripheral:%@ advertisementData:%@ RSSI:%@", peripheral, advertisementData, RSSI);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralDiscovered object:peripheral userInfo:@{ kKeyAdvertisementData:advertisementData, kKeyRssi:RSSI }];
}

- (void) centralManager:(CBCentralManager*)centralManager didConnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"centralManager:didConnectPeripheral:%@", peripheral);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralConnected object:peripheral];
}

- (void) centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    NSLog(@"centralManager:didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralFailedToConnect object:peripheral userInfo:@{ kKeyError:(error ? error : [NSNull null]) }];
}

- (void) centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    NSLog(@"centralManager:didDisconnectPeripheral:%@ error:%@", peripheral, error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralDisconnected object:peripheral userInfo:@{ kKeyError:(error ? error : [NSNull null]) }];
}

@end
