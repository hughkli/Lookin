//
//  LKTwoColors.m
//  Lookin
//
//  Created by Li Kai on 2019/9/30.
//  https://lookin.work
//

#import "LKTwoColors.h"

@implementation LKTwoColors

+ (instancetype)colorsWithColorInLightMode:(NSColor *)colorInLightMode colorInDarkMode:(NSColor *)colorInDarkMode {
    LKTwoColors *colors = [LKTwoColors new];
    colors.colorInLightMode = colorInLightMode;
    colors.colorInDarkMode = colorInDarkMode;
    return colors;
}

- (NSColor *)color {
    BOOL isDarkMode = [NSApp effectiveAppearance].lk_isDarkMode;
    if (isDarkMode) {
        return self.colorInDarkMode;
    } else {
        return self.colorInLightMode;
    }
}

@end
