//
//  LookinObject+LookinClient.m
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinObject+LookinClient.h"

@implementation LookinObject (LookinClient)

- (NSString *)lk_demangledNoModuleClassName {
    NSString *rawName = self.rawClassName;
    NSString *demangled = [rawName lk_demangledSwiftName];
    NSString *result = [demangled componentsSeparatedByString:@"."].lastObject;
    return result;
}

@end
