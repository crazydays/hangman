//
//  NotificationPeripheralDelegate.m
//  Hangman
//
//  Created by Aaron Day on 4/9/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import "NotificationCentralManagerDelegate.h"

#import "NotificationPeripheralDelegate.h"

NSString* const kDiscoveredServices = @"PeripheralDiscoveredServices";
NSString* const kDiscoveredServicesForService = @"PeripheralDiscoveredServicesForService";
NSString* const kDiscoveredCharacteristics = @"PeripheralDiscoveredCharacteristics";
NSString* const kDiscoveredDescriptors = @"PeripheralDiscoveredDescriptors";
NSString* const kCharacteristicUpdated = @"CharacteristicUpdated";
NSString* const kCharacteristicNotificationStateUpdated = @"CharacteristicNotificationStateUpdated";

NSString* const kKeyService = @"Service";
NSString* const kKeyCharacteristic = @"Characteristic";

@implementation NotificationPeripheralDelegate

- (void) peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    NSLog(@"peripheral:didDiscoverServices:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoveredServices object:peripheral userInfo:@{ kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheral:(CBPeripheral*)peripheral didDiscoverIncludedServicesForService:(CBService*)service error:(NSError*)error
{
    NSLog(@"peripheral:didDiscoverIncludedServicesForService:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoveredServicesForService object:peripheral userInfo:@{ kKeyService:service, kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    NSLog(@"peripheral:didDiscoverCharacteristicsForService:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoveredCharacteristics object:peripheral userInfo:@{ kKeyService:service, kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheral:(CBPeripheral*)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"peripheral:didDiscoverDescriptorsForCharacteristic:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoveredDescriptors object:peripheral userInfo:@{ kKeyCharacteristic:characteristic, kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"peripheral:didUpdateValueForCharacteristic:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kCharacteristicUpdated object:peripheral userInfo:@{ kKeyCharacteristic:characteristic, kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheral:(CBPeripheral*)peripheral didUpdateValueForDescriptor:(CBDescriptor*)descriptor error:(NSError*)error
{
    NSLog(@"peripheral:didUpdateValueForDescriptor:error:%@", error);
}

- (void) peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"peripheral:didWriteValueForCharacteristic:error:%@", error);
}

- (void) peripheral:(CBPeripheral*)peripheral didWriteValueForDescriptor:(CBDescriptor*)descriptor error:(NSError*)error
{
    NSLog(@"peripheral:didWriteValueForDescriptor:error:%@", error);
}

- (void) peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"peripheral:didUpdateNotificationStateForCharacteristic:error:%@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kCharacteristicNotificationStateUpdated object:peripheral userInfo:@{ kKeyCharacteristic:characteristic, kKeyError:(error ? error : [NSNull null]) }];
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral*)peripheral error:(NSError*)error
{
    NSLog(@"peripheralDidUpdateRSSI:error:%@", error);
}

@end
