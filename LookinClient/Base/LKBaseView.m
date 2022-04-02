//
//  LKBaseView.m
//  Lookin
//
//  Created by Li Kai on 2018/8/4.
//  https://lookin.work
//

#import "LKBaseView.h"

@interface LKBaseView ()

@property(nonatomic, strong) CALayer *customBorderLayer;
@property(nonatomic, strong) LKVisualEffectView *backgroundEffectView;

@end

@implementation LKBaseView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        self.borderColors = LKColorsCombine(SeparatorLightModeColor, SeparatorDarkModeColor);
        
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [NSColor redColor].CGColor;
    }
    return self;
}

- (BOOL)isVisible {
    BOOL isVisible = self.superview && !self.hidden && self.alphaValue >= 0.01;
    return isVisible;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setBackgroundColors:(LKTwoColors *)backgroundColors {
    _backgroundColors = backgroundColors;
    [self updateColors];
}

- (void)setBorderColors:(LKTwoColors *)borderColors {
    _borderColors = borderColors;
    [self updateColors];
}

- (void)setBorderPosition:(LKViewBorderPosition)borderPosition {
    _borderPosition = borderPosition;
    if (borderPosition == LKViewBorderPositionNone) {
        [self.customBorderLayer removeFromSuperlayer];
        return;
    }
    if (!self.customBorderLayer) {
        self.customBorderLayer = [CALayer layer];
        [self.customBorderLayer lookin_removeImplicitAnimations];
        [self updateColors];
        [self.layer addSublayer:self.customBorderLayer];
    }
    [self setNeedsLayout:YES];
}

- (BOOL)isFlipped {
    return YES;
}

- (NSView *)hitTest:(NSPoint)point {
    if (self.hidden || self.alphaValue <= 0) {
        return nil;
    }
    return [super hitTest:point];
}

- (void)layout {
    [super layout];
    
    if (self.backgroundEffectView) {
        $(self.backgroundEffectView).fullFrame;        
    }
    
    if (self.tooltipString) {
        [self addToolTipRect:self.bounds owner:self userData:nil];
    } else {
        [self removeAllToolTips];
    }
    
    switch (self.borderPosition) {
        case LKViewBorderPositionNone:
            break;
        case LKViewBorderPositionTop:
            $(self.customBorderLayer).fullWidth.height(1).y(0);
            break;
        case LKViewBorderPositionLeft:
            $(self.customBorderLayer).fullHeight.width(1).x(0);
            break;
        case LKViewBorderPositionBottom:
            $(self.customBorderLayer).fullFrame.height(1).bottom(0);
            break;
        case LKViewBorderPositionRight:
            $(self.customBorderLayer).fullHeight.width(1).right(0);
            break;
    }
    
    if (self.didLayout) {
        self.didLayout();
    }
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data {
    return self.tooltipString;
}

- (void)setTooltipString:(NSString *)tooltipString {
    _tooltipString = tooltipString;
    if (tooltipString) {
        [self addToolTipRect:self.bounds owner:self userData:nil];
    } else {
        [self removeAllToolTips];
    }
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = [self sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height;
    return height;
}

- (void)updateLayer {
    [super updateLayer];
    if (self.backgroundColorName) {
        self.layer.backgroundColor = [NSColor colorNamed:self.backgroundColorName].CGColor;
    }
}

- (void)viewDidChangeEffectiveAppearance {
    [self _triggerDidChangeAppearanceBlock];
}

- (void)setDidChangeAppearanceBlock:(void (^)(LKBaseView *, BOOL))didChangeAppearance {
    _didChangeAppearanceBlock = didChangeAppearance;
    [self _triggerDidChangeAppearanceBlock];
}

- (void)_triggerDidChangeAppearanceBlock {
    if (self.didChangeAppearanceBlock) {
        self.didChangeAppearanceBlock(self, [self isDarkMode]);
    }
    [self updateColors];
}

- (void)updateColors {
    if (self.backgroundColors) {
        self.layer.backgroundColor = self.backgroundColors.color.CGColor;
    }
    if (self.borderColors) {
        self.layer.borderColor = self.borderColors.color.CGColor;
        self.customBorderLayer.backgroundColor = self.borderColors.color.CGColor;
    }
}

- (BOOL)isDarkMode {
    return [self.effectiveAppearance lk_isDarkMode];
}

- (void)setHasEffectedBackground:(BOOL)hasEffectedBackground {
    _hasEffectedBackground = hasEffectedBackground;
    if (hasEffectedBackground) {
        if (self.backgroundEffectView) {
            return;
        }
        self.backgroundEffectView = [LKVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self lk_insertSubviewAtBottom:self.backgroundEffectView];
        [self setNeedsLayout:YES];
    } else {
        [self.backgroundEffectView removeFromSuperview];
        self.backgroundEffectView = nil;
    }
}

@end

@implementation LKBaseView (SubslassingHooks)

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    return NSZeroSize;
}

- (void)sizeToFit {
}

@end

@implementation LKVisualEffectView

- (BOOL)isFlipped {
    return YES;
}

@end
