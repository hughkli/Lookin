//
//  LKBaseControl.m
//  Lookin
//
//  Created by Li Kai on 2018/8/28.
//  https://lookin.work
//

#import "LKBaseControl.h"

@interface LKBaseControl ()

@end

@implementation LKBaseControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    if (self.adjustAlphaWhenClick) {
        self.alphaValue = .8;
    }
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];
    [self triggerClickAction];
    if (self.adjustAlphaWhenClick) {
        self.alphaValue = 1;
    }
}

- (void)addTarget:(id)target clickAction:(SEL)action {
    self.target = target;
    self.clickAction = action;
}

- (void)triggerClickAction {
    if (self.clickAction && self.target) {
        [self sendAction:self.clickAction to:self.target];
    }
}

- (void)viewDidChangeEffectiveAppearance {
    [self _triggerDidChangeAppearanceBlock];
}

- (void)setDidChangeAppearance:(void (^)(LKBaseControl *, BOOL))didChangeAppearance {
    _didChangeAppearance = didChangeAppearance;
    [self _triggerDidChangeAppearanceBlock];
}

- (void)_triggerDidChangeAppearanceBlock {
    if (self.didChangeAppearance) {
        BOOL isDarkMode = [self.effectiveAppearance lk_isDarkMode];
        self.didChangeAppearance(self, isDarkMode);
    }
}

- (void)sizeToFit {
    $(self).size([self bestSize]);
}

- (BOOL)shouldTrackMouseEnteredAndExited {
    return NO;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (![self shouldTrackMouseEnteredAndExited]) {
        return;
    }
    [self.trackingAreas enumerateObjectsUsingBlock:^(NSTrackingArea * _Nonnull oldArea, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackingArea:oldArea];
    }];
    
    NSTrackingArea *newArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:newArea];
}

@end
