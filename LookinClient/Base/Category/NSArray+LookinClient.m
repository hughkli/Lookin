//
//  NSArray+LookinClient.m
//  Lookin
//
//  Created by Li Kai on 2019/8/14.
//  https://lookin.work
//

#import "NSArray+LookinClient.h"
#import <AppKit/AppKit.h>

@implementation NSArray (LookinClient)

- (NSArray *)lk_visibleViews {
    NSArray *newArray = [self lookin_filter:^BOOL(id obj) {
        if ([obj isKindOfClass:[NSView class]]) {
            return ![((NSView *)obj) isHidden];
        } else {
            NSAssert(NO, @"");
            return NO;
        }
    }];
    return newArray;
}

@end
