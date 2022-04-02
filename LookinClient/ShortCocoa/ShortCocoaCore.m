//
//  ShortCocoaCore.m
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"
#import <objc/runtime.h>

@implementation ShortCocoa

@synthesize get = _get;

- (instancetype)initWithObjectsCount:(uint)count objects:(nullable id)object,... {
    if (self = [self init]) {
        if (count == 1) {
            _get = object;
            
        } else if (count > 1) {
            int currentIndex = 1;
            
            NSMutableArray *array = nil;
            if (object) {
                array = [NSMutableArray array];
                [array addObject:object];
            }
            
            va_list args;
            va_start(args, object);
            id arg;
            while (currentIndex < count) {
                currentIndex++;
                
                arg = va_arg(args, id);
                if (!arg) {
                    // 传入了 nil
                    continue;
                }
                if (!array) {
                    array = [NSMutableArray array];
                }
                [array addObject:arg];
            }
            va_end(args);
            _get = array.count > 1 ? [array copy] : [array firstObject];
        }
    }
    return self;
}

id ShortCocoaMakeInstance(id object) {
    if (object_isClass(object)) {
        return [object new];
    }
    return object;
}

@end
