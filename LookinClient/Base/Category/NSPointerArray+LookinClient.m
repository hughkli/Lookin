//
//  NSPointerArray+LookinClient.m
//  Lookin
//
//  Created by Li Kai on 2019/5/9.
//  https://lookin.work
//

#import "NSPointerArray+LookinClient.h"

@implementation NSPointerArray (LookinClient)

- (NSUInteger)lk_indexOfPointer:(nullable void *)pointer {
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)lk_containsPointer:(void *)pointer {
    if (!pointer) {
        return NO;
    }
    if ([self lk_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
