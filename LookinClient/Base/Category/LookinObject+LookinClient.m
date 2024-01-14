//
//  LookinObject+LookinClient.m
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinObject+LookinClient.h"

@implementation LookinObject (LookinClient)

- (NSString *)lk_demangledClassName {
    return [self.rawClassName lk_demangledSwiftName];
}

- (NSString *)lk_demangledNoModuleClassName {
    NSString *demangled = [self lk_demangledClassName];
    NSString *result = [demangled componentsSeparatedByString:@"."].lastObject;
    return result;
}

@end
