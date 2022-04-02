//
//  LKTableRowView.m
//  Lookin
//
//  Created by Li Kai on 2019/4/20.
//  https://lookin.work
//

#import "LKTableRowView.h"
#import "LookinDefines.h"

@interface LKTableRowView ()

@property(nonatomic, strong) CALayer *backgroundColorLayer;

@property(nonatomic, assign, readwrite) BOOL isDarkMode;

@end

@implementation LKTableRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        self.backgroundColorLayer = [CALayer layer];
        [self.backgroundColorLayer lookin_removeImplicitAnimations];
        [self.layer addSublayer:self.backgroundColorLayer];
        
        _titleLabel = [LKLabel new];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.titleLabel];
        
        _subtitleLabel = [LKLabel new];
        [self addSubview:self.subtitleLabel];
        
        self.isDarkMode = self.effectiveAppearance.lk_isDarkMode;
        
        [self _updateBackgroundLayerColor];
    }
    return self;
}

- (void)layout {
    [super layout];
    $(self.backgroundColorLayer).fullFrame;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    self.isDarkMode = self.effectiveAppearance.lk_isDarkMode;
    [self _updateBackgroundLayerColor];
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    [self _updateBackgroundLayerColor];
}

- (void)setIsHovered:(BOOL)isHovered {
    if (_isHovered == isHovered) {
        return;
    }
    _isHovered = isHovered;
    [self _updateBackgroundLayerColor];
}

- (void)_updateBackgroundLayerColor {
    if (self.isSelected) {
        self.backgroundColorLayer.backgroundColor = [LKHelper accentColor].CGColor;
    } else if (self.isHovered) {
        self.backgroundColorLayer.backgroundColor = self.isDarkMode ? LookinColorRGBAMake(255, 255, 255, .15).CGColor : LookinColorRGBAMake(0, 0, 0, .1).CGColor;
    } else {
        self.backgroundColorLayer.backgroundColor = [NSColor clearColor].CGColor;
    }
}

@end

@implementation LKTableBlankRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.contentWidth = 0;
    }
    return self;
}

@end
