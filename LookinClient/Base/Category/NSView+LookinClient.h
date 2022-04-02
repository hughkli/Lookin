//
//  NSView+Lookin.h
//  Lookin
//
//  Created by Li Kai on 2018/11/24.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface NSView (LookinClient)

@property(nonatomic, assign, readonly) BOOL isVisible;

@property(nonatomic, copy) NSString *backgroundColorName;

/// 将一个 view 作为自己的 subview 并且放到最底部
- (void)lk_insertSubviewAtBottom:(NSView *)view;

- (void)showDebugBorder;

@end
