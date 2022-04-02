//
//  LKWindow.h
//  Lookin
//
//  Created by Li Kai on 2019/5/14.
//  https://lookin.work
//

#import <Cocoa/Cocoa.h>

@class LKPanelContentView;

@interface LKWindow : NSWindow

+ (instancetype)panelWindowWithWidth:(CGFloat)width height:(CGFloat)height contentView:(LKPanelContentView *)contentView;

@end
