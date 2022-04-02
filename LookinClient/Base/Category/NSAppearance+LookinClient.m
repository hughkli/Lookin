//
//  NSAppearance+macOS.m
//  Lookin
//
//  Created by Li Kai on 2019/3/4.
//  https://lookin.work
//

#import "NSAppearance+LookinClient.h"

@implementation NSAppearance (macOS)

- (BOOL)lk_isDarkMode {
    if (__builtin_available(macOS 10.14, *)) {
        if ([self.name isEqualToString:NSAppearanceNameDarkAqua]
            || [self.name isEqualToString:NSAppearanceNameVibrantDark]
            || [self.name isEqualToString:NSAppearanceNameAccessibilityHighContrastDarkAqua]
            || [self.name isEqualToString:NSAppearanceNameAccessibilityHighContrastVibrantDark]) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
}

@end
