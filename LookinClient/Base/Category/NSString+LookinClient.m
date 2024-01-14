//
//  NSString+LookinClient.m
//  Lookin
//
//  Created by Li Kai on 2019/9/29.
//  https://lookin.work
//

#import "NSString+LookinClient.h"
#import <AppKit/AppKit.h>
#import "Lookin-Swift.h"

@implementation NSString (LookinClient)

- (NSString *)lk_capitalizedString {
    if (self.length) {
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];        
    }
    return nil;
}

- (NSString *)lk_demangledSwiftName {
    return [LKSwiftDemangler parseWithInput:self];
}

@end
