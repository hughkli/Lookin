//
//  LKVersionComparer.m
//  LookinClient
//
//  Created by likai.123 on 2023/10/30.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LKVersionComparer.h"

@implementation LKVersionComparer

+ (BOOL)compareWithNewest:(NSString *)latest user:(NSString *)user {
    return [self compareWithExpectedVersion:latest realVersion:user];
}

+ (BOOL)compareWithExpectedVersion:(NSString *)expectedVersion realVersion:(NSString *)realVersion {
    NSInteger expectedNumber = [expectedVersion lookin_numbericOSVersion];
    NSInteger realNumber = [realVersion lookin_numbericOSVersion];
    if (expectedNumber == 0 || realNumber == 0) {
        NSAssert(NO, @"");
        return NO;
    }
    if (realNumber >= expectedNumber) {
        return YES;
    }
    return NO;
}

@end
