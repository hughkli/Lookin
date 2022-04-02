//
//  LKColorIndicatorLayer.h
//  Lookin
//
//  Created by Li Kai on 2019/1/19.
//  https://lookin.work
//

#import <AppKit/AppKit.h>

/// 当 backgroundColor
@interface LKColorIndicatorLayer : CALayer

/// 默认为 (0, 0, 0)
@property(nonatomic, strong) NSColor *color;

+ (NSImage *)imageWithColor:(NSColor *)color shapeSize:(NSSize)shapeSize insets:(NSEdgeInsets)insets;

@end
