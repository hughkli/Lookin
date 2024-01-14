//
//  LookinObject+LookinClient.h
//  LookinClient
//
//  Created by likai.123 on 2024/1/14.
//  Copyright © 2024 hughkli. All rights reserved.
//

#import "LookinObject.h"

@interface LookinObject (LookinClient)

/// 这里返回的类名已经被 demangle 过，但是【有 module 前缀】
- (NSString *)lk_demangledClassName;

/// 这里返回的类名已经被 demangle 过，并且【没有 module 前缀】
- (NSString *)lk_demangledNoModuleClassName;

@end
