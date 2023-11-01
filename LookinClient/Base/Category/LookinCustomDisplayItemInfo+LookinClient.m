//
//  LookinCustomDisplayItemInfo+LookinClient.m
//  LookinClient
//
//  Created by likai.123 on 2023/11/1.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LookinCustomDisplayItemInfo+LookinClient.h"

@implementation LookinCustomDisplayItemInfo (LookinClient)

- (BOOL)hasValidFrame {
    if (!self.frameInWindow) {
        return NO;
    }
    CGRect rect = [self.frameInWindow rectValue];
    BOOL valid = [LKHelper validateFrame:rect];
    return valid;
}

@end
