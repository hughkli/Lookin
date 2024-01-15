//
//  LookinObject+LookinClient.m
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinObject+LookinClient.h"
#import "Lookin-Swift.h"

@implementation LookinObject (LookinClient)

- (NSString *)lk_completedDemangledClassName {
    return [LKSwiftDemangler completedParseWithInput:self.rawClassName];
}

- (NSString *)lk_simpleDemangledClassName {
    NSString *name = [LKSwiftDemangler simpleParseWithInput:self.rawClassName];
    // 理论上可能有 bad case，比如 xx<aaa.bbb>，期望拿到 xx 但是这里会拿到 bbb……不过似乎没发现过，所以先这样简单处理吧
    NSString *result = [name componentsSeparatedByString:@"."].lastObject;
    return result;
}

@end
