//
//  LKBaseControl.h
//  Lookin
//
//  Created by Li Kai on 2018/8/28.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@interface LKBaseControl : NSControl

@property(nonatomic, assign) SEL clickAction;

- (void)triggerClickAction;

- (void)addTarget:(id)target clickAction:(SEL)action;

@property(nonatomic, assign) BOOL adjustAlphaWhenClick;

@property(nonatomic, copy) void (^didChangeAppearance)(LKBaseControl *control, BOOL isDarkMode);

@end

@interface LKBaseControl (NSSubclassingHooks)

/// 如果子类返回 YES，则 mouseEntered: 和 mouseExited: 会被调用。默认为 NO
- (BOOL)shouldTrackMouseEnteredAndExited;

@end
