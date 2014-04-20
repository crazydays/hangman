//
//  CBUUID+UUIDString.m
//  Hangman
//
//  Created by Aaron Day on 4/20/14.
//  Copyright (c) 2014 Aaron Day. All rights reserved.
//

#import "CBUUID+UUIDString.h"

@implementation CBUUID (UUIDString)

- (NSString*) UUIDString
{
    NSLog(@"Hello...");
    NSUInteger length = [self.data length];
    const unsigned char *uuidBytes = [self.data bytes];

    NSMutableString *uuidString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger i = 0; i < length; i++)
    {
        [uuidString appendFormat:@"%02X", uuidBytes[i]];

        if (i == 3 || i == 5 || i == 7 || i == 9) {
            [uuidString appendString:@"-"];
        }
    }
    
    return uuidString;
}

@end
