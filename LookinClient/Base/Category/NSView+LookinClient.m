//
//  NSView+Lookin.m
//  Lookin
//
//  Created by Li Kai on 2018/11/24.
//  https://lookin.work
//

#import "NSView+LookinClient.h"

@implementation NSView (LookinClient)

- (BOOL)isVisible {
    return !self.hidden && self.alphaValue > 0;
}

- (NSString *)backgroundColorName {
    return [self lookin_getBindObjectForKey:@"lk_backgroundColorName"];
}

- (void)setBackgroundColorName:(NSString *)backgroundColorName {
    [self lookin_bindObject:backgroundColorName forKey:@"lk_backgroundColorName"];
    if (!backgroundColorName) {
        self.layer.backgroundColor = nil;
    } else {
        self.layer.backgroundColor = [NSColor colorNamed:backgroundColorName].CGColor;        
    }
}

- (void)showDebugBorder {
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)lk_insertSubviewAtBottom:(NSView *)view {
    if (self.subviews.count) {
        [self addSubview:view positioned:NSWindowBelow relativeTo:self.subviews.firstObject];
    } else {
        [self addSubview:view];
    }
}

@end
