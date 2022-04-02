//
//  ShortCocoaDefines.h
//  ShortCocoa
//
//  Copyright © 2018年 hughkli. All rights reserved.
//

/**
 *  属于 ShortCocoaColor 的对象：
 *  1）UIColor(iOS) 或 NSColor(macOS)
 *  2）RGB/RGBA 格式的字符串，中间用逗号隔开，RGB 的范围是 0 ~ 255，A 的范围是 0 ~ 1。比如：@"155, 233, 245"，@"0, 255, 3, 0.5"
 *  3）HEX 格式的字符串，格式可以是 RGB、ARGB、RRGGBB、AARRGGBB，比如：@"ff00ff"
 *  4）@"red"等表意字符串，支持列表：@"clear", @"white", @"black", @"gray", @"red", @"green", @"blue", @"yellow"
 */
typedef id ShortCocoaColor;

/**
 *  属于 ShortCocoaQuad 的对象：
 *  1）字符串，用逗号","隔开，允许 1 ~ 4 个值，比如 @"10, 15, 20, 25"
 *  2）NSNumber 对象，比如 @20
 *  3）NSArray 对象，允许 1 ~ 4 个值，比如 @[@10, @20, @30, @40]
 *
 *  四个值：@"10, 20, 30, 40"
 *  三个值：@"10, 20, 30" 等价于 @"10, 20, 30, 20"
 *  两个值：@"10, 20" 等价于 @"10, 20, 10, 20"
 *  一个值：@"10" 或 @10 等价于 @"10, 10, 10, 10"
 */
typedef id ShortCocoaQuad;

/**
 *  属于 ShortCocoaImage 的对象：
 *  1）UIImage(iOS) 或 NSImage(macOS)
 *  2）NSString，比如 @"icon" 等价于 [UIImage imageNamed:@"icon"] 或 [NSImage imageNamed:@"icon"]
 */
typedef id ShortCocoaImage;

/**
 *  属于 ShortCocoaFont 的对象：
 *  1）UIFont
 *  2）字符串或 NSNumber，比如 @"15"、@15 等价于 [UIFont systemFontOfSize:15]
 */
typedef id ShortCocoaFont;

/**
 *  属于 ShortCocoaString 的对象：
 *  1）NSString
 *  2）NSAttributedString
 *  3）NSNumber，比如 @(20.3) 将被看做是 @"20.3"
 *  4）NSArray，比如 @[@"a", @2]，它将被拼为 @"a2"。该数组里支持 NSString, NSAttributedString, NSNumber 对象。
 *  5）ShortCocoa，比如 $(@"abc")，它将被转换为 @"abc"。比如 $(attrString)，它将被转换为 attrString
 */
typedef id ShortCocoaString;
