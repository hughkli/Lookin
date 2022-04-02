//
//  LKPopPanel.m
//  Lookin
//
//  Created by Li Kai on 2019/9/28.
//  https://lookin.work
//

#import "LKPopPanel.h"

@implementation LKPopPanel

- (instancetype)initWithSize:(NSSize)size {
    // 如果不是 NSWindowStyleMaskNonactivatingPanel 的话，当显示该 window 时点击别的 app，整个 Lookin 窗口都会被隐藏，不知道为什么
    if (self = [super initWithContentRect:NSMakeRect(0, 0, size.width, size.height) styleMask:NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:YES]) {
        LKBaseView *contentView = [LKBaseView new];
        contentView.layer.cornerRadius = 6;
        contentView.layer.borderWidth = 1;
        contentView.didChangeAppearanceBlock = ^(LKBaseView *view, BOOL isDarkMode) {
            view.backgroundColor = isDarkMode ? LookinColorMake(44, 44, 44) : LookinColorMake(236, 236, 236);
            view.layer.borderColor = isDarkMode ? SeparatorDarkModeColor.CGColor : SeparatorLightModeColor.CGColor;
        };
        self.contentView = contentView;
        self.backgroundColor = [NSColor clearColor];
    }
    return self;
}

// 如果没有这一句，window 里的输入框将无法触发编辑
- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
