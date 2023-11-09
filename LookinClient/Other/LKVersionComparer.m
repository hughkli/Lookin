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
    NSInteger latestNumber = [latest lookin_numbericOSVersion];
    NSInteger userNumber = [user lookin_numbericOSVersion];
    if (latestNumber == 0 || userNumber == 0) {
        return YES;
    }
    if (userNumber >= latestNumber) {
        return YES;
    }
    return NO;
}

@end
