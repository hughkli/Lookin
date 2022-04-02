//
//  LKTwoColors.h
//  Lookin
//
//  Created by Li Kai on 2019/9/30.
//  https://lookin.work
//

#import <Foundation/Foundation.h>

/// colorA 是浅色模式下的颜色，colorB 是深色模式下的颜色
#define LKColorsCombine(colorA, colorB) [LKTwoColors colorsWithColorInLightMode:colorA colorInDarkMode:colorB]

@interface LKTwoColors : NSObject

+ (instancetype)colorsWithColorInLightMode:(NSColor *)colorInLightMode colorInDarkMode:(NSColor *)colorInDarkMode;

/// 如果当前是 darkMode 则该方法返回 colorInDarkMode，否则返回 colorInLightMode
@property(nonatomic, strong, readonly) NSColor *color;

@property(nonatomic, strong) NSColor *colorInLightMode;
@property(nonatomic, strong) NSColor *colorInDarkMode;

@end
