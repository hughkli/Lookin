//
//  LKBaseView.h
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKTwoColors;

typedef NS_ENUM(NSInteger, LKViewBorderPosition) {
    LKViewBorderPositionNone,
    LKViewBorderPositionTop,
    LKViewBorderPositionLeft,
    LKViewBorderPositionBottom,
    LKViewBorderPositionRight
};

@interface LKBaseView : NSView

@property(nonatomic, copy) NSString *tooltipString;

@property(nonatomic, strong) NSColor *backgroundColor;

@property(nonatomic, strong) LKTwoColors *backgroundColors;

/// 可以单独设置某一条边有 border，颜色由 borderColors 属性决定，注意通过这个属性设置了单边 border 后，就不要再使用系统的 layer.border 接口来设置四边 border 了
/// 默认为 LKViewBorderPositionNone
@property(nonatomic, assign) LKViewBorderPosition borderPosition;

/// 通过系统的 layer.border 接口和上面的 borderPosition 接口设置的 border 均可被该属性影响到
/// 默认为 SeparatorLightModeColor / SeparatorDarkModeColor
@property(nonatomic, strong) LKTwoColors *borderColors;

@property(nonatomic, assign, readonly) BOOL isVisible;

- (CGFloat)heightForWidth:(CGFloat)width;

/// 当设置该 block 之后，该 block 会立即被调用一次
@property(nonatomic, copy) void (^didChangeAppearanceBlock)(LKBaseView *view, BOOL isDarkMode);

- (BOOL)isDarkMode;

/// 用户切换主题时，该方法会被调用
- (void)updateColors NS_REQUIRES_SUPER;

@property(nonatomic, copy) void (^didLayout)(void);

/// 是否磨砂背景
@property(nonatomic, assign) BOOL hasEffectedBackground;

@end

@interface LKBaseView (SubslassingHooks)

- (NSSize)sizeThatFits:(NSSize)limitedSize;

- (void)sizeToFit;

@end

@interface LKVisualEffectView : NSVisualEffectView

@end
