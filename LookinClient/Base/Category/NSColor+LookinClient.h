//
//  NSColor+LookinClient.h
//  Lookin
//
//  Created by Li Kai on 2019/5/17.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface NSColor (LookinClient)

/**
 如果 alpha 为 1 则返回诸如 (15, 17, 19) 这样的格式
 如果 alpha 小于 1 则返回诸如 (15, 17, 19, 0.5) 这样的格式
 */
- (NSString *)rgbaString;

- (NSString *)hexString;

- (NSArray<NSNumber *> *)lk_rgbaComponents;

+ (instancetype)lk_colorFromRGBAComponents:(NSArray<NSNumber *> *)components;

@end
