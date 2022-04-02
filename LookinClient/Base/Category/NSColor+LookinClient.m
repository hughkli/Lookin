//
//  NSColor+LookinClient.m
//  Lookin
//
//  Created by Li Kai on 2019/5/17.
//  https://lookin.work
//

#import "NSColor+LookinClient.h"

@implementation NSColor (LookinClient)

- (NSArray<NSNumber *> *)lk_rgbaComponents {
    NSColor *rgbColor = [self colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    NSArray<NSNumber *> *rgba = @[@(r), @(g), @(b), @(a)];
    return rgba;
}

+ (instancetype)lk_colorFromRGBAComponents:(NSArray<NSNumber *> *)components {
    if (!components) {
        return nil;
    }
    if (components.count != 4) {
        NSAssert(NO, @"");
        return nil;
    }
    NSColor *color = [NSColor colorWithRed:components[0].doubleValue green:components[1].doubleValue blue:components[2].doubleValue alpha:components[3].doubleValue];
    return color;
}

- (NSString *)rgbaString {
    NSColor *rgbColor = [self colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    
    if (a >= 1) {
        return [NSString stringWithFormat:@"(%.0f, %.0f, %.0f)", r * 255, g * 255, b * 255];
    } else {
        return [NSString stringWithFormat:@"(%.0f, %.0f, %.0f, %.2f)", r * 255, g * 255, b * 255, a];
    }
}

- (NSString *)hexString {
    NSColor *rgbColor = [self colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    
    NSInteger red = r * 255;
    NSInteger green = g * 255;
    NSInteger blue = b * 255;
    NSInteger alpha = a * 255;
    
    NSString *rString = [NSColor _alignColorHexStringLength:[NSColor _hexStringWithInteger:red]];
    NSString *gString = [NSColor _alignColorHexStringLength:[NSColor _hexStringWithInteger:green]];
    NSString *bString = [NSColor _alignColorHexStringLength:[NSColor _hexStringWithInteger:blue]];
    NSString *aString = [NSColor _alignColorHexStringLength:[NSColor _hexStringWithInteger:alpha]];
    
    if (a >= 1) {
        return [[NSString stringWithFormat:@"#%@%@%@", rString, gString, bString] lowercaseString];
    }
    return [[NSString stringWithFormat:@"#%@%@%@%@", rString, gString, bString, aString] lowercaseString];
}

// 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
+ (NSString *)_alignColorHexStringLength:(NSString *)hexString {
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (NSString *)_hexStringWithInteger:(NSInteger)integer {
    NSString *hexString = @"";
    NSInteger remainder = 0;
    for (NSInteger i = 0; i < 9; i++) {
        remainder = integer % 16;
        integer = integer / 16;
        NSString *letter = [self _hexLetterStringWithInteger:remainder];
        hexString = [letter stringByAppendingString:hexString];
        if (integer == 0) {
            break;
        }
        
    }
    return hexString;
}

+ (NSString *)_hexLetterStringWithInteger:(NSInteger)integer {
    NSAssert(integer < 16, @"要转换的数必须是16进制里的个位数，也即小于16，但你传给我是%@", @(integer));
    
    NSString *letter = nil;
    switch (integer) {
        case 10:
            letter = @"A";
            break;
        case 11:
            letter = @"B";
            break;
        case 12:
            letter = @"C";
            break;
        case 13:
            letter = @"D";
            break;
        case 14:
            letter = @"E";
            break;
        case 15:
            letter = @"F";
            break;
        default:
            letter = [[NSString alloc]initWithFormat:@"%@", @(integer)];
            break;
    }
    return letter;
}

@end
