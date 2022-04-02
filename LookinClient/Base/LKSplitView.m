//
//  LKSplitView.m
//  Lookin
//
//  Created by Li Kai on 2018/11/4.
//  https://lookin.work
//

#import "LKSplitView.h"

@implementation LKSplitView {
    BOOL _hasLayouted;
}

- (CGFloat)dividerThickness {
    return 0;
}

//- (NSColor *)dividerColor {
//    BOOL isDarkMode = self.effectiveAppearance.lk_isDarkMode;
//    if (isDarkMode) {
//        return [NSColor blackColor];
//    } else {
//        return [NSColor colorWithWhite:0 alpha:.1];
//    }
//}

- (void)layout {
    [super layout];
    
    if (!_hasLayouted) {
        if (self.didFinishFirstLayout) {
            self.didFinishFirstLayout(self);
        }
        _hasLayouted = YES;
    }
}

@end
