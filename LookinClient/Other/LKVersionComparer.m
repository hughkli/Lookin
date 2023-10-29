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
    NSInteger latestNumber = [self numbericOSVersion:latest];
    NSInteger userNumber = [self numbericOSVersion:user];
    if (latestNumber == 0 || userNumber == 0) {
        return YES;
    }
    if (userNumber >= latestNumber) {
        return YES;
    }
    return NO;
}

/// 数字形式的操作系统版本号，可直接用于大小比较；如 110205 代表 11.2.5 版本；根据 iOS 规范，版本号最多可能有3位
+ (NSInteger)numbericOSVersion:(NSString *)text {
    if (!text || text.length == 0) {
        NSAssert(NO, @"");
        return 0;
    }
    NSArray *versionArr = [text componentsSeparatedByString:@"."];
    if (versionArr.count != 3) {
        NSAssert(NO, @"");
        return 0;
    }
    
    NSInteger numbericOSVersion = 0;
    NSInteger pos = 0;
    
    while ([versionArr count] > pos && pos < 3) {
        numbericOSVersion += ([[versionArr objectAtIndex:pos] integerValue] * pow(10, (4 - pos * 2)));
        pos++;
    }
    
    return numbericOSVersion;
}

@end
